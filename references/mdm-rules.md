# Master Data Management Rules

## Principle

All foundational entities are **Master Data** — globally unique records that are referenced, never copied.

## Master Data Entities

| Entity | Key Fields | Uniqueness Rule |
|--------|-----------|----------------|
| Customer | name, phone | One record per person/organization |
| Asset | name, customerId, addressId | One record per device, identified by customer + location |
| Part | name, sku | One record per spare part type |
| Brand | name | One record per manufacturer |
| Model | brandId, name | One record per product model per brand |
| Supplier | name, contact | One record per supplier |
| Technician | name, phone | One record per field worker |

## Customer-First Architecture

**Primary identifier: Customer + Address, NOT equipment serial number.**

```
Customer (name, phone)
  └── Address (label, detail)
       └── Asset (name, brand, model, location)
            └── WorkOrder (type, status, description)
                └── TimelineEvent (type, timestamp)
```

### Why Customer-First?

For non-official service providers:
- Customer calls with a problem → Record customer info
- Technician goes to customer's address → Service equipment at that location
- Equipment is identified by: "客厅空调" (Living Room AC), not by SN
- History is tracked per customer, not per equipment serial

### Equipment Identification

Equipment is identified by:
- **Customer** (who owns it)
- **Address** (where it's located)
- **Name/Location** (客厅空调, 卧室空调, 办公室中央空调)

NOT by:
- ❌ Serial number (not useful for non-official)
- ❌ QR code (manufacturer-specific)
- ❌ Barcode (no lookup value)

## Reference Rules

1. **WorkOrder never contains customer name** — it holds `customerId` only
2. **WorkOrder never contains address detail** — it holds `addressId` only
3. **WorkOrder never contains equipment brand/model** — it holds `assetId` only (optional)
4. **Asset references customer and address** — never copies their data
5. **Asset does NOT require serial number** — identified by customer + location

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
  name: string;                    // "客厅空调", "卧室空调"
  customerId: string;              // Owner
  addressId: string;               // Location
  category: AssetCategory;         // 'hvac' | 'appliance' | ...
  extension: Record<string, unknown>; // Industry-specific
}
```

Each industry module defines its own extension schema. Core never validates industry-specific fields.
