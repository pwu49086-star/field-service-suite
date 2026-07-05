# Module Development Guide

## Overview

This guide explains how to create a new industry module for Field Service Suite. Each module is an independent Codex Sub-Skill that extends the core Asset model with industry-specific fields and workflows.

## Step-by-Step Process

### 1. Create Module Directory

```
skills/<module-name>/
├── SKILL.md              # Required — module skill definition
├── agents/
│   └── openai.yaml       # UI metadata
├── references/
│   ├── data-model.md     # Industry-specific data model
│   ├── workflows.md      # Industry-specific workflows
│   └── [optional]        # Brand lists, checklists, etc.
└── assets/
    └── schemas/
        └── *-extension.json  # JSON Schema for asset extension
```

### 2. Write SKILL.md Frontmatter

```yaml
---
name: <module-name>
description: |
  <Industry name> field service module.
  Use when:
  - Building <industry> asset management
  - Creating <industry> work orders (installation, repair, maintenance, inspection)
  - Processing <industry>-specific data (fields, checklists, etc.)
  - Integrating <industry> OCR or scanning
  Do NOT use for other industries or generic field service tasks.
---
```

### 3. Define Asset Extension

Create `assets/schemas/<module>-asset-extension.json`:

```json
{
  "$id": "field-service://schemas/<module>-asset-extension",
  "type": "object",
  "properties": {
    "industryField1": { "type": "string", "description": "..." },
    "industryField2": { "type": "number", "description": "..." }
  },
  "required": ["industryField1"]
}
```

### 4. Define Data Model

Create `references/data-model.md`:

- List all industry-specific fields with types and descriptions
- Define industry-specific enums
- Define validation rules
- Define relationships to core entities

### 5. Define Workflows

Create `references/workflows.md`:

- List all workflow types (installation, repair, maintenance, inspection)
- Define state machines for each workflow type
- Define checklist items
- Define required data per workflow step

### 6. Register in Plugin

Add to root `plugin.json`:

```json
{
  "skills": [
    "skills/field-service-core",
    "skills/hvac",
    "skills/<module-name>"  // ← Add here
  ]
}
```

### 7. Validate

Run the validation script:

```bash
python scripts/quick_validate.py skills/<module-name>
```

## Module Requirements Checklist

- [ ] SKILL.md with proper frontmatter (name + description)
- [ ] agents/openai.yaml with UI metadata
- [ ] Asset extension JSON Schema
- [ ] Data model reference document
- [ ] Workflow reference document
- [ ] At least one working example
- [ ] Follows naming conventions
- [ ] No hardcoded industry logic in Core
- [ ] Uses shared Timeline, Attachment, OCR systems
- [ ] Validates against quick_validate.py

## Anti-Patterns

- ❌ Adding fields directly to the core Asset schema
- ❌ Creating separate history tables (use Timeline)
- ❌ Implementing industry-specific OCR in Core
- ❌ Hardcoding industry names in routing logic
- ❌ Copying master data into work orders
