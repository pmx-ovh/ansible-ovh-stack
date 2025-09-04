#!/usr/bin/env bash
set -e

# =========================================
# Variables principales
# =========================================
ANSIBLE_DIR="/ansible"
INVENTORY="${ANSIBLE_DIR}/inventories/hosts.ini"
PLAYBOOK="${ANSIBLE_DIR}/site.yml"
DOCKER_COMPOSE="./docker/docker-compose.yml"

# 🔹 Clés SSH via variables d'environnement
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa_wbx}"
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-$HOME/.ssh/id_rsa_wbx.pub}"

# =========================================
# Usage
# =========================================
usage() {
  echo "Usage: $0 [phase]"
  echo "Phases: install, network, provision, opnsense, bastion, haproxy, services, templates, full"
  exit 1
}

[ $# -eq 0 ] && usage
PHASE=$1
echo ">>> Phase: ${PHASE}"
echo ">>> Clé SSH locale utilisée : ${SSH_KEY_PATH}"

# =========================================
# Arguments Docker
# =========================================
DOCKER_KEY_ARGS="-v $ANSIBLE_DIR:$ANSIBLE_DIR:rw"
DOCKER_KEY_ARGS+=" -v $(dirname $SSH_KEY_PATH):/root/.ssh:ro -e SSH_KEY_PATH=/root/.ssh/$(basename $SSH_KEY_PATH)"
DOCKER_KEY_ARGS+=" -v docker_proxmox_templates:/tmp/proxmox_templates:rw"  # volume persistant pour templates
DOCKER_KEY_ARGS+=" -e SSH_PUBLIC_KEY_PATH=/root/.ssh/$(basename $SSH_PUBLIC_KEY_PATH)"

DOCKER_CMD="docker-compose -f ${DOCKER_COMPOSE} run --rm $DOCKER_KEY_ARGS -w ${ANSIBLE_DIR} ansible"

# =========================================
# Détection ProxyJump si nécessaire
# =========================================
JUMP_ARGS=""
if [[ "${PHASE}" != "network" && "${PHASE}" != "install" && "${PHASE}" != "provision" ]]; then
  if [[ -f "${INVENTORY}" ]] && grep -Eq "ansible_host=(192\.168|10\.)" "${INVENTORY}"; then
    JUMP_ARGS="-e ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump=root@192.99.32.41'"
  fi
fi
echo ">>> DOCKER_CMD: ${DOCKER_CMD}"
# =========================================
# Lancer Ansible selon la phase
# =========================================
case "${PHASE}" in
  version)
    echo "[INFO] Vérification d’Ansible et des collections..."
    ${DOCKER_CMD} ansible --version
    ;;
  full)
    echo "[INFO] Exécution du playbook complet..."
    ${DOCKER_CMD} ansible-playbook "${PLAYBOOK}" -i "${INVENTORY}" ${JUMP_ARGS}
    ;;
  *)
    echo "[INFO] Exécution de la phase : ${PHASE}"
    ${DOCKER_CMD} ansible-playbook "${PLAYBOOK}" -i "${INVENTORY}" ${JUMP_ARGS} --tags "${PHASE}"
    ;;
esac
