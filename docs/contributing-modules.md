# Contributing Modules

## How to Add a New Industry Module

### Step 1: Generate Module Skeleton

```bash
python scripts/generate_module.py <module-name> <industry-name>

# Example
python scripts/generate_module.py elevator 电梯
```

This creates `skills/elevator/` from the template.

### Step 2: Define Your Asset Extension

Edit `skills/elevator/assets/schemas/asset-extension.json`:

```json
{
  "type": "object",
  "properties": {
    "loadCapacity": { "type": "number", "description": "载重 (kg)" },
    "speed": { "type": "number", "description": "速度 (m/s)" },
    "floors": { "type": "integer", "description": "服务楼层" },
    "machineRoomType": { "type": "string", "enum": ["机房", "无机房"] },
    "nextInspectionDate": { "type": "string", "format": "date" }
  }
}
```

### Step 3: Define Workflows

Edit `skills/elevator/references/data-model.md`:
- List all workflow types (installation, repair, maintenance, inspection)
- Define checklists for each workflow
- Define common faults and solutions

### Step 4: Register OCR Patterns (if applicable)

If your industry has nameplate or label recognition needs, add patterns to your SKILL.md.

### Step 5: Register in plugin.json

```json
{
  "skills": [
    "skills/field-service-core",
    "skills/hvac",
    "skills/elevator"
  ]
}
```

### Step 6: Validate

```bash
python scripts/quick_validate.py skills/elevator
```

### Step 7: Submit PR

- All validation passes
- At least one working example
- README updated with your module

## Requirements Checklist

- [ ] SKILL.md with proper frontmatter
- [ ] agents/openai.yaml
- [ ] Asset extension JSON Schema
- [ ] Data model reference document
- [ ] Workflow reference document
- [ ] At least one example
- [ ] Follows naming conventions
- [ ] Uses shared Timeline, Attachment, OCR
- [ ] No hardcoded industry logic in Core
