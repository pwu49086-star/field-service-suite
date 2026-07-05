# OCR Engine

## Overview

OCR is a **Core capability** — shared across all industries. The engine itself is generic; industry modules provide parsing rules.

## Recognition Types

| Type | Input | Output |
|------|-------|--------|
| nameplate | Device nameplate photo | brand, model, SN, specs |
| barcode | Barcode image | String value |
| qrcode | QR code image | String/JSON value |
| invoice | Invoice photo | Structured invoice data |
| receipt | Receipt photo | Amount, date, items |
| contract | Document scan | Key fields |

## Pipeline

```
Image → Preprocess → OCR → Parse (industry module) → Confidence → Confirm → Fill Form
```

## Confidence Levels

- **High (> 0.85)**: Auto-fill form fields
- **Medium (0.6-0.85)**: Pre-fill with highlight for confirmation
- **Low (< 0.6)**: Show raw text for manual extraction

## Industry Integration

Industry modules register nameplate parsers:

```typescript
ocrEngine.registerParser('nameplate', 'hvac', {
  patterns: [
    { regex: /REF[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant' },
    { regex: /(\d+\.?\d*)\s*(?:匹|HP)/i, field: 'horsepower' },
  ],
});
```

## Rules

1. OCR engine never contains industry-specific logic
2. All results include confidence scores
3. Low confidence always requires human confirmation
4. Processing happens in Web Worker
5. Cache results for 7 days
