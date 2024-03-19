# Docker image for A1111 Forge with Deforum, Stable Video Diffusion XT 1.1, Stable Diffusion XL Base/Turbo

> [!IMPORTANT]
> You need to set `$CIVITAI_TOKEN` environment variable in order for Stable Video Diffusion XT 1.1 to download,
> otherwise it will not be downloaded

## Installs

### Bundled with image

-   Ubuntu 22.04 LTS
-   CUDA 11.8
-   Python 3.10.12
-   Torch 2.1.2
-   xformers 0.0.23.post1
-   Jupyter Lab
-   [Automatic1111 Stable Diffusion Web UI Forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) 1.7.0d
-   [Deforum Forge extension](https://github.com/deforum-art/sd-forge-deforum)
-   [Infinite Image Browsing extension](https://github.com/zanllp/sd-webui-infinite-image-browsing)
-   [CivitAI extension](https://github.com/civitai/sd_civitai_extension)
-   [CivitAI Browser+ extension](https://github.com/BlafKing/sd-civitai-browser-plus)
-   [sdxl_vae.safetensors](https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors)
-   [runpodctl](https://github.com/runpod/runpodctl)
-   [OhMyRunPod](https://github.com/kodxana/OhMyRunPod)
-   [RunPod File Uploader](https://github.com/kodxana/RunPod-FilleUploader)
-   [croc](https://github.com/schollz/croc)
-   [rclone](https://rclone.org/)

### Downloaded at first launch

-   [sd_xl_base_1.0.safetensors](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors)
-   [sd_xl_refiner_1.0.safetensors](https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors)
-   [stableVideoDiffusion_img2vidXt11.safetensors](https://civitai.com/models/207992)
-   (Optional, set `ENABLE_SDXL_TURBO=true`) [sd_xl_turbo_1.0.safetensors](https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0.safetensors)

<!-- ## Available on RunPod -->
<!---->
<!-- This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy). -->
<!-- You can use my custom [RunPod template](https://runpod.io/console/gpu-cloud?template=ts8ze6urzh&ref=2xxro4sy) -->
<!-- to launch it on RunPod. -->

## Building the Docker image

> [!NOTE]
> You will need to edit the `docker-bake.hcl` file and update `USERNAME`,
> and `RELEASE`. You can obviously edit the other values too, but these
> are the most important ones.

<!-- > [!IMPORTANT] -->
<!-- > In order to cache the models, you will need at least 32GB of CPU/system -->
<!-- > memory (not VRAM) due to the large size of the models. If you have less -->
<!-- > than 32GB of system memory, you can comment out or remove the code in the -->
<!-- > `Dockerfile` that caches the models. -->

```bash
# Clone the repo
git clone https://github.com/mnb3000/a1111-forge-svd-docker.git

# Log in to Docker Hub
docker login

# Build the image, tag the image, and push the image to Docker Hub
docker buildx bake -f docker-bake.hcl --push
```

## Running Locally

### Install Nvidia CUDA Driver

-   [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
-   [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 8888:8888 \
  -p 2999:2999 \
  -e VENV_PATH=/workspace/venvs/stable-diffusion-webui-forge \
  mnb3000/a1111-forge-svd-docker:latest
```

You can obviously substitute the image name and tag with your own.

### Ports

| Connect Port | Internal Port | Description                   |
| ------------ | ------------- | ----------------------------- |
| 3000         | 3001          | A1111 Stable Diffusion Web UI |
| 8888         | 8888          | Jupyter Lab                   |
| 2999         | 2999          | RunPod File Uploader          |

### Environment Variables

| Variable             | Description                                  | Default                                       |
| -------------------- | -------------------------------------------- | --------------------------------------------- |
| VENV_PATH            | Set the path for the Python venv for the app | /workspace/venvs/stable-diffusion-webui-forge |
| JUPYTER_LAB_PASSWORD | Set a password for Jupyter lab               | not set - no password                         |
| DISABLE_AUTOLAUNCH   | Disable Web UIs from launching automatically | enabled                                       |
| ENABLE_SDXL_TURBO    | Enable SDXL Turbo download on startup        | false                                         |
| CIVITAI_TOKEN        | CivitAI access token                         |                                               |

## Logs

Stable Diffusion Web UI creates a log file, and you can tail it instead of
killing the services to view the logs

| Application             | Log file                  |
| ----------------------- | ------------------------- |
| Stable Diffusion Web UI | /workspace/logs/webui.log |

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/mnb3000/a1111-forge-svd-docker)
are welcome. Bug fixes and new features are encouraged.
