#!/bin/sh
PLAYBOOK="${1:-main.yml}"

docker compose up -d --build --force-recreate

docker exec -i ansible ansible-playbook "playbooks/${PLAYBOOK}" -vv
#docker exec -it ansible ansible-playbook playbooks/corrusant.yml --tags check_ports -vv
#docker exec -it ansible myhost -m command -a "whoami" -vvvv

docker compose down