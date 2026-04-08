"""Custom ansible-lint rule to enforce role name in task names."""
from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

from ansiblelint.rules import AnsibleLintRule

if TYPE_CHECKING:
    from ansiblelint.file_utils import Lintable
    from ansiblelint.utils import Task


class RoleNameInTaskRule(AnsibleLintRule):
    """Rule to ensure task names in roles include the role name."""

    id = "role-task-name"
    description = "Task names in roles should include the role name in format 'ROLE_NAME | Description'"
    severity = "MEDIUM"
    tags = ["idiom", "formatting"]
    version_added = "1.0.0"

    def matchtask(
        self, task: Task, file: Lintable | None = None
    ) -> bool | str:
        """Check if task name includes role name."""
        # Only check tasks within roles
        if not file or not file.path:
            return False

        # Check if file is within a role's tasks or handlers directory
        path_parts = Path(file.path).parts
        if "roles" not in path_parts:
            return False

        # Find role name from path
        try:
            roles_index = path_parts.index("roles")
            if roles_index + 1 >= len(path_parts):
                return False
            role_name = path_parts[roles_index + 1]
        except (ValueError, IndexError):
            return False

        # Check if we're in tasks or handlers directory
        if not any(part in ["tasks", "handlers"] for part in path_parts):
            return False

        # Get task name
        task_name = task.get("name")
        if not task_name:
            return False

        # Convert role name to expected format (snake_case to UPPER CASE)
        # e.g., "dns_stack" -> "DNS STACK"
        role_name_formatted = role_name.replace("_", " ").upper()

        # Check if task name starts with role name followed by pipe
        pattern = rf"^{re.escape(role_name_formatted)}\s*\|"
        if not re.match(pattern, task_name):
            return (
                f"Task name should start with '{role_name_formatted} | ' "
                f"but found: '{task_name}'"
            )

        return False
