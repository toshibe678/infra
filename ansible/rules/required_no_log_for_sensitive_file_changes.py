from __future__ import annotations

import re
from typing import Any

from ansiblelint.rules import AnsibleLintRule


class RequiredNoLogForSensitiveFileChangesRule(AnsibleLintRule):
    id = "CUSTOM001"
    shortdesc = "Sensitive file changes must set no_log: true"
    description = (
        "Tasks that write likely-sensitive files (for example .env, wireguard *.conf, "
        "or SSH private keys) must set no_log: true to prevent leaking values in logs."
    )
    severity = "MEDIUM"
    tags = ["security", "no-log"]
    version_added = "v1.0.0"

    _WRITE_MODULES = {
        "ansible.builtin.copy",
        "copy",
        "ansible.builtin.template",
        "template",
        "ansible.builtin.lineinfile",
        "lineinfile",
        "ansible.builtin.blockinfile",
        "blockinfile",
        "ansible.builtin.replace",
        "replace",
    }
    _SENSITIVE_TARGET_PATTERNS = (
        re.compile(r"(^|/)\.env([.-].+)?$"),
        re.compile(r"^/etc/wireguard/.+\.conf$"),
        re.compile(r"(^|/)\.ssh/id_[^/]+$"),
        re.compile(r"(^|/)\.ssh/gitkey$"),
    )

    def matchtask(self, task: dict[str, Any], file: Any | None = None) -> bool:
        action = task.get("action", {})
        module = action.get("__ansible_module__", "")
        if module not in self._WRITE_MODULES:
            return False

        target = self._extract_target_path(action)
        if not target or not self._is_sensitive_target(target):
            return False

        return not self._is_true(task.get("no_log"))

    def _extract_target_path(self, action: dict[str, Any]) -> str:
        for key in ("dest", "path", "name"):
            value = action.get(key)
            if isinstance(value, str):
                return value.strip().strip('"').strip("'")
        return ""

    def _is_sensitive_target(self, target: str) -> bool:
        return any(pattern.search(target) for pattern in self._SENSITIVE_TARGET_PATTERNS)

    @staticmethod
    def _is_true(value: Any) -> bool:
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return value.strip().lower() == "true"
        return False
