#!/bin/bash
set -e

source /${VENV_NAME}/bin/activate

if [ "${ENABLE_SSH}" = "yes" ]; then
    if [ -z "${SSH_PUBLIC_KEY_FILENAME}" ] || [ ! -f "/tmp/${SSH_PUBLIC_KEY_FILENAME}" ]; then
        echo "Error: ENABLE_SSH is set to yes but SSH_PUBLIC_KEY_FILENAME is not set or file does not exist in /tmp/"
        exit 1
    fi

    mkdir --parents /run/sshd /root/.ssh
    chmod 700 /root/.ssh
    cp "/tmp/${SSH_PUBLIC_KEY_FILENAME}" /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    service ssh start
fi

if [ "${ENABLE_JUPYTER}" = "yes" ]; then
    if [ -z "${JUPYTER_PASS}" ]; then
        echo "Error: ENABLE_JUPYTER is set to yes but JUPYTER_PASS is not set"
        exit 1
    fi

    python /opt/setup_jupyter.py "${JUPYTER_PASS}"
    jupyter lab --allow-root --config=/etc/jupyter/jupyter_lab_config.py &
fi

if [ "${RUN_PYTHON_SCRIPT}" = "yes" ]; then
    if [ -z "${PYTHON_SCRIPT_PATH}" ] || [ ! -f "${PYTHON_SCRIPT_PATH}" ]; then
        echo "Error: RUN_PYTHON_SCRIPT is set to yes but PYTHON_SCRIPT_PATH is not set or file does not exist"
        exit 1
    fi
    
    python "${PYTHON_SCRIPT_PATH}" "$@"
fi

if [ "${KEEP_CONTAINER}" = "yes" ]; then
    echo "KEEP_CONTAINER is set to yes, keeping container alive..."
    tail --follow=name /dev/null
fi

exec "$@"