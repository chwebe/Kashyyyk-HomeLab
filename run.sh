#!/bin/sh
sudo docker compose up -d

sudo docker exec -it ansible ansible-playbook playbooks/install_coruscant.yml -vv
#sudo docker exec -it ansible ansible-playbook playbooks/corrusant.yml --tags check_ports -vv
#docker exec -it ansible myhost -m command -a "whoami" -vvvv

sudo docker compose down