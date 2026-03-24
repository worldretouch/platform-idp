#!/usr/bin/env python3
"""
Validate service.yaml against platform JSON schema.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--service-file",
        default="service.yaml",
        help="Path to service.yaml file",
    )
    parser.add_argument(
        "--schema-file",
        default="shared/ci/service-yaml.schema.json",
        help="Path to JSON schema file",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    service_path = Path(args.service_file)
    schema_path = Path(args.schema_file)

    if not service_path.exists():
        print(f"ERROR: missing service metadata file: {service_path}")
        return 1

    if not schema_path.exists():
        print(f"ERROR: missing schema file: {schema_path}")
        return 1

    try:
        data = yaml.safe_load(service_path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: invalid YAML in {service_path}: {exc}")
        return 1

    if not isinstance(data, dict):
        print(f"ERROR: {service_path} must contain a YAML object")
        return 1

    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: invalid JSON schema in {schema_path}: {exc}")
        return 1

    validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(data), key=lambda err: list(err.path))

    if errors:
        print(f"ERROR: schema validation failed for {service_path}")
        for err in errors:
            path = ".".join(str(p) for p in err.path) or "<root>"
            print(f" - {path}: {err.message}")
        return 1

    print(f"OK: {service_path} matches platform schema")
    return 0


if __name__ == "__main__":
    sys.exit(main())
