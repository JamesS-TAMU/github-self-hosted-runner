#!/bin/bash

echo "Setting up msmtp ... "
echo

echo "Constructing msmtprc ... "
echo

MSMTP_LOGFILE_DATE=$(date +"%Y-%m-%d")
MSMTP_LOGFILE="msmtp-${LOGFILE_DATE}.log"

sed -i "s|SMTP_RELAY|${SMTP_RELAY}|g" /etc/msmtprc
sed -i "s|SMTP_PORT|${SMTP_PORT}|g" /etc/msmtprc
sed -i "s|MSMTP_LOG_LOCATION|${MSMTP_LOG_LOCATION}/${MSMTP_LOGFILE}|g" /etc/msmtprc
sed -i "s|MSMTP_NOTIFICATION_EMAIL_FROM|${MSMTP_NOTIFICATION_EMAIL_FROM}|g" /etc/msmtprc

echo
echo "/etc/msmtprc constructed:"
echo

ls -al /etc/msmtprc

echo
cat /etc/msmtprc
echo

echo
echo "Done setting up msmtp."
echo

echo "Adding \"runner\" user to \"/var/run/docker.sock\"\'s group : "
echo
echo 'Before changing:'
echo

sudo getent group docker

echo 'After changing: '
echo

DOCKER_SOCK_GID=$(stat -c "%g" /var/run/docker.sock)
sudo groupmod -g ${DOCKER_SOCK_GID} docker

sudo getent group docker

echo "Done adding \"runner\" to ${DOCKER_SOCK_GID} ."
echo

newgrp docker << EOF

echo "Starting the runner via \"${ACTIONS_RUNNER_DIR}/run.sh &\" : "
echo

${ACTIONS_RUNNER_DIR}/run.sh &

EOF

tail -f /dev/null

