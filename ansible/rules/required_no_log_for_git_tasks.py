from __future__ import annotations

from typing import Any

from ansiblelint.rules import AnsibleLintRule


class RequiredNoLogForGitTasksRule(AnsibleLintRule):
    id = "CUSTOM002"
    shortdesc = "Git clone/update tasks must set no_log: true"
    description = (
        "Tasks using ansible.builtin.git must set no_log: true to suppress noisy "
        "revision changes and avoid leaking repository operation details in logs."
    )
    severity = "LOW"
    tags = ["style", "no-log"]
    version_added = "v1.0.0"

    _GIT_MODULES = {"ansible.builtin.git", "git"}

    def matchtask(self, task: dict[str, Any], file: Any | None = None) -> bool:
        action = task.get("action", {})
        module = action.get("__ansible_module__", "")
        if module not in self._GIT_MODULES:
            return False
        return not self._is_true(task.get("no_log"))

    @staticmethod
    def _is_true(value: Any) -> bool:
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return value.strip().lower() == "true"
        return False
