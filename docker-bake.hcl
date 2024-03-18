variable "USERNAME" {
    default = "mnb3000"
}

variable "APP" {
    default = "a1111-forge-svd-docker"
}

variable "RELEASE" {
    default = "0.0.1-testing1"
}

variable "CU_VERSION" {
    default = "118"
}

variable "IS_LATEST" {
    default = false
}

target "default" {
    dockerfile = "Dockerfile"
    tags = (
      length(regexall("^testing", RELEASE)) > 0 ?
      ["${USERNAME}/${APP}:testing"] :
      flatten(["${USERNAME}/${APP}:${RELEASE}", IS_LATEST != false ? ["${USERNAME}/${APP}:latest"] : []])
    )
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
