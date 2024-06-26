variable "USERNAME" {
    default = "mnb3000"
}

variable "APP" {
    default = "a1111-forge-svd-docker"
}

variable "RELEASE" {
    default = "0.1.0"
}

variable "CU_VERSION" {
    default = "118"
}

target "docker-metadata-action" {}

target "default" {
    inherits = ["docker-metadata-action"]
    dockerfile = "Dockerfile"
    # Uncomment this line to build locally
    # tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.1.2+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.23.post1+cu${CU_VERSION}"
        WEBUI_VERSION = "v1.7.0d"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/stable-diffusion-webui-forge"
    }
    platforms = ["linux/amd64"]
}
