# Plugin Marketplace Guide

## Module Structure

    your-module/
    SKILL.md              Required: skill definition
    agents/openai.yaml    Required: UI metadata
    references/data-model.md     Required: industry data model
    references/workflows.md      Required: industry workflows
    assets/schemas/*.json Required: JSON Schema for asset extension

## Publishing Checklist

- SKILL.md with proper frontmatter (name + description)
- agents/openai.yaml with display_name
- Asset extension JSON Schema (extends core Asset)
- Data model reference document
- Workflows reference document
- At least one working example
- Follows naming conventions
- Uses shared Timeline, Attachment, OCR systems

## Submission Process

1. Fork the repository
2. Create your module in skills/your-module/
3. Run: python scripts/quick_validate.py skills/your-module
4. Submit a Pull Request
5. Review and merge
