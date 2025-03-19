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

echo "Adding folio related configs : "
echo

yarn config set @folio:registry https://repository.folio.org/repository/npm-folioci/
yarn global add @folio/stripes-cli

echo
echo "Done configuring folio related configs."
echo

echo "Starting the runner via \"${ACTIONS_RUNNER_DIR}/run.sh &\" : "
echo

${ACTIONS_RUNNER_DIR}/run.sh &

EOF

tail -f /dev/null

