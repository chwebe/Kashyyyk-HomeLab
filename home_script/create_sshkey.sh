mkdir -p keys
ssh-keygen -t ed25519 -C "chwebe" -f keys/id_ed25519

# copy key to remote host
ssh-copy-id -i keys/id_ed25519.pub chweadm@192.168.1.13
ssh-copy-id -i keys/id_ed25519.pub chweadm@192.168.1.47

#ssh-copy-id -i keys/id_ed25519.pub chweadm@192.168.1.47