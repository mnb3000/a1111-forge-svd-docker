# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    python3.10-venv \
    python3-pip \
    python3-tk \
    python3-dev \
    nodejs \
    npm \
    bash \
    coreutils \
    dos2unix \
    git \
    git-lfs \
    ncdu \
    nginx \
    net-tools \
    inetutils-ping \
    openssh-server \
    libglib2.0-0 \
    libsm6 \
    libgl1 \
    libxrender1 \
    libxext6 \
    ffmpeg \
    wget \
    curl \
    psmisc \
    rsync \
    vim \
    zip \
    unzip \
    p7zip-full \
    htop \
    screen \
    tmux \
    bc \
    pkg-config \
    plocate \
    libcairo2-dev \
    libgoogle-perftools4 \
    libtcmalloc-minimal4 \
    apt-transport-https \
    ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install Torch, xformers and tensorrt
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION

RUN pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL}

# Stage 2: Install applications
FROM base as setup

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
WORKDIR /
ARG WEBUI_VERSION
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git && \
    cd /stable-diffusion-webui-forge && \
    git checkout tags/${WEBUI_VERSION}

WORKDIR /stable-diffusion-webui-forge
RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==${TORCH_VERSION} torchvision torchaudio --index-url ${INDEX_URL} && \
    pip3 install --no-cache-dir xformers==${XFORMERS_VERSION} --index-url ${INDEX_URL} && \
    pip3 install tensorflow[and-cuda] && \
    deactivate

# Install the dependencies for the Automatic1111 Stable Diffusion Web UI
COPY a1111/cache-sd-model.py a1111/install-automatic.py ./
RUN source /venv/bin/activate && \
    pip3 install -r requirements_versions.txt && \
    python3 -m install-automatic --skip-torch-cuda-test && \
    deactivate


# Clone the Automatic1111 Extensions
RUN git clone --depth=1 https://github.com/deforum-art/sd-forge-deforum.git extensions/deforum && \
    git clone --depth=1 https://github.com/zanllp/sd-webui-infinite-image-browsing.git extensions/infinite-image-browsing && \
    git clone --depth=1 https://github.com/civitai/sd_civitai_extension.git extensions/sd_civitai_extension && \
    git clone --depth=1 https://github.com/BlafKing/sd-civitai-browser-plus.git extensions/sd-civitai-browser-plus

# Install dependencies for Deforum Forge, Infinite Image Browsing, CivitAI Browser+ extensions
RUN source /venv/bin/activate && \
    pip3 install basicsr &&  \
    cd /stable-diffusion-webui-forge/extensions/deforum && \
    pip3 install -r requirements.txt && \
    pip3 install onnxruntime-gpu && \
    cd /stable-diffusion-webui-forge/extensions/infinite-image-browsing && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui-forge/extensions/sd_civitai_extension && \
    pip3 install -r requirements.txt && \
    deactivate

# Install dependencies for Civitai Browser+ extension
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui-forge/extensions/sd-civitai-browser-plus && \
    pip3 install send2trash ZipUnicode fake-useragent && \
    deactivate

# Install Jupyter, gdown and OhMyRunPod
RUN pip3 install -U --no-cache-dir jupyterlab \
    jupyterlab_widgets \
    ipykernel \
    ipywidgets \
    gdown \
    OhMyRunPod

# Install RunPod File Uploader
RUN curl -sSL https://github.com/kodxana/RunPod-FilleUploader/raw/main/scripts/installer.sh -o installer.sh && \
    chmod +x installer.sh && \
    ./installer.sh

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Install runpodctl
ARG RUNPODCTL_VERSION
RUN wget "https://github.com/runpod/runpodctl/releases/download/${RUNPODCTL_VERSION}/runpodctl-linux-amd64" -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install croc
RUN curl https://getcroc.schollz.com | bash

# Install speedtest CLI
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt install speedtest

# Install CivitAI Model Downloader
COPY scripts/civitai-download.sh /usr/local/bin/download-model
RUN chmod +x /usr/local/bin/download-model

# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui-forge/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion-webui-forge/styles.csv

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

# Set the civitai token
ARG CIVITAI_TOKEN
ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Copy the checksums
RUN mkdir -p ./checksums
COPY checksums/* ./checksums

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
