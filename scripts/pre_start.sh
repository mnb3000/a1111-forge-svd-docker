#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export APP="stable-diffusion-webui-forge"
DOCKER_IMAGE_VERSION_FILE="/workspace/${APP}/docker_image_version"

echo "Template version: ${TEMPLATE_VERSION}"
echo "venv: ${VENV_PATH}"
echo "SDXL enabled: ${ENABLE_SDXL_TURBO}"

if [[ -e ${DOCKER_IMAGE_VERSION_FILE} ]]; then
    EXISTING_VERSION=$(cat ${DOCKER_IMAGE_VERSION_FILE})
else
    EXISTING_VERSION="0.0.0"
fi

execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

sync_apps() {
    # Sync main venv to workspace to support Network volumes
    echo "Syncing main venv to workspace, please wait..."
    mkdir -p ${VENV_PATH}
    rsync --remove-source-files -rlptDu /venv/ ${VENV_PATH}/
    rm -rf /venv

    # Sync application to workspace to support Network volumes
    echo "Syncing ${APP} to workspace, please wait..."
    rsync --remove-source-files -rlptDu /${APP}/ /workspace/${APP}/
    rm -rf /stable-diffusion-webui-forge

    echo "${TEMPLATE_VERSION}" >${DOCKER_IMAGE_VERSION_FILE}
    echo "${VENV_PATH}" >"/workspace/${APP}/venv_path"
}

fix_venvs() {
    echo "Fixing Stable Diffusion Web UI venv..."
    /fix_venv.sh /venv ${VENV_PATH}
}

check_and_download_models() {
    execute_script "/ensure-sdxl.sh" "Checking SDXL weights..."
    execute_script "/ensure-svd.sh" "Checking SVD XT 1.1 weights..."
    if [[ $ENABLE_SDXL_TURBO == "true" ]]; then
        execute_script "/ensure-sdxl-turbo.sh" "Checking SDXL Turbo weights..."
    fi
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs
        check_and_download_models

        # Add VENV_PATH to webui-user.sh
        sed -i "s|venv_dir=VENV_PATH|venv_dir=${VENV_PATH}\"\"|" /workspace/stable-diffusion-webui-forge/webui-user.sh

        # Create logs directory
        mkdir -p /workspace/logs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
else
    echo "Existing version is newer than the template version, not syncing!"
fi

if [[ ${DISABLE_AUTOLAUNCH} ]]; then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   /start_a1111.sh"
else
    /start_a1111.sh
fi

echo "All services have been started"
