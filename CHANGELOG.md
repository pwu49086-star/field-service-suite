# Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [0.1.0] - 2026-07-06

### Added
- Initial project structure following Codex Skill plugin architecture
- Core router SKILL.md with industry routing logic
- 14 reference documents (rules) covering all core concerns
- 7 master data JSON schemas (Customer, Asset, Part, Brand, Model, Supplier, Technician)
- 5 business JSON schemas (WorkOrder, Attachment, TimelineEvent, Payment, Quote)
- 6 code generation templates (Vue pages, Dexie schema, services, stores, workflow)
- field-service-core sub-skill with master data, timeline, attachment, and OCR references
- HVAC industry sub-skill with data model, workflows, brands, and nameplate OCR rules
- Module development template for creating new industry modules
- Placeholder skills for: appliance-repair, water-purifier, elevator, fire-safety, solar, security
- Architecture design document
- README, LICENSE (MIT), CONTRIBUTING guide

### Design Decisions
- Renamed "Equipment" to "Asset" for better extensibility
- Unified Event Timeline replaces separate history tables
- OCR Engine belongs to Core, not any specific industry
- Attachment System supports images, video, PDF, audio, document
- All master data entities follow MDM principles: globally unique, referenced never copied
