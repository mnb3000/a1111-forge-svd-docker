verify_checksum() {
    local FILENAME="$(basename $1)"

    echo "Verifying checksum for $FILENAME..."

    if [ ! -f $1 ]; then
        echo "$FILENAME does not exist."
        return 0
    fi

    local CHECKSUM="$(shasum -a 256 $1 | awk '{ print $1 }')"
    local CHECKSUM_FILENAME="$FILENAME.sha256"
    local EXPECTED_CHECKSUM="$(cat ./checksums/$CHECKSUM_FILENAME)"

    if [[ $CHECKSUM = $EXPECTED_CHECKSUM ]]; then
        echo "Checksum valid!"
        return 0
    fi
    echo "Checksum not valid! Removing file, restart container to retry..."
    rm -f $1
    return 1
}
