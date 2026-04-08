---
trigger: always_on
description: Guidelines and structure for Ansible role development
---

# Ansible Role Development Guidelines

This document defines the standards for creating, organizing, and using Ansible roles in this workspace. Cascade should follow these guidelines when generating or modifying Ansible code.

## 1. Role Directory Structure

A standard role MUST follow this hierarchy:

```text
roles/
    <role_name>/          # Name of the role (e.g., common, webserver)
        tasks/
            main.yml      # Main list of tasks to execute
        handlers/
            main.yml      # Handlers (triggered by notify)
        templates/
            ntp.conf.j2   # Jinja2 templates (end in .j2)
        files/
            bar.txt       # Static files for copy module
            foo.sh        # Scripts
        vars/
            main.yml      # High precedence variables (internal/constants)
        defaults/
            main.yml      # Low precedence variables (default overridable values)
        meta/
            main.yml      # Role dependencies and metadata
```

## 2. Component Responsibilities

### Tasks (`tasks/main.yml`)
- Contains the primary logic for the role.
- **Best Practice**: If `main.yml` becomes too large, break tasks into smaller files and import them using `import_tasks` or `include_tasks`.
- **Naming Convention**: All tasks MUST have a descriptive `name` following this format:
  - **Pattern**: `ROLE_NAME | Description`
  - **ROLE_NAME**: Uppercase version of the role name with underscores replaced by spaces
  - **Description**: Clear description starting with uppercase letter
  - **Examples**:
    - Role `dns_stack`: `DNS STACK | Deploy configuration`
    - Role `admin_packages`: `ADMIN PACKAGES | Install essential tools`
    - Role `common`: `COMMON | Update system packages`
  - **Enforcement**: This is enforced by the custom `role-task-name` ansible-lint rule

### Handlers (`handlers/main.yml`)
- Contains tasks that are triggered by other tasks (e.g., restarting a service after a config change).
- Imported into the parent play automatically.
- **Naming Convention**: Handler names MUST follow the same pattern as tasks:
  - **Pattern**: `ROLE_NAME | Description`
  - **Example**: `DNS STACK | Restart` instead of `Restart dns stack`
  - **Enforcement**: This is enforced by the custom `role-task-name` ansible-lint rule

### Variables
- **Defaults (`defaults/main.yml`)**: 
  - Lowest precedence.
  - Use this for values that users of the role are expected to override.
  - *Example*: Default port numbers, installation paths.
- **Vars (`vars/main.yml`)**: 
  - High precedence.
  - Use this for variables that should generally remain constant or are internal to the role implementation.
  - *Example*: Package names specific to an OS version.
- Variable in role should starts with the name of the role followed by an underscore.
  - *Example*: `common_package_name`

### Files & Templates
- **Files (`files/`)**: Static assets transferred as-is.
- **Templates (`templates/`)**: Dynamic configuration files processed via Jinja2.

### Metadata (`meta/main.yml`)
- Defines role dependencies (roles that must run before this one).
- Contains Galaxy metadata (author, license, platforms).

## 3. Using Roles in Playbooks

### Static vs Dynamic Reuse

#### 1. Standard Role List (Static)
The classic way to apply roles to hosts. Dependencies in `meta/main.yml` run first.

```yaml
- hosts: webservers
  roles:
    - common
    - role: webservers
      vars:
        http_port: 8080
```

#### 2. Import Role (Static)
Parses the role at playbook parse time.

```yaml
- hosts: webservers
  tasks:
    - import_role:
        name: common
```

#### 3. Include Role (Dynamic)
Parses the role at runtime. useful for loops or conditionals.

```yaml
- hosts: webservers
  tasks:
    - include_role:
        name: common
      when: "ansible_os_family == 'RedHat'"
```

## 4. Execution Order
1. **Pre_tasks** defined in the play.
2. **Handlers** triggered by pre_tasks.
3. **Roles** listed in `roles:` (and their dependencies).
4. **Tasks** defined in the play.
5. **Handlers** triggered by roles or tasks.
6. **Post_tasks** defined in the play.
7. **Handlers** triggered by post_tasks.
