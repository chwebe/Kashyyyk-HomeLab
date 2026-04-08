---
description: Add tasks to an existing Ansible role
---

# Add Tasks to Existing Ansible Role

This workflow guides you through adding new tasks to an existing role, following the standards in `.windsurf/rules/ansible_role.md`.

## Reference Documentation

**Read the full guidelines**: `.windsurf/rules/ansible_role.md`

Key points:
- Break large `main.yml` into smaller files using `import_tasks` or `include_tasks`
- All tasks must have descriptive `name` fields
- Variables must follow `<role_name>_variable` naming convention
- Use `when` conditionals for OS-specific tasks

## Option 1: Add to tasks/main.yml

For simple additions, edit the existing `tasks/main.yml` directly:

```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/roles/<role_name>/tasks
# Edit main.yml and add new tasks
```

## Option 2: Create Separate Task File (Recommended)

When `main.yml` becomes too large or for better organization:

### 1. Create new task file
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/roles/<role_name>/tasks
touch <task_category>.yml
```

### 2. Add tasks to the new file
```yaml
---
# Tasks for <task_category>

- name: Descriptive task name
  ansible.builtin.<module>:
    parameter: value
```

### 3. Import in main.yml

**Static import** (parsed at playbook parse time):
```yaml
- name: Include <task_category> tasks
  import_tasks: <task_category>.yml
```

**Dynamic include** (parsed at runtime, useful for conditionals):
```yaml
- name: Include <task_category> tasks conditionally
  include_tasks: <task_category>.yml
  when: <role_name>_enable_feature | bool
```

## Adding Supporting Components

### Variables

**User-overridable** (`defaults/main.yml`):
```yaml
<role_name>_new_variable: default_value
<role_name>_enable_feature: false
```

**Internal constants** (`vars/main.yml`):
```yaml
<role_name>_internal_value: "constant"
```

### Handlers

Edit `handlers/main.yml`:
```yaml
- name: restart service_name
  ansible.builtin.systemd:
    name: service_name
    state: restarted
```

### Templates

1. Create in `templates/` (must end in `.j2`):
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/roles/<role_name>/templates
touch config_file.j2
```

2. Reference in tasks:
```yaml
- name: Deploy configuration
  ansible.builtin.template:
    src: config_file.j2
    dest: /etc/app/config.conf
    mode: '0644'
  notify: restart service_name
```

### Static Files

1. Add to `files/` directory
2. Reference in tasks:
```yaml
- name: Copy static file
  ansible.builtin.copy:
    src: script.sh
    dest: /usr/local/bin/script.sh
    mode: '0755'
```

## Verification

### 1. Syntax check
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-playbook --syntax-check playbooks/<playbook_using_role>.yml
```

### 2. Lint the role
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint roles/<role_name>
```

### 3. Test in check mode
```bash
ansible-playbook playbooks/<playbook_using_role>.yml --check
```
