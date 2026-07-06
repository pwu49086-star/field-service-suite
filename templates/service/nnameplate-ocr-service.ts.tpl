/**
 * Nameplate OCR Template
 * 
 * Captures equipment nameplate photo and extracts structured data.
 * Used for automatic equipment identification and asset creation.
 * 
 * Follows: scanner-rules.md, ocr-rules.md
 */

export interface NameplateOCRResult {
  brand?: string;
  model?: string;
  refrigerant?: string;
  voltage?: string;
  horsepower?: string;
  coolingCapacity?: string;
  confidence: number; // 0-1
}

export interface OCRPattern {
  regex: RegExp;
  field: string;
  confidence: number;
}

// HVAC nameplate patterns
const HVAC_PATTERNS: OCRPattern[] = [
  { regex: /(?:品牌|BRAND)[:\s]*(.+)/i, field: 'brand', confidence: 0.9 },
  { regex: /(?:型号|MODEL)[:\s]*([A-Z0-9\-\/]+)/i, field: 'model', confidence: 0.9 },
  { regex: /(?:制冷剂|REF)[:\s]*(R\d+[A-Z]*)/i, field: 'refrigerant', confidence: 0.9 },
  { regex: /(\d{3})\s*V/i, field: 'voltage', confidence: 0.85 },
  { regex: /(\d+\.?\d*)\s*(?:匹|HP|hp)/i, field: 'horsepower', confidence: 0.85 },
  { regex: /(?:制冷量|Cooling)[:\s]*(\d+)\s*(?:W|瓦)/i, field: 'coolingCapacity', confidence: 0.85 },
];

export class NameplateOCRService {
  private patterns: OCRPattern[];

  constructor(category: string = 'hvac') {
    // Load patterns based on equipment category
    this.patterns = this.getPatternsForCategory(category);
  }

  private getPatternsForCategory(category: string): OCRPattern[] {
    switch (category) {
      case 'hvac':
        return HVAC_PATTERNS;
      // Add more categories as needed
      default:
        return HVAC_PATTERNS;
    }
  }

  /**
   * Process OCR result and extract structured data
   */
  processOCRResult(rawText: string): NameplateOCRResult {
    const fields: Record<string, string> = {};
    let totalConfidence = 0;
    let matchCount = 0;

    for (const pattern of this.patterns) {
      const match = rawText.match(pattern.regex);
      if (match) {
        fields[pattern.field] = match[1].trim();
        totalConfidence += pattern.confidence;
        matchCount++;
      }
    }

    const confidence = matchCount > 0 ? totalConfidence / matchCount : 0;

    return {
      brand: fields.brand,
      model: fields.model,
      refrigerant: fields.refrigerant,
      voltage: fields.voltage,
      horsepower: fields.horsepower,
      coolingCapacity: fields.coolingCapacity,
      confidence,
    };
  }

  /**
   * Post-process OCR result (normalize values)
   */
  postProcess(result: NameplateOCRResult): NameplateOCRResult {
    const processed = { ...result };

    // Normalize refrigerant code
    if (processed.refrigerant) {
      processed.refrigerant = processed.refrigerant.toUpperCase().replace(/\s/g, '');
    }

    // Convert horsepower to number string
    if (processed.horsepower) {
      processed.horsepower = parseFloat(processed.horsepower).toString();
    }

    return processed;
  }
}

export const nameplateOCRService = new NameplateOCRService();
