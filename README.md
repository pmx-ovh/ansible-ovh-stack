# ansible-ovh-stack

Infrastructure as Code pour déployer un environnement complet sur Proxmox avec une **contrainte OVH 1:1 IP**, automatisé via **Ansible** et exécutable depuis **Docker**, sans installer Ansible localement.

---

## 🌐 Architecture

```
Proxmox Host
├─ vmbr0 (WAN, internet)
├─ vmbr1 (LAN interne → OPNsense WAN)
├─ vmbr2 (LAN interne → services)

VM OPNsense
├─ net0 → vmbr1 (WAN)
├─ net1 → vmbr2 (LAN)
└─ NAT LAN → WAN

VM Services
├─ net0 → vmbr2 (LAN interne)
├─ Docker
│  ├─ HAProxy
│  ├─ Traefik
│  └─ Portainer
```

- Toutes les machines du LAN sortent sur Internet via l’IP OVH unique.  
- Les machines du LAN ne sont pas joignables depuis le réseau public.

---

## 📦 Structure du projet

```
ansible-ovh-stack/
├── ansible/                   # Playbooks Ansible
│   ├── inventories/
│   ├── group_vars/
│   ├── roles/
│   ├── requirements.yml
│   └── site.yml
├── docker/                    # Conteneur Docker pour Ansible
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── run.sh
├── commands.md                # Commandes utiles
└── README.md
```

---

## ⚙️ Pré-requis

- macOS ou Linux avec **Docker** et **Docker Compose v2**  
- Accès root SSH à Proxmox  
- IP publique OVH 1:1  
- Compte GitHub pour versionner le projet  

---

## 🚀 Lancer les playbooks depuis Docker

### 1️⃣ Construire l’image Docker contenant Ansible

```bash
cd docker
docker compose build
```

> Cette étape installe Ansible et toutes ses dépendances dans un conteneur Docker.

---

### 2️⃣ Lancer le playbook principal

```bash
./run.sh
```

Le script exécute :

```bash
ansible-playbook -i inventories/hosts.ini site.yml
```

dans un conteneur Docker, avec :

- le dossier `ansible/` monté comme volume
- les clés SSH disponibles via `~/.ssh`
- la configuration réseau et le NAT automatiquement appliqués sur Proxmox

---

### 3️⃣ Vérifier le bon déroulement

- Depuis la machine locale, tu peux tester la connexion aux hôtes Proxmox :

```bash
docker compose run --rm ansible ansible -i inventories/hosts.ini all -m ping
```

- Tu peux aussi exécuter des commandes ad-hoc dans le conteneur Docker :

```bash
docker compose run --rm --entrypoint bash ansible
# puis dans le conteneur :
ansible-playbook -i inventories/hosts.ini site.yml
```

---

## 🔧 Gestion des clés SSH pour GitHub

1. Générer une clé SSH dédiée pour le projet :

```bash
ssh-keygen -t ed25519 -C "pmx.ovh@proton.me" -f ~/.ssh/pmx-ovh_id_ed25519
```

2. Ajouter la clé à l’agent SSH :

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/pmx-ovh_id_ed25519
```

3. Configurer l’alias SSH dans `~/.ssh/config` :

```text
Host pmx-ovh
    HostName github.com
    User git
    IdentityFile ~/.ssh/pmx-ovh_id_ed25519
    IdentitiesOnly yes
```

4. Tester la connexion :

```bash
ssh -T pmx-ovh
```

5. Ajouter le remote Git via l’alias :

```bash
cd /Users/f/Desktop/ismo/ansible-ovh-stack/
git remote add origin git@pmx-ovh:pmx-ovh/ansible-ovh-stack.git
```

---

## 🧰 Workflow Git

```bash
git add .
git commit -m "Initial commit: Ansible OVH stack"
git push -u origin main
```

> L’alias SSH garantit que chaque projet utilise la bonne clé et le bon compte GitHub.

---

## 📄 Commandes utiles

Voir `commands.md` pour :  

- Tester l’inventaire Ansible
- Ping des hôtes
- Installer les collections Ansible
- Logs détaillés / debug
- Nettoyage des containers Docker

---

## 🔐 Sécurité

- Ne pas committer les mots de passe ou secrets en clair dans `group_vars/all.yml`.  
- Les variables sensibles doivent passer via `--extra-vars`.  
- Permissions des fichiers SSH : `chmod 600 ~/.ssh/pmx-ovh_id_ed25519`.  

---

## 📚 Liens utiles

- [Proxmox Documentation](https://pve.proxmox.com/wiki/Main_Page)  
- [OPNsense Documentation](https://docs.opnsense.org/)  
- [Ansible Documentation](https://docs.ansible.com/)  
- [Docker Documentation](https://docs.docker.com/)
