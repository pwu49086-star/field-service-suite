# Asset Lifecycle Rules

## Asset Identity

- Every physical device, installation, or equipment is an **Asset**
- Asset is the central entity of the entire system
- Each Asset has a unique `id` (UUID) and `serialNumber`
- Asset references: `brandId`, `modelId`, `customerId`, `addressId`

## Asset Categories

```
hvac              — Air conditioning, heating, ventilation
appliance         — Washing machine, refrigerator, microwave, dishwasher
elevator          — Elevators, escalators
water-purifier    — RO filters, UV purifiers
solar             — Solar panels, inverters, batteries
fire-safety       — Extinguishers, alarms, sprinklers
security          — Cameras, access control, sensors
other             — Any other physical asset
```

## Asset Lifecycle States

```
registered → active → maintenance → inactive → scrapped
                  ↘                    ↑
                   → transferred → ────┘
```

| State | Meaning | Next States |
|-------|---------|-------------|
| registered | Newly created, not yet installed | active |
| active | In normal operation | maintenance, inactive, transferred, scrapped |
| maintenance | Temporarily out of service for repair/maintenance | active, inactive |
| inactive | Decommissioned but not scrapped | active, scrapped |
| transferred | Moved to a new address | active |
| scrapped | End of life, permanently out of service | (terminal) |

## Lifecycle Events (Timeline)

Every state change and service activity creates a **Timeline Event**:

| Event Type | Trigger | Data |
|-----------|---------|------|
| installation | Asset installed at location | Install params, commissioning results |
| repair | Fault reported and fixed | Fault description, repair actions, parts used |
| maintenance | Scheduled or preventive service | Checklist results, parts replaced |
| inspection | Periodic check or compliance audit | Inspection checklist, pass/fail |
| quote | Price estimate for work | Line items, total, approval status |
| payment | Payment collected | Amount, method, invoice |
| callback | Post-service follow-up | Satisfaction, feedback |
| transfer | Asset moved to new address | From/to address |
| scrap | Asset decommissioned | Reason, disposal method |
| note | General note or observation | Free text |

## Asset Extension Pattern

Industry-specific data is stored in `asset.extension` as a JSON object. Each industry module defines its own extension interface.

```typescript
// Core defines the base
interface Asset {
  id: string;
  name: string;
  serialNumber: string;
  category: AssetCategory;
  extension: Record<string, unknown>;
}

// HVAC module defines its extension
interface HVACExtension {
  refrigerant: string;
  voltage: number;
  horsepower: number;
  coolingCapacity: number;
  outdoorUnitSerial?: string;
}

// Usage
const asset: Asset = {
  id: 'uuid-1',
  name: '客厅空调',
  serialNumber: 'SN-2026-001',
  category: 'hvac',
  extension: {
    refrigerant: 'R410A',
    voltage: 220,
    horsepower: 1.5,
    coolingCapacity: 3500
  }
};
```

## Rules

1. Asset category is set at creation and never changes
2. Extension schema is validated by the industry module, not by Core
3. Changing extension fields does not affect the asset lifecycle state
4. All asset operations must create Timeline Events
5. Asset deletion is forbidden — use scrap state instead
