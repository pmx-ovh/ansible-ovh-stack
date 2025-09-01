# === ansible-ovh-stack/commands.md ===
# 📖 Commandes Ansible-OVH-Stack (Production)



export SSH_KEY_PATH=$HOME/.ssh/id_rsa_wbx
export SSH_PUBLIC_KEY_PATH=$HOME/.ssh/id_rsa_wbx.pub

# Build le conteneur Ansible
docker-compose -f docker/docker-compose.yml build


# 1) Vérification Ansible + collections
./setup.sh install
./setup.sh templates

# 2) Upload / Vérification des templates
./setup.sh provision --tags templates

# 3) Créer les VMs clonées
./setup.sh provision --tags provision

# 4) Déployer Bastion
./setup.sh bastion

# 5) Déployer OPNsense + VPN
./setup.sh opnsense

# 6) Déployer HAProxy
./setup.sh haproxy

# 7) Déployer services Docker (Traefik, Portainer, Wordpress…)
./setup.sh services

# 8) Tout en une seule commande
./setup.sh full
