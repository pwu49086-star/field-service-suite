# HVAC Nameplate OCR

## Overview

HVAC registers a nameplate parser with the Core OCR engine. When a technician takes a photo of an air conditioner's nameplate, the OCR engine extracts structured data.

## Recognizable Fields

| Field | OCR Pattern | Example Match |
|-------|------------|---------------|
| brand | `品牌/BRAND: xxx` | "品牌: 格力" |
| model | `型号/MODEL: xxx` | "型号: KFR-35GW" |
| serialNumber | `S/N: xxx` | "S/N: ABC123456" |
| refrigerant | `制冷剂/REF: Rxxx` | "制冷剂: R410A" |
| voltage | `xxxV` | "220V" |
| horsepower | `xxx匹/HP` | "1.5匹" |
| coolingCapacity | `xxxW` (制冷) | "3500W" |
| heatingCapacity | `xxxW` (制热) | "4000W" |
| current | `xxxA` | "6.5A" |

## Processing Flow

```
1. Technician takes nameplate photo
   ↓
2. Image compressed (800px, 80% quality)
   ↓
3. OCR engine runs in Web Worker
   ↓
4. Text extraction from image
   ↓
5. Pattern matching against HVAC regex rules
   ↓
6. Post-processing (HP → cooling capacity estimate)
   ↓
7. Confidence assessment:
   - High (> 0.85): auto-fill form
   - Medium (0.6-0.85): pre-fill, highlight for confirmation
   - Low (< 0.6): show raw text, manual extraction
   ↓
8. User confirms/edits extracted fields
   ↓
9. Fields populated into Asset extension
```

## Regex Patterns

```typescript
const hvacPatterns = [
  // Brand
  { regex: /(?:品牌|BRAND|制造商)[:\s]*(.+)/i, field: 'brand', confidence: 0.9 },

  // Model
  { regex: /(?:型号|MODEL|Type)[:\s]*([A-Z0-9\-\/]+)/i, field: 'model', confidence: 0.9 },

  // Serial Number
  { regex: /(?:S\/?N|序列号|机身号)[:\s]*([A-Z0-9\-]+)/i, field: 'serialNumber', confidence: 0.85 },

  // Refrigerant
  { regex: /(?:制冷剂|冷媒|REF|Refrigerant)[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant', confidence: 0.9 },

  // Voltage
  { regex: /(?:电压|VOLTAGE)?[:\s]*(\d{2,3})\s*V/i, field: 'voltage', confidence: 0.85 },

  // Horsepower
  { regex: /(\d+\.?\d*)\s*(?:匹|HP|hp|P)/i, field: 'horsepower', confidence: 0.85 },

  // Cooling capacity
  { regex: /(?:制冷量|制冷|Cooling)[:\s]*(\d+)\s*(?:W|瓦)/i, field: 'coolingCapacity', confidence: 0.85 },

  // Heating capacity
  { regex: /(?:制热量|制热|Heating)[:\s]*(\d+)\s*(?:W|瓦)/i, field: 'heatingCapacity', confidence: 0.85 },

  // Current
  { regex: /(?:额定电流|电流|Current)[:\s]*(\d+\.?\d*)\s*A/i, field: 'current', confidence: 0.8 },
];
```

## Post-Processing

```typescript
function postProcess(fields: Record<string, string>): Record<string, any> {
  const result: Record<string, any> = { ...fields };

  // Convert horsepower to number
  if (result.horsepower) {
    result.horsepower = parseFloat(result.horsepower);
  }

  // Estimate cooling capacity from horsepower if not directly available
  if (result.horsepower && !result.coolingCapacity) {
    result.coolingCapacity = Math.round(result.horsepower * 2500);
  }

  // Normalize refrigerant code
  if (result.refrigerant) {
    result.refrigerant = result.refrigerant.toUpperCase().replace(/\s/g, '');
  }

  // Convert voltage to number
  if (result.voltage) {
    result.voltage = parseInt(result.voltage, 10);
  }

  return result;
}
```

## Tips for Better Recognition

1. **Lighting**: Ensure the nameplate is well-lit, avoid shadows
2. **Angle**: Camera should be perpendicular to the nameplate
3. **Focus**: Tap on the nameplate to focus
4. **Clean**: Wipe off dust/dirt before photographing
5. **Full nameplate**: Capture the entire nameplate in frame
6. **Multiple shots**: Take 2-3 photos if uncertain
