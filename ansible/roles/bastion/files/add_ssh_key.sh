#!/bin/sh
SSH_KEY="$1"
mkdir -p /root/.ssh
echo "$SSH_KEY" >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
