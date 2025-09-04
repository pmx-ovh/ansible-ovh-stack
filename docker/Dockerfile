# === Dockerfile pour Ansible-OVH-Stack ===
FROM python:3.11-slim

# === Install system dependencies ===
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        sshpass \
        openssh-client \
        git \
        curl \
        vim \
        bridge-utils \
        docker.io \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# === Create Python virtual environment for Ansible ===
RUN python3 -m venv /opt/ansible-venv

# Upgrade pip and install Ansible + proxmoxer in venv
RUN /opt/ansible-venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/ansible-venv/bin/pip install --no-cache-dir "ansible>=8.6.1" proxmoxer urllib3 certifi requests

# === Add venv to PATH for all sessions ===
ENV PATH="/opt/ansible-venv/bin:${PATH}"

# === Install common Ansible collections ===
RUN ansible-galaxy collection install community.general community.docker community.proxmox || true

# === Working directory ===
WORKDIR /ansible

# === Default command ===
CMD ["/bin/bash"]
