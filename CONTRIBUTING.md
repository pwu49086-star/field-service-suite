# Contributing to Field Service Suite

Thank you for your interest in contributing!

## Adding a New Industry Module

1. Copy `skills/_module-template/` to `skills/<your-module>/`
2. Update `SKILL.md` frontmatter with your module name and description
3. Define your data model in `references/data-model.md`
4. Create JSON Schema extensions in `assets/schemas/`
5. Register the module in the root `plugin.json` skills array
6. Run `scripts/quick_validate.py skills/<your-module>` to verify
7. Submit a pull request

## Module Requirements

Every industry module MUST:

- Extend the base Asset schema (not create a parallel entity)
- Use the unified Timeline for all history events
- Use the shared Attachment system for photos/documents
- Use the shared OCR engine for recognition tasks
- Follow the naming conventions in `references/naming-rules.md`
- Follow the UI rules in `references/ui-rules.md`
- Include at least one working example

## Code Style

- TypeScript strict mode
- Vue 3 Composition API
- Tailwind CSS for styling
- Dexie.js for IndexedDB access
- All master data entities follow MDM principles

## Reporting Issues

Open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Codex version and environment
