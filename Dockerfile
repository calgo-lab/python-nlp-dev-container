ARG CUDA_VERSION='12.4.1'
ARG PYTHON_VERSION='3.12.11'
ARG TIMEZONE='Europe/Berlin'
ARG TORCH_VERSION='2.5.1'
ARG TORCHAUDIO_VERSION='2.5.1'
ARG TORCHVISION_VERSION='0.20.1'
ARG UBUNTU_VERSION='22.04'
ARG VENV_NAME='nlp-venv'
ARG WORKDIR='/'


FROM ubuntu:${UBUNTU_VERSION} AS python-builder

ARG PYTHON_VERSION
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --assume-yes \
    build-essential \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    && \
    rm --recursive --force /var/lib/apt/lists/* && \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" && \
    wget "${PYTHON_URL}" && \
    tar --extract --gzip --file=Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make --jobs="$(nproc)" && make install

ARG CUDA_VERSION
ARG UBUNTU_VERSION

FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --assume-yes \
    ca-certificates \
    curl \
    gawk \
    git \
    gosu \
    htop \
    iputils-ping \
    less \
    locales \
    nano \
    net-tools \
    openssh-server \
    screen \
    sudo \
    tmux \
    tzdata \
    unzip \
    vim \
    wget \
    && \
    rm --recursive --force /var/lib/apt/lists/*

COPY --from=python-builder /usr/local /usr/local

ARG PYTHON_VERSION
ARG TIMEZONE

RUN PYTHON_SHORT_VERSION=$(echo "${PYTHON_VERSION}" | cut --delimiter=. --fields=1,2) && \
    ln --symbolic --force /usr/local/bin/python${PYTHON_SHORT_VERSION} /usr/bin/python && \
    ln --symbolic --force /usr/local/bin/pip${PYTHON_SHORT_VERSION} /usr/bin/pip && \
    ln --symbolic --force /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo ${TIMEZONE} > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    wget --output-document=/root/.screenrc https://raw.githubusercontent.com/thomhastings/screenrc/master/screenrc

ENV TZ=${TIMEZONE}

ARG CUDA_VERSION
ARG PYTHON_VERSION
ARG TORCH_VERSION
ARG TORCHAUDIO_VERSION
ARG TORCHVISION_VERSION
ARG VENV_NAME

RUN PYTHON_SHORT_VERSION=$(echo "${PYTHON_VERSION}" | cut --delimiter=. --fields=1,2) && \
    /usr/local/bin/python${PYTHON_SHORT_VERSION} -m venv ${VENV_NAME} && \
    . ${VENV_NAME}/bin/activate && \
    pip install --upgrade setuptools pip && \
    CUDA_TAG=cu$(echo "${CUDA_VERSION}" | cut --delimiter=. --fields=1,2 | tr --delete .) && \
    pip install --no-cache-dir --prefer-binary --retries 5 --timeout 60 torch==${TORCH_VERSION} torchvision==${TORCHVISION_VERSION} torchaudio==${TORCHAUDIO_VERSION} --extra-index-url https://download.pytorch.org/whl/${CUDA_TAG} && \
    rm --recursive --force /root/.cache/pip

COPY requirements.txt /tmp/requirements.txt
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY setup_jupyter.py /opt/setup_jupyter.py

RUN . ${VENV_NAME}/bin/activate && \
    pip install --no-cache-dir --prefer-binary --retries 5 --timeout 60 --requirement /tmp/requirements.txt && \
    rm --recursive --force /root/.cache/pip && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    echo "source /${VENV_NAME}/bin/activate" >> /root/.bashrc

ENV VENV_NAME=${VENV_NAME} \
    ENABLE_SSH=no \
    SSH_PUBLIC_KEY_FILENAME="" \
    ENABLE_JUPYTER=no \
    JUPYTER_PASS="" \
    RUN_PYTHON_SCRIPT=no \
    PYTHON_SCRIPT_PATH="" \
    KEEP_CONTAINER=no

ARG WORKDIR
WORKDIR ${WORKDIR}

EXPOSE 22 8888

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]