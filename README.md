# ./README.md
# chemin: ./README.md
# ====================================================================================
# Ansible OVH Proxmox Stack (vmbr0/vmbr1/vmbr2) — OPNsense + HAProxy + Traefik
# ====================================================================================

## Résumé
- **Contrainte OVH** : MAC/IP 1:1, pas de failover → **Proxmox seul sur WAN (vmbr0)**.
- **Réseaux** :
  - **vmbr0 (WAN)** : IP publique OVH affectée au **Proxmox uniquement**.
  - **vmbr1 (LAN1)** : lien **Proxmox ↔ OPNsense** (management + passerelle LAN).
  - **vmbr2 (DMZ)** : lien **OPNsense ↔ HAProxy/Services** (reverse-proxy + apps).
- **Flux** :
  - Sortant LAN/DMZ → **NAT via OPNsense**.
  - Entrant HTTP/HTTPS → **DNAT/port-forward OPNsense → HAProxy → Traefik → services**.
  - Accès d’admin distant → **VPN WireGuard OPNsense**.

## Schéma (ASCII)
Proxmox (vmbr0/WAN)
  │  (IP Publique OVH)
  └─ vmbr1 (10.0.1.0/24) ── OPNsense (LAN:10.0.1.1 , DMZ:10.0.2.1) ── vmbr2 (10.0.2.0/24)
                                                  │
                                              HAProxy (10.0.2.10) → Traefik/Portainer & services (10.0.2.11+)

## Déploiement en 2 phases
1. **Phase 1** : configure Proxmox (vmbr1/vmbr2 si absents), crée/paramètre VMs (bastion, fw1, haproxy, srv1).
2. **Phase 2** : configure OPNsense (interfaces, NAT, FW, WireGuard), installe HAProxy, et Services (Docker, Traefik, Portainer).

## Prérequis
- Accès SSH **root** au Proxmox (clé déjà installée).
- Templates Proxmox existants :
  - `debian-11-standard` (template cloneable)
  - `opnsense-template` (template cloneable)
- DNS côté domaine pointant vers l’IP OVH publique (si exposition web).
- Variables à renseigner dans `ansible/group_vars/all.yml` (API Proxmox & OPNsense).

## Utilisation rapide
```bash
./setup.sh build
./setup.sh phase1
# → configure ton client WireGuard avec le fichier généré (voir notes du rôle opnsense)
./setup.sh phase2

Sécurité
Aucun service WAN exposé depuis Proxmox (sauf SSH si nécessaire et restreint).
NAT et filtrage côté OPNsense uniquement.
VPN obligatoire pour l’admin interne.
HAProxy en DMZ, Traefik côté services (mTLS/ACME possibles).



# Étape 1 : Réseau + Bastion
./setup.sh network
./setup.sh bastion

# Tu te connectes via VPN (auto-généré par OPNsense)
./setup.sh opnsense

# Étape 2 : HAProxy + Services
./setup.sh haproxy
./setup.sh services
