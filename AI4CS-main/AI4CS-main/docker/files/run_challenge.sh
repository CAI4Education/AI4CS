#!/bin/bash

CHALLENGE_DIR="/opt/ctf/challenges"
WORK_DIR="/home/hacker/ctf_workspace"
#BIN_DIR="/opt/ctf/bin"

#Controlla argomento challengeX sia stat fornito
if [ -z "$1" ]; then
    echo "Error: you need to specify a challenge. For example:"
    echo "/opt/ctf/run_challenge.sh challenge1"
    exit 1
fi

CTF_USER="hacker"

CHALLENGE_NAME="$1"
CHALLENGE_SCRIPT="$CHALLENGE_DIR/${CHALLENGE_NAME}.sh"

#Controlla che challenge esista
if [ ! -f "$CHALLENGE_SCRIPT" ]; then
    echo "Error: the challenge '$CHALLENGE_NAME' does not exist."
    exit 1
fi

#Resetta ambiente precedente
echo "[*] resetting workspace..."
rm -rf "$WORK_DIR"
mkdir "$WORK_DIR"
chown -R "$CTF_USER:$CTF_USER" "$WORK_DIR"

#Prepara nuovo ambiente rbash
echo "[*] Getting started..."

# Run challenge script **as root** but inside the workspace
echo "[*] Preparing challenge '$CHALLENGE_NAME'..."
(
    cd "$WORK_DIR"
    bash "$CHALLENGE_SCRIPT"
)

# Make sure hacker owns the output
chown -R "$CTF_USER:$CTF_USER" "$WORK_DIR"

echo "[*] Challenge Ready"