FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sshpass \
        ssh \
        git \
        curl \
        vim \
        bridge-utils \
        docker.io \
        && rm -rf /var/lib/apt/lists/*

# Create a virtualenv for Ansible
RUN python3 -m venv /opt/ansible-venv
ENV PATH="/opt/ansible-venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

# Install Ansible and Python modules
RUN pip install ansible proxmoxer

# Install Galaxy collections
RUN ansible-galaxy collection install community.general community.docker

# Set working directory
WORKDIR /ansible

# Default entrypoint
ENTRYPOINT ["/bin/bash"]
