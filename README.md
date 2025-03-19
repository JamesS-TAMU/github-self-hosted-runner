## Containerized Self-hosted GitHub Actions Runner for TAMU Folio Scratch Environment

### Instructions

#### Overview

- The Folio Scratch Environment runs on Rancher v2.9.3 .
- The actions-runner is built on `ubuntu:24.04` .
- The actions-runner needs to run in privileged mode to share the docker sock.
- A `bind mount` of `/var/run/docker.sock` is needed for the container to utilize the host/node's docker socket.
- A ServiceAccount, ClusterRole, and a ClusterRoleBinding need to be configured in your cluster for `kubectl` .
- A volume can be mounted to the `ACTIONS_RUNNER_DIR="/opt/actions-runner"` path for persistent configs.
- The installation and entrypoint scripts are under the `ACTIONS_RUNNER_SCRIPTS_DIR="/opt/actions-runner-scripts"` directory.

#### Build image

- Make a copy of the `example-build.sh` and name it to `build.sh`, and modify the `ACTIONS_RUNNER_IMAGE_TAG` and `ACTIONS_RUNNER_IMAGE_FULL_TAG` variables as needed.
- Login to your docker registry before running the script.
- Run the `build.sh` to build and push your actions-runner image.

#### Configurations

The following environment variables should be supplied. This information can be found at:

Your GitHub Repo --> Settings --> Actions --> Runners --> New self-hosted runner --> Linux

e.g. :

For repo `https://github.com/jameswsullivan/mysamplerepo` , the following information can be found under the `Download` and `Configure` sections :

**Download**
```
curl -o actions-runner-linux-x64-2.320.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-2.320.0.tar.gz
```

**Configure**
```
./config.sh --url https://github.com/jameswsullivan/mysamplerepo --token ABCDEFGHIJKLMNOPQRSTUVWXYZABC
```


The environment variables would then be configured as follows :

```
ENV GITHUB_REPO_URL="https://github.com/jameswsullivan/mysamplerepo"
ENV GITHUB_REPO_TOKEN="ABCDEFGHIJKLMNOPQRSTUVWXYZABC"
ENV ACTIONS_RUNNER_INSTALL_FILENAME="actions-runner-linux-x64-2.320.0.tar.gz"
ENV ACTIONS_RUNNER_DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-x64-2.320.0.tar.gz"

ENV GITHUB_RUNNER_GROUP=""
ENV GITHUB_RUNNER_NAME="mysamplerepo-runner"
ENV GITHUB_RUNNER_LABELS=""
ENV GITHUB_RUNNER_WORK_FOLDER=""

KUBECONFIG_CONTENT="<CONTENT_FROM_YOUR_KUBECONFIG_FILE>"
```

#### Start and run the actions-runner

- upon first startup, run the container with `sh -c /opt/actions-runner-scripts/install-runner.sh` script to install and configure the actions-runner.
- after the runner is configured, change the startup command to `sh -c /opt/actions-runner-scripts/entrypoint.sh` and start the runner.

#### ServiceAccount, ClusterRole, and ClusterRoleBinding

```
# 1. Create a ServiceAccount, e.g., kubectl-sa, in the namespace you intend to deploy the actions-runner.

# 2. Create the ClusterRole:
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubectl-clusterrole
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch", "update", "patch"]

# 3. Create the ClusterRoleBinding:
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubectl-clusterrolebinding
subjects:
  - kind: ServiceAccount
    name: kubectl-sa
    namespace: <YOUR_NAMESPACE>
roleRef:
  kind: ClusterRole
  name: kubectl-clusterrole
  apiGroup: rbac.authorization.k8s.io
```

