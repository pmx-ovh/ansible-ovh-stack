# 📖 Commandes Ansible-OVH-Stack (Production)

# 0️⃣ Pré-requis et vérifications
docker --version
docker-compose --version
ls -ld ansible docker
ls -l setup.sh

# 1️⃣ Construire l'image Docker Ansible
docker build -t docker-ansible:latest ./docker

# 2️⃣ Vérifier le volume Ansible
docker run --rm -it --entrypoint /bin/bash -v $(pwd)/ansible:/ansible -w /ansible docker-ansible:latest -c "ls -l"

# 3️⃣ Installer les collections Ansible nécessaires
./setup.sh install

# 4️⃣ Test clé SSH et connectivité avant VPN
ssh -i ~/.ssh/id_rsa_wbx root@192.99.32.41
docker-compose -f docker/docker-compose.yml run --rm ansible ansible proxmox_group -i ansible/inventories/hosts.ini -m ping

# 5️⃣ Étapes avant VPN
./setup.sh network
./setup.sh bastion
ssh -J root@192.99.32.41 root@192.168.1.10
docker-compose -f docker/docker-compose.yml run --rm ansible ansible bastion_group -i ansible/inventories/hosts.ini -m ping

# 6️⃣ Étapes de configuration VPN
./setup.sh opnsense
docker-compose -f docker/docker-compose.yml run --rm ansible ansible opnsense_group -i ansible/inventories/hosts.ini -m ping
docker-compose -f docker/docker-compose.yml run --rm ansible ansible haproxy_group -i ansible/inventories/hosts.ini -m ping
docker-compose -f docker/docker-compose.yml run --rm ansible ansible services_group -i ansible/inventories/hosts.ini -m ping

# 7️⃣ Étapes après VPN
./setup.sh haproxy
./setup.sh services
docker-compose -f docker/docker-compose.yml run --rm ansible ansible all -i ansible/inventories/hosts.ini -m ping

# 8️⃣ Exemples d’utilisation de setup.sh avec différents tags
# - Appliquer uniquement la configuration réseau
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh network

# - Déployer uniquement le bastion
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh bastion

# - Déployer uniquement OPNsense et configurer le VPN
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh opnsense

# - Configurer uniquement HAProxy
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh haproxy

# - Déployer uniquement les services Docker
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh services

# - Tout faire en une seule commande
SSH_KEY=~/.ssh/id_rsa_wbx ./setup.sh full

# 🔄 Notes de prod
# - La clé SSH prioritaire peut être passée via variable d'environnement :
#   SSH_KEY=/path/to/key ./setup.sh network
# - Les tests ping avant/après VPN valident la connectivité réseau.
# - Le bastion doit être configuré avant d’accéder aux hôtes internes.
# - Tous les chemins sont relatifs au projet ansible-ovh-stack.
