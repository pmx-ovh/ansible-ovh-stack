FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    sshpass \
    git \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible

WORKDIR /ansible
ENTRYPOINT [ "ansible-playbook" ]
