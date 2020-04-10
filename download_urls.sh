#!/bin/bash

DOWNLOAD_DIR="/download"

CURL_CMD=(curl)
if [[ ! -z "$CURL_OPTIONS" ]]; then
    CURL_CMD+=($CURL_OPTIONS)
fi
CURL_CMD+=(-O)

if [[ ! -z "$1" ]]; then
    cd $DOWNLOAD_DIR

    IFS=';' read -ra ADDR <<< "$1"
    for i in "${ADDR[@]}"; do
        if [[ "$DEBUG" != "true" ]]; then
            ${CURL_CMD[@]} $i
        else
            echo "==== $(date +%Y-%m-%d" "%H:%M:%S) ===="
            echo "cd $DOWNLOAD_DIR"
            echo "${CURL_CMD[@]} $i"
            echo "chown -R $PUID:$PGID $DOWNLOAD_DIR/*"
            echo
        fi
    done
    
    chown -R $PUID:$PGID $DOWNLOAD_DIR/*
fi