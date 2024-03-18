#!/usr/bin/env bash
echo "Checking SVD XT 1.1 model"
export SVD_PATH=$APP/models/Stable-diffusion

ensure_svd() {
    if [ ! -f $SVD_PATH/svd_xt-1.1.safetensors ]; then # TODO: add checksum check
        echo -n "Checking if there's enough space for SVD XT 1.1 download..."
        FREE=$(df --output=avail -k $SVD_PATH | tail -n 1)
        if [[ $FREE -lt 5000000 ]]; then
            echo -e "\nNot enough space for SVD XT 1.1 download in $SVD_PATH, skipping."
            return
        fi
        echo " Success!"
        echo "Starting SVD-XT weights download..."
        download-model https://civitai.com/models/207992 $SVD_PATH/svd_xt-1.1.safetensors
        echo "Successfully downloaded SVD-XT weights!"
    else
        echo "Found SVD XT 1.1 weights"
    fi
}

ensure_svd
echo "Successfully checked and downloaded SVD XT 1.1 weights!"
