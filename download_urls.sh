#!/bin/bash

DOWNLOAD_DIR="/download"

if [[ "$DOWNLOADER" != "wget" ]]; then
    DOWNLOAD_CMD=(curl)
    if [[ ! -z "$CURL_OPTIONS" ]]; then
        DOWNLOAD_CMD+=($CURL_OPTIONS)
    fi
    DOWNLOAD_CMD+=(-O)
else
    DOWNLOAD_CMD=(wget)
    if [[ ! -z "$WGET_OPTIONS" ]]; then
        DOWNLOAD_CMD+=($WGET_OPTIONS)
    fi
fi

if [[ ! -z "$1" ]]; then
    if [[ "$DEBUG" != "true" ]]; then
        cd $DOWNLOAD_DIR
    else
        echo "==== $(date +%Y-%m-%d" "%H:%M:%S) ===="
        echo "cd $DOWNLOAD_DIR"
    fi

    IFS=';' read -ra ADDR <<< "$1"
    for i in "${ADDR[@]}"; do
        if [[ "$DEBUG" != "true" ]]; then
            ${DOWNLOAD_CMD[@]} $i
        else
            echo "${DOWNLOAD_CMD[@]} $i"
        fi
    done

    if [[ "$DEBUG" != "true" ]]; then
        if [[ "$DOWNLOADER" == "wget" && "$WGET_DELETE_BACKUP_1" == "true" ]]; then
            rm ./*.1
        fi
        
        chown -R $PUID:$PGID ./*
    else
        if [[ "$DOWNLOADER" == "wget" && "$WGET_DELETE_BACKUP_1" == "true" ]]; then
            echo "rm ./*.1"
        fi
        echo "chown -R $PUID:$PGID ./*"
        echo
    fi
fi