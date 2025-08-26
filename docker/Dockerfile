# Image de base légère avec Python 3.12
FROM python:3.12-slim

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances système nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sshpass git vim curl python3-pip sudo openssh-client \
        && rm -rf /var/lib/apt/lists/*

# Installer Ansible et ansible-lint pour la vérification des playbooks
RUN pip install --no-cache-dir ansible ansible-lint

# Définir le répertoire de travail
WORKDIR /ansible

# Commande par défaut pour vérifier la version d'Ansible
CMD [ "ansible-playbook", "--version" ]
