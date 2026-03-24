#!/usr/bin/env python3
"""
Fail CI when production values image.tag violates platform policy.
Policy:
- must not be latest-like tags
- must match SHA-like format
"""

from __future__ import annotations

import glob
import re
import sys
from pathlib import Path

import yaml


GLOBS = [
    "shared/gitops/environments/prod/values/*.yaml",
    "shared/gitops/environments/prod/values/*.yml",
    "environments/prod/values/*.yaml",
    "environments/prod/values/*.yml",
]
SHA_LIKE_PATTERN = r"^(sha-)?[0-9a-f]{7,64}$"


def collect_files() -> list[Path]:
    files: list[Path] = []
    for pattern in GLOBS:
        for match in glob.glob(pattern):
            p = Path(match)
            if p.is_file():
                files.append(p)
    unique = sorted(set(files))
    return unique


def main() -> int:
    files = collect_files()
    if not files:
        print("OK: no production values files found, skip latest-tag check")
        return 0

    violations: list[str] = []
    for file_path in files:
        try:
            data = yaml.safe_load(file_path.read_text(encoding="utf-8")) or {}
        except Exception as exc:  # noqa: BLE001
            violations.append(f"{file_path}: invalid YAML ({exc})")
            continue

        tag = ((data.get("image") or {}).get("tag") or "").strip()
        tag_lower = tag.lower()
        if not tag:
            violations.append(f"{file_path}: missing production image tag")
            continue
        if tag_lower in {"latest", "main-latest", "prod-latest"}:
            violations.append(
                f"{file_path}: disallowed production image tag '{tag}'"
            )
            continue
        if re.fullmatch(SHA_LIKE_PATTERN, tag_lower) is None:
            violations.append(
                f"{file_path}: production image tag must be SHA-like, got '{tag}'"
            )

    if violations:
        print("ERROR: production image tag policy violated")
        for item in violations:
            print(f" - {item}")
        return 1

    print(f"OK: production image tags validated ({len(files)} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
