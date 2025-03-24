FROM ubuntu:24.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

ENV RUNNER_USER_ID="3001"
ENV RUNNER_USER_NAME="runner"
ENV ACTIONS_RUNNER_DIR="/opt/actions-runner"
ENV ACTIONS_RUNNER_SCRIPTS_DIR="/opt/actions-runner-scripts"

# Provide the information from the "Runners / Add new self-hosted runner" page :
ENV GITHUB_REPO_URL=""
ENV GITHUB_REPO_TOKEN=""
ENV ACTIONS_RUNNER_INSTALL_FILENAME=""
ENV ACTIONS_RUNNER_DOWNLOAD_URL=""

ENV GITHUB_RUNNER_GROUP=""
ENV GITHUB_RUNNER_NAME=""
ENV GITHUB_RUNNER_LABELS=""
ENV GITHUB_RUNNER_WORK_FOLDER=""

# Intall basic packages :
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  tzdata locales ca-certificates sudo && \
    apt-get upgrade ca-certificates -y && \
    update-ca-certificates && \
    apt-get install -y iputils-ping iproute2 net-tools && \
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Configure actions-runner :
RUN apt-get install -y wget curl vim nano git zip unzip tree psmisc && \
    apt-get install -y npm yarnpkg openjdk-21-jdk maven && \
    apt-get install -y libicu-dev docker.io jq && \
    ln -s /usr/bin/yarnpkg /usr/bin/yarn && \
    mkdir ${ACTIONS_RUNNER_DIR} && \
    mkdir ${ACTIONS_RUNNER_SCRIPTS_DIR} && \
    groupadd --non-unique -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    useradd --non-unique -d /${RUNNER_USER_NAME} -m -u ${RUNNER_USER_ID} -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    usermod -aG docker runner && \
    chown -R ${RUNNER_USER_NAME}:${RUNNER_USER_NAME} ${ACTIONS_RUNNER_DIR} && \
    usermod -aG sudo runner && \
    echo 'runner  ALL=(ALL)    NOPASSWD: ALL' >> /etc/sudoers

# Install kubectl :
RUN apt-get update -y && \
    apt-get install -y apt-transport-https gnupg && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update -y && \
    apt-get install -y kubectl

COPY ./entrypoint.sh ${ACTIONS_RUNNER_SCRIPTS_DIR}/entrypoint.sh
COPY ./install-runner.sh ${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh

RUN chmod +x ${ACTIONS_RUNNER_SCRIPTS_DIR}/entrypoint.sh && \
    chmod +x ${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh

USER ${RUNNER_USER_NAME}

WORKDIR ${ACTIONS_RUNNER_DIR}
