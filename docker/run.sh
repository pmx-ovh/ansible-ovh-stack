# ./docker/run.sh
# chemin: ./docker/run.sh
#!/usr/bin/env bash
# Petit helper si besoin d’ouvrir un shell dans le container
docker run --rm -it \
  -v "$HOME/ansible-ovh-stack/ansible":/ansible \
  -v "$HOME/.ssh":/root/.ssh:ro \
  -w /ansible \
  ansible-local:latest bash
