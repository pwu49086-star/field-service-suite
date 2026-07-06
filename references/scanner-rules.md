# Scanner Rules

## Overview

Scanner functionality focuses on **nameplate OCR** for automatic equipment identification. SN/QR code scanning is not supported for non-official service providers.

## Nameplate OCR (Primary)

### Supported Equipment Types

| Equipment | Recognition Fields |
|-----------|-------------------|
| Air Conditioner | Brand, Model, Refrigerant, Voltage, Horsepower, Cooling Capacity |
| Refrigerator | Brand, Model, Capacity, Voltage |
| Washing Machine | Brand, Model, Capacity, Voltage |
| Water Heater | Brand, Model, Capacity, Voltage |

### OCR Pipeline

```
Camera Capture → Image Preprocessing → OCR Recognition → Field Extraction → User Confirmation → Data Population
```

### Recognition Flow

1. **Camera capture** - Take photo of equipment nameplate
2. **Image preprocessing** - Auto-rotate, crop, enhance contrast
3. **OCR recognition** - Extract text from image
4. **Field extraction** - Parse recognized text into structured fields
5. **Confidence assessment**:
   - High (> 0.85): Auto-fill form
   - Medium (0.6-0.85): Pre-fill with highlight for confirmation
   - Low (< 0.6): Show raw text for manual extraction
6. **User confirmation** - User reviews and confirms extracted data
7. **Data population** - Fill asset creation form with extracted data

### HVAC Nameplate Patterns

```typescript
const hvacPatterns = [
  { regex: /(?:品牌|BRAND)[:\s]*(.+)/i, field: 'brand' },
  { regex: /(?:型号|MODEL)[:\s]*([A-Z0-9\-\/]+)/i, field: 'model' },
  { regex: /(?:制冷剂|REF)[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant' },
  { regex: /(\d{3})\s*V/i, field: 'voltage' },
  { regex: /(\d+\.?\d*)\s*(?:匹|HP|hp)/i, field: 'horsepower' },
  { regex: /(?:制冷量|Cooling)[:\s]*(\d+)\s*W/i, field: 'coolingCapacity' },
];
```

## Manual Input (Fallback)

When OCR is not available or fails:

1. User manually enters equipment information
2. System searches for existing equipment by customer + location
3. If not found, create new equipment record

## Key Design Decisions

### Why No SN/QR Scanning?

For non-official service providers:
- SN is just a random string with no lookup value
- QR codes on equipment are manufacturer-specific, not useful for third parties
- Customer name + address is the primary identifier
- Equipment is associated with customer, not tracked by SN

### Customer-First Identification

```
Customer (name/phone) → Address → Equipment List → Select Equipment
```

Instead of:
```
Scan SN → Lookup Equipment → Find Customer
```

## Offline Behavior

- OCR processing happens locally (Web Worker)
- No network required for scanning
- Results cached for 7 days
