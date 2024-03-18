#!/usr/bin/env bash
echo "Checking SVD XT 1.1 model"
export SVD_PATH=/workspace/$APP/models/Stable-diffusion

verify_checksum() {
    local FILENAME = $(basename $1)

    echo "Verifying checksum for $FILENAME..."

    local CHECKSUM = $(sha256sum $1)
    local CHECKSUM_FILENAME = $FILENAME.sha256
    local EXPECTED_CHECKSUM = $(cat ../checksums/$CHECKSUM_FILENAME)

    if [[ $CHECKSUM = $EXPECTED_CHECKSUM ]]; then
        echo "Checksum valid!"
        return 0
    fi
    echo "Checksum not valid! Removing file, restart container to retry..."
    rm -f $1
    return 1
}

ensure_svd() {
    if [ ! -f $SVD_PATH/svd_xt-1.1.safetensors ]; then
        echo -n "Checking if there's enough space for SVD XT 1.1 download..."
        local FREE=$(df --output=avail -k $SVD_PATH | tail -n 1)
        if [[ $FREE -lt 5000000 ]]; then
            echo -e "\nNot enough space for SVD XT 1.1 download in $SVD_PATH, skipping."
            return
        fi
        echo " Success!"
        echo "Starting SVD-XT weights download..."
        download-model https://civitai.com/models/207992 $SVD_PATH/svd_xt-1.1.safetensors
        echo "Successfully downloaded SVD-XT weights!"

        verify_checksum $SVD_PATH/svd_xt-1.1.safetensors
    else
        echo "Found SVD XT 1.1 weights"
    fi
}

ensure_svd
echo "Successfully checked and downloaded SVD XT 1.1 weights!"
