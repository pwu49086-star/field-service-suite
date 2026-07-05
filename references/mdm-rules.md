# Master Data Management Rules

## Principle

All foundational entities are **Master Data** — globally unique records that are referenced, never copied.

## Master Data Entities

| Entity | Key Fields | Uniqueness Rule |
|--------|-----------|----------------|
| Customer | name, phone, email | One record per person/organization |
| Asset | serialNumber, brandId, modelId | One record per physical device |
| Part | sku, name | One record per spare part type |
| Brand | name | One record per manufacturer |
| Model | brandId, name | One record per product model per brand |
| Supplier | name, contact | One record per supplier |
| Technician | name, phone | One record per field worker |

## Reference Rules

1. **WorkOrder never contains customer name/address** — it holds `customerId` only
2. **WorkOrder never contains asset serial/brand** — it holds `assetId` only
3. **WorkOrder never contains technician name** — it holds `technicianId` only
4. **PartsUsage never contains part name/price** — it holds `partId` + quantity
5. **Asset never contains brand name or model name** — it holds `brandId` and `modelId`
6. **Asset never contains customer name** — it holds `customerId`

## Denormalization Exception

The ONLY allowed denormalization is for **search/display performance**, and it must:

- Be a cached copy, not the source of truth
- Be clearly marked as `denormalized` or `cached`
- Be automatically updated when the source changes
- Never be used for writes

Example: Storing `customerName` on WorkOrder for list display is acceptable if it's a cached field that updates when Customer changes.

## Data Integrity Rules

1. Deleting a master data record requires checking all references first
2. If references exist, mark as `inactive` instead of deleting
3. Work orders are never physically deleted — only marked `cancelled` or `archived`
4. Use soft deletes (`deletedAt` timestamp) for all master data

## Industry Extension Rule

Industry-specific fields go in a JSON `extension` field on the Asset entity:

```typescript
interface Asset {
  // Shared fields (all industries)
  id: string;
  name: string;
  serialNumber: string;
  brandId: string;
  modelId: string;
  customerId: string;
  category: AssetCategory; // 'hvac' | 'elevator' | 'solar' | ...
  extension: Record<string, unknown>; // Industry-specific
}
```

Each industry module defines its own extension schema. Core never validates industry-specific fields.
