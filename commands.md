# commands.md

Guide rapide pour piloter **Ansible via Docker** (aucune installation Ansible locale requise).

## 📦 Pré-requis
- Docker + Docker Compose v2 installés localement.
- Arborescence du projet :
  ```
  ansible-ovh-stack/
  ├── ansible/          # playbooks, inventaire, rôles
  └── docker/           # Dockerfile / docker-compose.yml / run.sh
  ```

---

## 🚀 Lancement du setup depuis le bastion
```bash
docker build -t ansible-local:latest .

docker run --rm -it   -v "$HOME/ansible-ovh-stack/ansible":/ansible   -v "$HOME/.ssh":/root/.ssh:ro   -w /ansible   ansible-local:latest -i inventories/hosts.ini site.yml
```

## 🚀 Lancement rapide (depuis le dossier `docker/`)
```bash
cd docker
docker compose build
./run.sh
```

---

## ▶️ Exécuter le playbook manuellement (sans script)
```bash
cd docker
docker compose run --rm ansible
```
> L’entrypoint du service `ansible` est déjà `ansible-playbook -i inventories/hosts.ini site.yml`.

### Exemples utiles
- Mode check (dry-run) + verbose :
  ```bash
  cd docker
  docker compose run --rm ansible --check -vv
  ```

- Passer des variables à la volée :
  ```bash
  cd docker
  docker compose run --rm ansible \
    --extra-vars 'proxmox_api_password=MY_SECRET ovh_public_ip=51.68.x.y'
  ```

---

## 🧰 Commandes Ansible courantes (dans le container)

> Pour lancer **d’autres** commandes Ansible que `ansible-playbook`, on **override l’entrypoint**.

- **Ping** des hôtes (module `ping`) :
  ```bash
  cd docker
  docker compose run --rm --entrypoint ansible ansible \
    -i inventories/hosts.ini all -m ping
  ```

- **Installer/mettre à jour** les collections :
  ```bash
  cd docker
  docker compose run --rm --entrypoint ansible-galaxy ansible \
    collection install -r requirements.yml
  ```

- **Shell** interactif à l’intérieur du conteneur :
  ```bash
  cd docker
  docker compose run --rm --entrypoint bash ansible
  ```

---

## 🔍 Débogage & vérifications

- Vérifier que l’inventaire est vu :
  ```bash
  cd docker
  docker compose run --rm --entrypoint ansible-inventory ansible --list
  ```

- Lancer un playbook avec logs détaillés :
  ```bash
  cd docker
  docker compose run --rm ansible -vvv
  ```

- Tester la connexion SSH au Proxmox **depuis ta machine** :
  ```bash
  ssh root@<IP_PROXMOX>
  ```

- Vérifier depuis Ansible (ad-hoc) une commande sur Proxmox (ex: iptables) :
  ```bash
  cd docker
  docker compose run --rm --entrypoint ansible ansible \
    -i inventories/hosts.ini proxmox \
    -m shell -a "iptables -t nat -S"
  ```

---

## 🧹 Nettoyage

- Supprimer le conteneur éphémère (au cas où il resterait) :
  ```bash
  docker ps -a
  docker rm <container_id>
  ```

- Supprimer l’image locale buildée par Compose :
  ```bash
  cd docker
  docker compose down --rmi local
  ```

---

## 🔐 Notes sécurité

- Les variables sensibles (ex: `proxmox_api_password`) peuvent être passées via `--extra-vars` ou variables d’environnement au moment de l’exécution.
- Pense à **ne pas** commiter de secrets en clair dans `group_vars/all.yml`.

---
