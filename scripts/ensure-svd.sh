#!/usr/bin/env bash
echo "Checking SVD XT 1.1 model"
export SVD_PATH=/workspace/$APP/models/svd

source ./verify-checksum.sh

ensure_svd() {
    if [ ! -f $SVD_PATH/stableVideoDiffusion_img2vidXt11.safetensors ]; then
        echo -n "Checking if there's enough space for SVD XT 1.1 download..."
        local FREE=$(df -k $SVD_PATH | tr -s ' ' | cut -d" " -f 4 | tail -n 1)
        if [[ $FREE -lt 5000000 ]]; then
            echo -e "\nNot enough space for SVD XT 1.1 download in $SVD_PATH, skipping."
            return
        fi
        echo " Success!"

        echo "Starting SVD-XT weights download..."
        download-model https://civitai.com/api/download/models/329995 $SVD_PATH $CIVITAI_TOKEN
        echo "Successfully downloaded SVD-XT weights!"

        verify_checksum $SVD_PATH/stableVideoDiffusion_img2vidXt11.safetensors
    else
        echo "Found SVD XT 1.1 weights"
    fi
}

ensure_svd
echo "Successfully checked and downloaded SVD XT 1.1 weights!"
