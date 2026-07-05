# Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [0.3.0] - 2026-07-06

### Added
- Elevator industry module
  - 7 elevator types (passenger, freight, residential, escalator, hospital, observation)
  - Compliance tracking (annual inspection, safety certificates, registration)
  - Maintenance checklist with 30+ inspection items
  - Common fault database
- Fire safety industry module
  - 13 equipment types (extinguisher, alarm, sprinkler, detector, fire door, etc.)
  - Expiry tracking and compliance documentation
  - Inspection checklists for extinguishers, alarms, sprinklers
  - Fire drill scheduling and records
- Solar PV industry module
  - 4 system types (residential, commercial, industrial, utility)
  - Generation monitoring and performance degradation tracking
  - Panel cleaning schedules
  - 3 grid types (on-grid, off-grid, hybrid)
- Security industry module
  - 14 device types (camera, NVR, DVR, access control, alarm, etc.)
  - Network configuration tracking (IP, MAC, protocol)
  - Firmware version management
  - Storage capacity calculation

## [0.2.0] - 2026-07-06

### Added
- Appliance repair industry module with complete data model, workflows, and fault database
  - 12 appliance types (washing machine, refrigerator, microwave, dishwasher, etc.)
  - Detailed fault diagnosis tables for washing machines, refrigerators, microwaves, dishwashers, range hoods
  - Maintenance checklists per appliance type
  - 16 common appliance brands with model naming patterns
  - OCR patterns for appliance nameplate recognition
- Water purifier industry module with TDS monitoring and filter lifecycle tracking
  - 7 purifier types (RO, UF, UV, nanofiltration, water softener, commercial)
  - Filter type database (PP, CTO, RO membrane, UF membrane, UV lamp, T33, mineral)
  - TDS trend analysis for filter health monitoring
  - Filter lifespan calculation and replacement scheduling
  - Water quality testing workflow
  - 12 common water purifier brands
- New templates from v0.2 testing iteration
  - useFormWizard composable for multi-step forms
  - timeline utilities (date grouping, stats, event subtitles)
  - asset-lookup-service for scanner flow

### Changed
- Updated pinia-store template with enrichment pattern (join master data names for display)
- Updated SKILL.md with 7 Critical Patterns (was 3)
  - Added Component Splitting rule (pages > 200 lines must split)
  - Added Checklist Loading rule (load from workflow references, not hardcode)
  - Added Component Splitting and Checklist Loading patterns

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
