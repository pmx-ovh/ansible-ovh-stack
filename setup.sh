#!/usr/bin/env bash
set -e

# === CONFIGURATION ===
ANSIBLE_DIR="/ansible"
INVENTORY="${ANSIBLE_DIR}/inventories/hosts.ini"
PLAYBOOK="${ANSIBLE_DIR}/site.yml"
DOCKER_COMPOSE="./docker/docker-compose.yml"

# === Clé SSH facultative (prioritaire via variable d'environnement) ===
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa_random}"

# Si la clé n'existe pas, on continue sans bloquer
if [ ! -f "${SSH_KEY}" ]; then
  echo "ATTENTION : la clé SSH ${SSH_KEY} n'existe pas, Ansible utilisera la clé par défaut dans group_vars/all.yml"
  SSH_KEY=""
fi


# === FONCTION USAGE ===
usage() {
  echo "Usage: $0 [phase]"
  echo "Phases disponibles: network, bastion, opnsense, haproxy, services, full"
  echo "Exemple: SSH_KEY=/path/to/key $0 network"
  exit 1
}

[ $# -eq 0 ] && usage
PHASE=$1

echo ">>> Phase: ${PHASE}"
echo ">>> Utilisation de la clé SSH: ${SSH_KEY}"

# === LANCEMENT DU PLAYBOOK ===
# Prépare les options de volume et variable pour Docker selon la clé
DOCKER_KEY_ARGS=""
if [ -n "$SSH_KEY" ]; then
  DOCKER_KEY_ARGS="-v ${SSH_KEY}:${SSH_KEY}:ro -e ANSIBLE_KEY=${SSH_KEY}"
fi

# === LANCEMENT DU PLAYBOOK ===
docker-compose -f "${DOCKER_COMPOSE}" run --rm \
  -v "${ANSIBLE_DIR}:/ansible:ro" \
  ${DOCKER_KEY_ARGS} \
  -w /ansible ansible \
  ansible-playbook "${PLAYBOOK}" -i "${INVENTORY}" --tags "${PHASE}"





