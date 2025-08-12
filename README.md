# python-nlp-dev-container

This project aims to build and make available simple docker container image 
for developing python based NLP projects. Keeping in mind how developers use 
different development workflows to train, finetune or develop in our cluster, 
this image can be adjusted with runtime variables to deploy a container with 
support for - (1) Jupyter Lab, (2) SSH + Visual Studio Code and (3) Python 
script as Kubernetes Jobs workflows.

## Features

The goal is to keep building up-to-date compatible images. The most recent 
version comes with -

- Ubuntu: 24.04
- Python: 3.12.11
- CUDA: 12.8.1
  (https://hub.docker.com/r/nvidia/cuda/tags)

- Installed Terminal Tools:
  - curl
  - gawk
  - git
  - htop
  - iputils-ping
  - less
  - locales
  - nano
  - net-tools
  - openssh-server
  - screen
  - tmux
  - unzip
  - vim
  - wget

- A preconfigured virtual environment (nlp-venv) with following packages -
  - torch==2.7.1 + torchaudio==2.7.1 + torchvision==0.22.1
    (https://pytorch.org/get-started/previous-versions/)
  
  - accelerate
  - autogluon
  - beautifulsoup4
  - bpemb
  - dask[complete]
  - datasets
  - evaluate
  - fastapi
  - flair
  - gensim
  - huggingface_hub
  - ipywidgets
  - Jinja2
  - jupyterlab
  - jupyterlab-widgets
  - keras
  - matplotlib
  - nltk
  - notebook
  - numpy
  - optuna
  - pandas
  - plotly
  - pydantic
  - python-dateutil
  - pytorch-lightning
  - PyYAML
  - requests
  - rich
  - scikit-learn
  - scipy
  - seaborn
  - segtok
  - sentencepiece
  - seqeval
  - SoMaJo
  - spacy
  - sqlitedict
  - streamlit
  - tensorboard
  - termcolor
  - tokenizers
  - torchdata
  - tqdm
  - transformers
  - urllib3
  - uvicorn
  - wandb

- Timezone preconfigured (Europe/Berlin)