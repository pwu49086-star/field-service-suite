# OCR Engine Rules

## Principle

OCR is a **Core capability** shared across all industries. No industry-specific OCR logic lives in the OCR engine itself — industry modules provide parsing rules as configuration.

## Recognition Types

| Type | Input | Output | Industry Agnostic? |
|------|-------|--------|-------------------|
| nameplate | Photo of device nameplate | Structured fields (brand, model, SN, specs) | ✅ Core provides framework, industries provide parsers |
| barcode | Barcode image | String value | ✅ Fully generic |
| qrcode | QR code image | String value (URL, JSON, text) | ✅ Fully generic |
| invoice | Photo of invoice | Structured invoice data | ✅ Core provides framework |
| receipt | Photo of receipt | Amount, date, items | ✅ Core provides framework |
| contract | Photo/scan of contract | Key fields extraction | ✅ Core provides framework |

## Processing Pipeline

```
1. Image Acquisition
   └── Camera capture or file selection

2. Image Preprocessing
   ├── Auto-rotate (EXIF orientation)
   ├── Crop to region of interest
   ├── Enhance contrast (adaptive histogram)
   ├── Denoise
   └── Binarize (for text recognition)

3. OCR Recognition
   ├── Barcode/QR: decode directly from image
   └── Text: run OCR engine (Tesseract / cloud API)

4. Structured Parsing
   ├── Apply type-specific parser (nameplate, invoice, ...)
   ├── Industry module provides field mapping rules
   └── Extract structured key-value pairs

5. Confidence Assessment
   ├── High (> 0.85): auto-fill form fields
   ├── Medium (0.6 - 0.85): pre-fill with highlight for confirmation
   └── Low (< 0.6): show raw text for manual extraction

6. Human Confirmation
   ├── Show extracted fields alongside original image
   ├── User can edit any field
   └── Confirm to populate form
```

## OCR Engine Interface

```typescript
interface OCREngine {
  recognize(image: Blob, type: OCRType): Promise<OCRResult>;
}

interface OCRResult {
  type: OCRType;
  confidence: number;           // 0-1
  rawText: string;              // Full OCR text output
  fields: OCRField[];           // Structured field extraction
  processingTime: number;       // ms
}

interface OCRField {
  name: string;                 // Field name (e.g., 'brand', 'model')
  value: string;                // Extracted value
  confidence: number;           // 0-1
  boundingBox?: {               // Position in original image
    x: number; y: number;
    width: number; height: number;
  };
}

type OCRType = 'nameplate' | 'barcode' | 'qrcode' | 'invoice' | 'receipt' | 'contract';
```

## Industry Module Integration

Industry modules register **nameplate parsers** that know how to extract fields from OCR text:

```typescript
// HVAC module registers its parser
ocrEngine.registerParser('nameplate', 'hvac', {
  patterns: [
    { regex: /REF[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant' },
    { regex: /(\d+\.?\d*)\s*(?:匹|HP|hp)/i, field: 'horsepower' },
    { regex: /(\d{3})\s*V/i, field: 'voltage' },
    { regex: /S\/?N[:\s]*([A-Z0-9-]+)/i, field: 'serialNumber' },
    { regex: /(?:型号|MODEL)[:\s]*([A-Z0-9-]+)/i, field: 'model' },
  ],
  postProcess: (fields) => {
    // Convert horsepower to cooling capacity estimate
    if (fields.horsepower) {
      fields.coolingCapacity = parseFloat(fields.horsepower) * 2500;
    }
    return fields;
  }
});
```

## Rules

1. OCR engine never contains industry-specific logic
2. Industry modules provide parsing rules as configuration
3. All OCR results include confidence scores
4. Low-confidence results always require human confirmation
5. OCR processing happens in a Web Worker — never block UI
6. Cache OCR results for 7 days to avoid re-processing same image
