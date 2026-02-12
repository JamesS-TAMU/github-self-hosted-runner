FROM ubuntu:25.10

ENV DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

ENV RUNNER_USER_ID="3001"
ENV RUNNER_USER_NAME="runner"
ENV ACTIONS_RUNNER_DIR="/opt/actions-runner"
ENV ACTIONS_RUNNER_SCRIPTS_DIR="/opt/actions-runner-scripts"
ENV CUSTOM_SCRIPTS_DIR="/opt/scripts"

ENV SMTP_RELAY=""
ENV SMTP_PORT=""
ENV MSMTP_LOG_LOCATION="/mnt/logs"
ENV MSMTP_NOTIFICATION_EMAIL_FROM=""

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
    apt-get install -y nano git curl unzip tzdata locales ca-certificates sudo msmtp postgresql-client && \
    apt-get upgrade ca-certificates -y && \
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Configure actions-runner :
RUN apt-get install -y libicu-dev jq docker.io && \
    mkdir ${ACTIONS_RUNNER_DIR} && \
    mkdir ${ACTIONS_RUNNER_SCRIPTS_DIR} && \
    mkdir ${CUSTOM_SCRIPTS_DIR} && \
    groupadd --non-unique -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    useradd --non-unique -d /${RUNNER_USER_NAME} -m -u ${RUNNER_USER_ID} -g ${RUNNER_USER_ID} ${RUNNER_USER_NAME} && \
    usermod -aG docker ${RUNNER_USER_NAME} && \
    chown -R ${RUNNER_USER_NAME}:${RUNNER_USER_NAME} ${ACTIONS_RUNNER_DIR} && \
    usermod -aG sudo ${RUNNER_USER_NAME} && \
    echo 'runner  ALL=(ALL)    NOPASSWD: ALL' >> /etc/sudoers

# Install latest kubectl :
RUN apt-get update -y && \
    apt-get install -y apt-transport-https gnupg && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

COPY msmtprc /etc/msmtprc
COPY ./entrypoint.sh ${ACTIONS_RUNNER_SCRIPTS_DIR}/entrypoint.sh
COPY ./install-runner.sh ${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh

RUN chmod +x ${ACTIONS_RUNNER_SCRIPTS_DIR}/entrypoint.sh && \
    chmod +x ${ACTIONS_RUNNER_SCRIPTS_DIR}/install-runner.sh

USER ${RUNNER_USER_NAME}

WORKDIR ${ACTIONS_RUNNER_DIR}
