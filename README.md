# ansible-ovh-stack

## Objectif
Déployer une infrastructure robuste et sécurisée sur Proxmox OVH avec :

- 1 IP publique OVH (1:1 MAC/IP)
- Isolation complète du LAN derrière OPNsense
- VMs créées automatiquement via Proxmox API si elles n’existent pas
- Configuration automatique des bridges WAN/LAN
- Déploiement de services web sur VM dédiée : HAProxy → Traefik → Docker/Portainer
- Bastion Docker pour exécuter Ansible et gérer les VMs

## Architecture réseau

Internet
   │
   │ IP publique OVH
   ▼
Proxmox Host (vmbr0 WAN)
   │
   ├─ vmbr1 (LAN interne)
   │    │
   │    ├─ Bastion VM (Docker + Ansible)
   │    │
   │    ├─ OPNsense VM (NAT + Firewall)
   │    │
   │    ├─ HAProxy VM (flux web entrants)
   │    │
   │    └─ Services VM (Traefik + Portainer + conteneurs)

- vmbr0 : WAN, IP publique OVH, existe par défaut sur Proxmox
- vmbr1 : LAN interne, créé automatiquement si absent
- Toutes les VMs LAN passent par OPNsense pour NAT et firewall

## Pré-requis

1. Proxmox Host : accès SSH root, IP publique OVH configurée
2. Templates ISO/VM : Debian pour Bastion et Services, OPNsense pour firewall
3. Bastion : Debian/Ubuntu avec Docker et Ansible (exécuté depuis Docker)
4. Clé SSH : générée sur bastion et déployée automatiquement sur les VMs LAN

## Installation et déploiement

1. Se connecter au bastion :
```
ssh root@IP_PUBLIC_BASTION
```

2. Cloner le projet :
```
git clone git@github.com:ton-repo/ansible-ovh-stack.git
cd ansible-ovh-stack
```

3. Exécuter le script de setup complet :
```
chmod +x setup_bastion.sh
./setup_bastion.sh
```

Le script :
- Installe Docker si nécessaire
- Génère la clé SSH sur le bastion
- Déploie la clé SSH sur toutes les VMs
- Vérifie et crée les bridges WAN/LAN
- Crée automatiquement les VMs via Proxmox API si elles n’existent pas
- Exécute le playbook Ansible pour configurer OPNsense, HAProxy, Traefik et Docker/Portainer

## Commandes utiles

- Exécuter un playbook Ansible spécifique :
```
docker run --rm -it \
  -v "$PWD":/ansible \
  -v "$HOME/.ssh":/root/.ssh:ro \
  -w /ansible \
  ansible/ansible:latest \
  ansible-playbook -i inventories/hosts.ini site.yml
```

- Tunnel SSH pour Portainer :
```
ssh -L 9000:192.168.100.12:9000 root@IP_PUBLIC_BASTION
```

- Tunnel SSH pour Traefik Dashboard :
```
ssh -L 8080:192.168.100.12:8080 root@IP_PUBLIC_BASTION
```

- Vérifier connectivité LAN :
```
ssh root@192.168.100.11
```

## Structure du projet

```
ansible-ovh-stack/
├── inventories/
│   └── hosts.ini          # IP ou noms des VMs
├── group_vars/
│   └── all.yml            # Variables globales
├── requirements.yml       # Rôles externes (si nécessaires)
├── site.yml               # Playbook principal
├── roles/
│   ├── proxmox-host/
│   │   ├── tasks/main.yml         # Bridges + création VMs via API
│   │   ├── templates/interfaces.j2
│   │   └── handlers/main.yml
│   ├── opnsense-vm/
│   │   ├── tasks/main.yml         # NAT + Firewall
│   │   └── templates/rules.v4.j2
│   └── services-vm/
│       ├── tasks/main.yml         # Docker + Traefik + Portainer
│       ├── tasks/haproxy.yml      # HAProxy VM
│       ├── templates/docker-compose.yml.j2
│       └── templates/haproxy.cfg.j2
├── setup_bastion.sh                # Script pour Docker + Ansible + clés + playbook
└── README.md
```

## Notes

- Idempotence : tout le projet peut être relancé sans casser les VMs existantes
- Sécurité : LAN isolé derrière OPNsense, flux entrants filtrés par HAProxy
- Extensible : ajouter de nouvelles VMs/services en modifiant `vm_list` dans `proxmox-host`
- Robustesse : création automatique des bridges et VMs, déploiement des services web sur VM dédiée
