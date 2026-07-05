#!/usr/bin/env python3
"""
Validate JSON Schema files in the schemas/ directory.

Usage:
    python scripts/schema_validate.py
"""

import json
import sys
from pathlib import Path


def validate_json_file(file_path: Path) -> list[str]:
    """Validate a single JSON file. Returns list of errors."""
    errors = []
    try:
        content = file_path.read_text(encoding="utf-8")
        data = json.loads(content)

        # Check required JSON Schema fields
        if "$schema" not in data:
            errors.append(f"Missing $schema field")
        if "title" not in data:
            errors.append(f"Missing title field")
        if "type" not in data:
            errors.append(f"Missing type field")

    except json.JSONDecodeError as e:
        errors.append(f"Invalid JSON: {e}")

    return errors


def main():
    base_dir = Path(__file__).parent.parent
    schemas_dir = base_dir / "schemas"

    if not schemas_dir.exists():
        print("No schemas/ directory found")
        sys.exit(1)

    total_errors = 0
    for json_file in sorted(schemas_dir.rglob("*.json")):
        errors = validate_json_file(json_file)
        rel_path = json_file.relative_to(base_dir)
        if errors:
            print(f"❌ {rel_path}:")
            for err in errors:
                print(f"  - {err}")
            total_errors += len(errors)
        else:
            print(f"✅ {rel_path}")

    print(f"\n{'='*40}")
    print(f"Validated schemas, {total_errors} errors found")
    sys.exit(1 if total_errors > 0 else 0)


if __name__ == "__main__":
    main()
