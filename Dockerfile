FROM golang:1.9-stretch

ENV TERRAFORM_VERSION=0.11.7
ENV TERRAFORM_SHA256SUM=6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418

ENV CLOUD_SDK_VERSION 194.0.0

ENV KUBECTL_VERSION=1.10.0

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
&& apt-get update && apt-get -qqy install google-cloud-sdk google-cloud-sdk-app-engine-go \
&& gcloud config set core/disable_usage_reporting true \
&& gcloud config set component_manager/disable_update_check true \
&& gcloud config set metrics/environment github_docker_image

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
&& chmod +x ./kubectl \
&& mv ./kubectl /usr/bin

# Docker
RUN apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common \
&& curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
&& apt-key fingerprint 0EBFCD88 \
&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
&& apt-get update && apt-get -qqy install docker-ce

# cleanup
RUN rm -rf /var/lib/apt/lists/*
