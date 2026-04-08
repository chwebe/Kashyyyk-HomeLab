---
description: Create a new Ansible role following project standards
---

# Create New Ansible Role

This workflow creates a new Ansible role following the standards defined in `.windsurf/rules/ansible_role.md`.

## Reference Documentation

**Read the full guidelines**: `.windsurf/rules/ansible_role.md`

Key points:
- Standard directory structure with `tasks/`, `handlers/`, `templates/`, `files/`, `vars/`, `defaults/`, `meta/`
- All variables must start with `<role_name>_`
- All tasks must have descriptive `name` fields
- Use `defaults/` for user-overridable values, `vars/` for constants

## Quick Start

Create a complete role structure:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/roles && \
mkdir -p <role_name>/{tasks,handlers,templates,files,vars,defaults,meta} && \
echo "---" > <role_name>/tasks/main.yml && \
echo "---" > <role_name>/handlers/main.yml && \
echo "---" > <role_name>/vars/main.yml && \
echo "---" > <role_name>/defaults/main.yml && \
echo "---" > <role_name>/meta/main.yml
```

## Steps

### 1. Create directory structure
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/roles
mkdir -p <role_name>/{tasks,handlers,templates,files,vars,defaults,meta}
```

### 2. Initialize main files
Create empty YAML files for each component:
```bash
cd <role_name>
for dir in tasks handlers vars defaults meta; do echo "---" > $dir/main.yml; done
```

### 3. Edit tasks/main.yml
Add your role's main logic with descriptive task names.

### 4. Edit defaults/main.yml
Add user-overridable variables (prefix with `<role_name>_`).

### 5. Edit vars/main.yml (if needed)
Add internal constants (prefix with `<role_name>_`).

### 6. Edit meta/main.yml
Define role dependencies and Galaxy metadata.

### 7. Add handlers/main.yml (if needed)
Define handlers for service restarts or reloads.

### 8. Add templates/ and files/ (if needed)
- Templates: Jinja2 files ending in `.j2`
- Files: Static assets copied as-is

## Verification

```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
tree roles/<role_name>
ansible-lint roles/<role_name>
```
