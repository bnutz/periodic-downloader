#!/bin/bash

DOWNLOAD_DIR="/download"

if [[ ! -z "$1" ]]; then
    cd $DOWNLOAD_DIR

    IFS=';' read -ra ADDR <<< "$1"
    for i in "${ADDR[@]}"; do
        if [[ "$DEBUG" != "true" ]]; then
            curl -v -O $i
        else
            echo "==== $(date +%Y-%m-%d" "%H:%M:%S) ====" >> /tmp/output.log
            echo "cd $DOWNLOAD_DIR" >> /tmp/output.log
            echo "curl -v -O $i" >> /tmp/output.log
            echo "chown -R $PUID:$PGID $DOWNLOAD_DIR/*" >> /tmp/output.log
            echo "" >> /tmp/output.log
        fi
    done
    
    chown -R $PUID:$PGID $DOWNLOAD_DIR/*
fi