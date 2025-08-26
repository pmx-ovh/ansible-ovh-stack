# ansible-ovh-stack

Infrastructure as Code pour déployer un environnement complet sur **Proxmox** avec une **IP publique OVH unique (1:1 MAC/IP)**, automatisé via **Ansible**, et exécuté depuis **Docker** sans installer Ansible localement.

---

## 🌐 Architecture réseau et flux

```
Internet (IP OVH unique)
   ↓
Proxmox host
   ↓ vmbr1 (bridge WAN)
VM OPNsense (firewall/NAT, règles)
   ↓ vmbr2 (bridge LAN)
VM Services
   ├─ HAProxy (reverse proxy VM-level)
   │    ↓ distribue vers VMs / services
   └─ Traefik (reverse proxy container-level)
        ↓ distribue vers conteneurs Docker
             └─ Portainer / autres services
```

### Points clés

1. **OPNsense**  
   - Firewall et NAT pour le LAN interne  
   - Filtrage du trafic entrant/sortant  

2. **HAProxy**  
   - Point d’entrée unique sur la VM services  
   - Routage vers plusieurs VMs/services selon nom de domaine ou port  

3. **Traefik**  
   - À l’intérieur de la VM services  
   - Routage vers les conteneurs Docker via labels  
   - Gestion automatique SSL/TLS via Let’s Encrypt  

4. **Docker / Portainer**  
   - Héberge tous les services internes et stacks  
   - Traefik assure la distribution vers les conteneurs  

---

## 📦 Structure du projet

```
ansible-ovh-stack/
├── ansible/                  # Playbooks Ansible
│   ├── inventories/hosts.ini  # Inventaire des hôtes
│   ├── group_vars/all.yml     # Variables globales
│   ├── roles/                 # Rôles pour Proxmox, OPNsense, Services
│   ├── requirements.yml       # Collections Ansible
│   └── site.yml               # Playbook principal
├── docker/                    # Docker pour exécuter Ansible
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── run.sh
├── commands.md                # Commandes utiles
└── README.md
```

---

## ⚙️ Prérequis

- macOS ou Linux avec **Docker** et **Docker Compose v2**  
- Accès root SSH à Proxmox  
- **IP publique OVH 1:1**  
- Compte GitHub pour versionner le projet  

---

## 🚀 Exécution des playbooks via Docker

### 1️⃣ Construire l’image Docker Ansible

```bash
cd docker
docker compose build
```

### 2️⃣ Lancer le playbook principal

```bash
./run.sh
```

- Monte le répertoire `ansible/` dans le conteneur  
- Monte `~/.ssh` pour utiliser les clés SSH  
- Exécute `ansible-playbook -i inventories/hosts.ini site.yml`  

### 3️⃣ Vérifier la connexion aux hôtes

```bash
docker compose run --rm ansible ansible -i inventories/hosts.ini all -m ping
```

### 4️⃣ Exécuter des commandes ad-hoc

```bash
docker compose run --rm --entrypoint bash ansible
# Puis à l’intérieur du conteneur :
ansible-playbook -i inventories/hosts.ini site.yml
```

---

## 🔑 Gestion des clés SSH pour GitHub

1. Générer une clé SSH dédiée :

```bash
ssh-keygen -t ed25519 -C "pmx.ovh@proton.me" -f ~/.ssh/pmx-ovh_id_ed25519
```

2. Ajouter la clé à l’agent SSH :

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/pmx-ovh_id_ed25519
```

3. Configurer l’alias SSH :

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
# Doit afficher : Hi <username>! You've successfully authenticated...
```

5. Ajouter le remote Git via l’alias :

```bash
git remote add origin git@pmx-ovh:pmx-ovh/ansible-ovh-stack.git
```

---

## 🧰 Workflow Git

```bash
git add .
git commit -m "Initial commit: Ansible OVH stack"
git push -u origin main
```

- L’alias SSH assure que le dépôt utilise la bonne clé et le bon compte GitHub.  

---

## 🔧 Commandes utiles

- Voir `commands.md` pour :  
  - Tester l’inventaire Ansible  
  - Ping des hôtes  
  - Installer les collections  
  - Logs détaillés / debug  
  - Nettoyage des containers Docker  

---

## 🔐 Sécurité

- Ne pas committer de mots de passe ou secrets dans `group_vars/all.yml`.  
- Variables sensibles → passer via `--extra-vars`.  
- Permissions des fichiers SSH : `chmod 600 ~/.ssh/pmx-ovh_id_ed25519`.  

---

## 📄 Déploiement

1. Configurer `hosts.ini` et `group_vars/all.yml` avec tes IP OVH et LAN.  
2. Lancer depuis Docker :

```bash
cd docker
./run.sh
```

3. Vérifier via Proxmox, Portainer et Ansible.  
4. Configurer le DNS de ton domaine vers l’IP OVH pour les services exposés.  

---

## 📚 Liens utiles

- [Proxmox Documentation](https://pve.proxmox.com/wiki/Main_Page)  
- [OPNsense Documentation](https://docs.opnsense.org/)  
- [Ansible Documentation](https://docs.ansible.com/)  
- [Docker Documentation](https://docs.docker.com/)  

---

## ✅ Résultat

- Une seule VM frontale reçoit l’IP OVH et gère tout le trafic entrant.  
- OPNsense sécurise le LAN et applique le NAT sortant.  
- HAProxy distribue le trafic vers VM services ou Traefik.  
- Traefik distribue le trafic vers les conteneurs Docker.  
- Portainer accessible pour gérer les stacks Docker.  
- Flux sécurisé et respectueux des contraintes OVH 1:1 IP.
