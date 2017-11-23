FROM golang:1.9-stretch

ENV TERRAFORM_VERSION=0.11.0
ENV TERRAFORM_SHA256SUM=402b4333792967986383670134bb52a8948115f83ab6bda35f57fa2c3c9e9279

ENV CLOUD_SDK_VERSION 180.0.0

# package dependencies
RUN apt-get update && apt-get -qqy dist-upgrade \
&& apt-get -qqy install mktemp git curl unzip python-pip apt-transport-https lsb-release openssh-client jq

# Terraform
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& sha256sum --quiet -c terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin \
&& rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# AWS CLI
RUN pip install awscli

# Google Cloud SDK
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
&& echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
&& apt-get update && apt-get -qqy install google-cloud-sdk \
&& gcloud config set core/disable_usage_reporting true \
&& gcloud config set component_manager/disable_update_check true \
&& gcloud config set metrics/environment github_docker_image

# cleanup
RUN rm -rf /var/lib/apt/lists/*
