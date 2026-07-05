#!/usr/bin/env python3
"""
Generate a new industry module from the _module-template.

Usage:
    python scripts/generate_module.py <module-name> <industry-name>

Example:
    python scripts/generate_module.py elevator 电梯
"""

import os
import sys
import shutil
from pathlib import Path


def generate_module(module_name: str, industry_name: str):
    """Generate a new module from template."""
    base_dir = Path(__file__).parent.parent
    template_dir = base_dir / "skills" / "_module-template"
    target_dir = base_dir / "skills" / module_name

    if target_dir.exists():
        print(f"Error: {target_dir} already exists")
        sys.exit(1)

    # Copy template
    shutil.copytree(template_dir, target_dir)

    # Replace placeholders in all files
    replacements = {
        "{{module-name}}": module_name,
        "{{Industry Name}}": industry_name,
        "{{Industry}}": industry_name,
        "{{industry}}": industry_name,
    }

    for file_path in target_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in (".md", ".tpl", ".json", ".yaml"):
            content = file_path.read_text(encoding="utf-8")
            for placeholder, value in replacements.items():
                content = content.replace(placeholder, value)
            file_path.write_text(content, encoding="utf-8")

        # Rename .tpl files
        if file_path.suffix == ".tpl":
            new_path = file_path.with_suffix("")
            file_path.rename(new_path)

    print(f"✅ Module '{module_name}' ({industry_name}) created at {target_dir}")
    print(f"\nNext steps:")
    print(f"  1. Edit skills/{module_name}/SKILL.md — update description and content")
    print(f"  2. Edit skills/{module_name}/references/data-model.md — define your fields")
    print(f"  3. Edit skills/{module_name}/assets/schemas/asset-extension.json — define your schema")
    print(f"  4. Register in plugin.json skills array")
    print(f"  5. Run: python scripts/quick_validate.py skills/{module_name}")


def main():
    if len(sys.argv) < 3:
        print("Usage: python generate_module.py <module-name> <industry-name>")
        print("Example: python generate_module.py elevator 电梯")
        sys.exit(1)

    module_name = sys.argv[1]
    industry_name = sys.argv[2]

    generate_module(module_name, industry_name)


if __name__ == "__main__":
    main()
