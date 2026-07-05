#!/usr/bin/env python3
"""
Quick validation script for Field Service Suite skills.

Usage:
    python scripts/quick_validate.py skills/<module-name>
    python scripts/quick_validate.py                    # Validate all skills
"""

import os
import sys
import re
from pathlib import Path


def validate_skill(skill_dir: Path) -> list[str]:
    """Validate a single skill directory. Returns list of errors."""
    errors = []

    # Check SKILL.md exists
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        errors.append(f"Missing SKILL.md in {skill_dir}")
        return errors

    content = skill_md.read_text(encoding="utf-8")

    # Check frontmatter
    if not content.startswith("---"):
        errors.append(f"SKILL.md must start with YAML frontmatter (---)")
        return errors

    # Extract frontmatter
    fm_match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not fm_match:
        errors.append(f"Invalid YAML frontmatter format")
        return errors

    frontmatter = fm_match.group(1)

    # Check required fields
    if "name:" not in frontmatter:
        errors.append("Frontmatter missing 'name' field")
    if "description:" not in frontmatter:
        errors.append("Frontmatter missing 'description' field")

    # Check description is not empty
    desc_match = re.search(r"description:\s*\|?\s*\n?\s*(.+)", frontmatter)
    if desc_match and len(desc_match.group(1).strip()) < 20:
        errors.append("Description too short (< 20 chars)")

    # Check agents/openai.yaml exists (recommended)
    agents_yaml = skill_dir / "agents" / "openai.yaml"
    if not agents_yaml.exists():
        errors.append(f"Warning: Missing agents/openai.yaml (recommended)")

    # Check references directory
    refs_dir = skill_dir / "references"
    if refs_dir.exists():
        for ref_file in refs_dir.glob("**/*"):
            if ref_file.is_file() and ref_file.stat().st_size == 0:
                errors.append(f"Empty reference file: {ref_file.relative_to(skill_dir)}")

    # Check assets directory
    assets_dir = skill_dir / "assets"
    if assets_dir.exists():
        for asset_file in assets_dir.glob("**/*.json"):
            try:
                import json
                json.loads(asset_file.read_text(encoding="utf-8"))
            except json.JSONDecodeError as e:
                errors.append(f"Invalid JSON in {asset_file.relative_to(skill_dir)}: {e}")

    return errors


def find_skills(base_dir: Path) -> list[Path]:
    """Find all skill directories (containing SKILL.md)."""
    skills = []
    skills_dir = base_dir / "skills"
    if skills_dir.exists():
        for item in skills_dir.iterdir():
            if item.is_dir() and not item.name.startswith("_"):
                if (item / "SKILL.md").exists():
                    skills.append(item)
    return skills


def main():
    if len(sys.argv) > 1:
        # Validate specific skill
        skill_path = Path(sys.argv[1])
        if not skill_path.exists():
            print(f"Error: {skill_path} does not exist")
            sys.exit(1)
        errors = validate_skill(skill_path)
        if errors:
            print(f"\n❌ {skill_path.name}:")
            for err in errors:
                print(f"  - {err}")
            sys.exit(1)
        else:
            print(f"✅ {skill_path.name}: Valid")
    else:
        # Validate all skills
        base_dir = Path(__file__).parent.parent
        skills = find_skills(base_dir)
        if not skills:
            print("No skills found")
            sys.exit(1)

        total_errors = 0
        for skill in sorted(skills):
            errors = validate_skill(skill)
            if errors:
                print(f"\n❌ {skill.name}:")
                for err in errors:
                    print(f"  - {err}")
                total_errors += len(errors)
            else:
                print(f"✅ {skill.name}: Valid")

        print(f"\n{'='*40}")
        print(f"Validated {len(skills)} skills, {total_errors} errors found")
        sys.exit(1 if total_errors > 0 else 0)


if __name__ == "__main__":
    main()
