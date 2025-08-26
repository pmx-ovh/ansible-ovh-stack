#!/bin/bash
set -e

cd "$(dirname "$0")"

# Construire l'image
docker compose build

# Exécuter le playbook ansible
docker compose run --rm ansible
