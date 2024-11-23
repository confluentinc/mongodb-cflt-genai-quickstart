ARG IMAGE_ARCH
FROM public.ecr.aws/sam/build-python3.12:1.129.0-${IMAGE_ARCH}

# install terraform
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo && \
    dnf -y install terraform && \
    dnf clean all

# install confluent cli
RUN dnf config-manager --add-repo https://packages.confluent.io/confluent-cli/rpm/confluent-cli.repo && \
    dnf -y install confluent-cli && \
    dnf clean all

# install java
RUN dnf -y install java-17 && \
    dnf -y install maven && \
    dnf clean all

# install nodejs 20 for frontend builds
RUN touch ~/.bashrc && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    source ~/.bashrc && \
    nvm install 20 && \
    nvm use 20 && \
    nvm alias default 20 \

WORKDIR /app

# make the directories for frontend and infrastructure
RUN mkdir -p frontend infrastructure

WORKDIR /app/infrastructure

ENTRYPOINT ["terraform"]