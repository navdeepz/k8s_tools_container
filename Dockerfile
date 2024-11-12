# File for Arm based Mac Docker file
# Base image
FROM ubuntu:24.04

# # Installing prerequisite packages
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
    apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends \
    tzdata \
    keyboard-configuration \
    gnupg \
    software-properties-common \
    curl \
    wget \
    unzip \
    less \
    vim \
    htop \
    net-tools \
    dnsutils \
    traceroute \
    iproute2 \
    screen \
    ipmitool \
    git \
    python3-pip \
    jq \
    postgresql-client \
    bash-completion \
    kubectx \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI installation commands
#RUN	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Terrafrom 
# Setup workspace for Terraform
WORKDIR /usr/local/bin
# Define the versions to install
version_list=(1.7.5 1.8.5 1.9.7)

# Install each version
RUN for v in ${version_list[@]}; do \
    wget https://releases.hashicorp.com/terraform/${v}/terraform_${v}_linux_arm.zip && \
    unzip terraform_${v}_linux_arm.zip && \
    mv terraform terraform_${v} && \
    rm terraform_${v}_linux_arm.zip LICENSE.txt && \
    done && \
    terraform -install-autocomplete

# Install Kubectl_1.31 and Helm
RUN curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/arm64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh

# Kube-ps1 - kubernetes prompt
# Adding other kubernetes alias
RUN wget https://raw.githubusercontent.com/jonmosco/kube-ps1/refs/heads/master/kube-ps1.sh  -O /root/.kube-ps1.sh \
    && echo "\n\
source /root/.kube-ps1.sh  \n\
KUBE_PS1_SYMBOL_CUSTOM=img \n\
PS1='[\u@\h \W \$(kube_ps1)] \\\n# ' \n\
\n\
source /etc/bash_completion \n\
source <(kubectl completion bash) \n\
alias kgp='kubectl get pod -o wide'  \n\
alias kgn='kubectl get node -o wide'  \n\
alias kgpa='kubectl get pod -A -o wide'  \n\
alias kx=kubectx \n\
alias kn=kubens \n\
alias k=kubectl \n\
complete -o default -F __start_kubectl k \n\
" >> ~/.bashrc
