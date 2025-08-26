#!/bin/bash
# Script pour exécuter les playbooks Ansible via Docker
# Il supporte l'ajout de paramètres supplémentaires (tags, extra-vars...)

# Construire l'image si nécessaire
docker compose build

# Lancer le playbook principal
docker compose run --rm ansible ansible-playbook -i inventories/hosts.ini site.yml "$@"
