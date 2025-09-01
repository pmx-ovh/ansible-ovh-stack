ansible-ovh-stack/
├── ansible.cfg
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       └── all.yml        # Configuration globale
├── roles/
│   ├── proxmox-host/      # Configuration réseau du host Proxmox
│   │   └── templates/
│   │       └── interfaces.j2
│   ├── proxmox-vm/        # Provisionnement des VMs (cloud-init)
│   │   ├── defaults/main.yml
│   │   └── tasks/main.yml
│   ├── bastion/           # Sécurisation bastion (Fail2ban, UFW, SSH)
│   ├── opnsense/          # Firewall et VPN
│   ├── haproxy/           # Reverse proxy / load balancer
│   └── docker/            # Stack Docker (Traefik, Portainer, etc.)
├── playbooks/
│   ├── setup.yml
│   ├── deploy-bastion.yml
│   └── deploy-services.yml
├── setup.sh               # Script de lancement
└── README.md
