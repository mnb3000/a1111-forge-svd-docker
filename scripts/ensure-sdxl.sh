#!/usr/bin/env bash
echo "Checking SDXL model"
export SDXL_PATH="/workspace/$APP/models/Stable-diffusion"
export VAE_PATH="/workspace/$APP/models/VAE"

source ./verify-checksum.sh

ensure_sdxl_base() {
    if [ ! -f $SDXL_PATH/sd_xl_base_1.0.safetensors ]; then
        echo -n "Checking if there's enough space for SDXL base download..."
        local FREE=$(df --output=avail -k $SDXL_PATH | tail -n 1)
        if [[ $FREE -lt 7000000 ]]; then
            echo -e "\nNot enough space for SDXL base download in $SDXL_PATH, skipping."
            return
        fi
        echo " Success!"

        echo "Starting SDXL base weights download..."
        wget -q --show-progress -O $SDXL_PATH/sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors -q --show-progress
        echo "Successfully downloaded SDXL base weights!"

        verify_checksum $SDXL_PATH/sd_xl_base_1.0.safetensors
        if [[ $? -gt 0 ]]; then
            exit 1
        fi
    else
        echo "Found SDXL base weights"
    fi
}

ensure_sdxl_refiner() {
    if [ ! -f $SDXL_PATH/sd_xl_refiner_1.0.safetensors ]; then
        echo -n "Checking if there's enough space for SDXL refiner download..."
        local FREE=$(df --output=avail -k $SDXL_PATH | tail -n 1)
        if [[ $FREE -lt 6100000 ]]; then
            echo -e "\nNot enough space for SDXL refiner download in $SDXL_PATH, skipping."
            return
        fi
        echo " Success!"

        echo "Starting SDXL refiner weights download..."
        wget -q --show-progress -O $SDXL_PATH/sd_xl_refiner_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
        echo "Successfully downloaded SDXL refiner weights!"

        verify_checksum $SDXL_PATH/sd_xl_refiner_1.0.safetensors
        if [[ $? -gt 0 ]]; then
            exit 1
        fi
    else
        echo "Found SDXL refiner weights"
    fi
}

ensure_sdxl_vae() {
    if [ ! -f $VAE_PATH/sdxl_vae.safetensors ]; then
        echo -n "Checking if there's enough space for SDXL VAE download..."
        local FREE=$(df --output=avail -k $VAE_PATH | tail -n 1)
        if [[ $FREE -lt 350000 ]]; then
            echo -e "\nNot enough space for SDXL VAE download in $VAE_PATH, skipping."
            return
        fi
        echo " Success!"

        echo "Starting SDXL VAE weights download..."
        wget -q --show-progress -O $VAE_PATH/sdxl_vae.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors -q --show-progress
        echo "Successfully downloaded SDXL VAE weights!"

        verify_checksum $VAE_PATH/sdxl_vae.safetensors
        if [[ $? -gt 0 ]]; then
            exit 1
        fi
    else
        echo "Found SDXL VAE weights"
    fi
}

ensure_sdxl_base
ensure_sdxl_refiner
ensure_sdxl_vae
echo "Successfully checked and downloaded SDXL weights!"
