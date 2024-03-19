#!/usr/bin/env bash
echo "Checking SDXL model"
export SDXL_TURBO_PATH="/workspace/$APP/models/Stable-diffusion"

source ./verify-checksum.sh

ensure_sdxl_turbo() {
    if [ ! -f $SDXL_TURBO_PATH/sd_xl_turbo_1.0.safetensors ]; then
        echo -n "Checking if there's enough space for SDXL Turbo download..."
        local FREE=$(df --output=avail -k $SDXL_TURBO_PATH | tail -n 1)
        if [[ $FREE -lt 7000000 ]]; then
            echo -e "\nNot enough space for SDXL Turbo download in $SDXL_TURBO_PATH, skipping."
            return
        fi
        echo " Success!"

        echo "Starting SDXL Turbo weights download..."
        wget -O $SDXL_TURBO_PATH/sd_xl_turbo_1.0.safetensors https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0.safetensors -q --show-progress
        echo "Successfully downloaded SDXL Turbo weights!"

        verify_checksum $SDXL_PATH/sd_xl_turbo_1.0.safetensors
        if [[ $? -gt 0 ]]; then
            return
        fi
    else
        echo "Found SDXL Turbo weights"
    fi
}

ensure_sdxl_turbo
echo "Successfully checked and downloaded SDXL weights!"
