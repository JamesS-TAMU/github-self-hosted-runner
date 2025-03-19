#!/bin/bash

# Configure docker sock:
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

# Start the runner:
newgrp docker << EOF

echo "The following folio related configs are being applied in the background : "
echo
echo 'yarn config set @folio:registry https://repository.folio.org/repository/npm-folioci/ &'
echo 'yarn global add @folio/stripes-cli &'

yarn config set @folio:registry https://repository.folio.org/repository/npm-folioci/ &
yarn global add @folio/stripes-cli &

echo
echo "......"
echo

echo "Starting the runner via \"${ACTIONS_RUNNER_DIR}/run.sh &\" : "
echo

${ACTIONS_RUNNER_DIR}/run.sh &

echo
echo
echo "run.sh has started ... "
echo
echo

EOF

tail -f /dev/null

