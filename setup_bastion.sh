
---

## 2️⃣ setup_bastion.sh

```bash
#!/bin/bash
set -e

# -----------------------------
# CONFIGURATION
# -----------------------------
SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_USER="root"
ANSIBLE_PROJECT_DIR="$HOME/ansible-ovh-stack"
DOCKER_IMAGE="ansible/ansible:latest"
INVENTORY_FILE="$ANSIBLE_PROJECT_DIR/inventories/hosts.ini"
PROXMOX_API_URL="https://proxmox.example.com:8006/api2/json"
PROXMOX_USER="root@pam"
PROXMOX_PASSWORD="CHANGE_ME"
PROXMOX_REALM="pam"

# -----------------------------
# 1. Vérification Docker
# -----------------------------
if ! command -v docker &>/dev/null; then
    echo "[INFO] Installation de Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "[INFO] Reconnectez-vous pour appliquer les changements."
    exit 0
fi

# -----------------------------
# 2. Génération de la clé SSH si absente
# -----------------------------
if [ ! -f "$SSH_KEY" ]; then
    echo "[INFO] Génération d'une clé SSH ed25519..."
    ssh-keygen -t ed25519 -f "$SSH_KEY" -C "ansible-bastion" -N ""
else
    echo "[INFO] Clé SSH existante : $SSH_KEY"
fi

# -----------------------------
# 3. Déploiement de la clé sur les VMs LAN
# -----------------------------
echo "[INFO] Déploiement de la clé sur les VMs..."
while read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    HOST=$(echo "$line" | awk '{print $1}')
    IP=$(echo "$line" | awk '{print $2}')
    echo "[INFO] Copie de la clé sur $HOST ($IP)..."
    ssh-copy-id -i "$SSH_KEY.pub" "$SSH_USER@$IP" || {
        echo "[ERREUR] Impossible de copier la clé sur $HOST ($IP)"
    }
done < <(grep -E '^[a-zA-Z0-9_-]+\s+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$INVENTORY_FILE")

# -----------------------------
# 4. Lancement du conteneur Ansible
# -----------------------------
echo "[INFO] Lancement du conteneur Ansible..."
docker run --rm -it \
    -v "$ANSIBLE_PROJECT_DIR":/ansible \
    -v "$HOME/.ssh":/root/.ssh:ro \
    -w /ansible \
    $DOCKER_IMAGE \
    ansible-playbook -i inventories/hosts.ini site.yml
