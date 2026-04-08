---
description: Run Ansible lint on playbooks and roles
---

# Ansible Lint Workflow

This workflow runs `ansible-lint` to check Ansible playbooks and roles for best practices and potential issues.

## Prerequisites

Ensure `ansible-lint` is installed:
```bash
uv add ansible-lint
```

## Important Note

A symlink to `.ansible-lint` exists in the project root, so ansible-lint can be run from either:
- The project root: `/home/chweadm/projects/Kashyyyk-HomeLab/`
- The ANSIBLE directory: `/home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE/`

Both locations will load the custom rules correctly.

## Steps

### 1. Lint all playbooks and roles
Run ansible-lint on the entire ANSIBLE directory:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint
```

### 2. Lint a specific playbook
To lint a specific playbook file:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint playbooks/<playbook-name>.yml
```

### 3. Lint a specific role
To lint a specific role:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint roles/<role-name>
```

**Note**: The custom `role-task-name` rule requires running from the ANSIBLE directory.

### 4. Lint with specific rules
To run with specific rule sets or skip certain rules:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint -x <rule-id>
```

### 5. Generate a configuration file (optional)
Create `.ansible-lint` configuration file in the ANSIBLE directory to customize linting behavior:
```bash
cd /home/chweadm/projects/Kashyyyk-HomeLab/ANSIBLE
ansible-lint --generate-ignore
```

## Common Options

- `--fix`: Automatically fix certain issues
- `-v`: Verbose output
- `--nocolor`: Disable colored output
- `--exclude <path>`: Exclude specific paths from linting
- `-f <format>`: Output format (e.g., `pep8`, `codeclimate`)

## Example Output

ansible-lint will report:
- Rule violations with severity levels
- File locations and line numbers
- Suggestions for fixes
