# Scanner Rules

## Supported Formats

| Format | Library | Use Case |
|--------|---------|----------|
| QR Code | html5-qrcode | Asset ID, work order URL, technician ID, parts |
| Data Matrix | html5-qrcode | Small labels on equipment |
| Code 128 | html5-qrcode | Parts barcodes, serial numbers |
| EAN-13 | html5-qrcode | Consumer product barcodes |
| Code 39 | html5-qrcode | Industrial labels |

## Scanner Interface

```typescript
interface ScannerService {
  startScan(containerId: string, options?: ScanOptions): Promise<ScanResult>;
  stopScan(): void;
  isScanning(): boolean;
}

interface ScanOptions {
  formats?: BarcodeFormat[];
  continuous?: boolean;       // Keep scanning after first result
  scanDelay?: number;         // ms between scans (continuous mode)
  facingMode?: 'user' | 'environment'; // Camera
}

interface ScanResult {
  value: string;              // Decoded value
  format: BarcodeFormat;      // QR_CODE, CODE_128, etc.
  timestamp: number;
}
```

## Scan-First Flow

Always prefer scanning over manual input:

```
User taps "Scan" button
    ↓
Start camera scanner
    ↓
Code detected
    ↓
Lookup in database
    ├── Found as Asset → Navigate to Asset detail
    ├── Found as Part → Add to parts list
    ├── Found as Work Order → Navigate to Work Order
    └── Not found → Show options:
        ├── "Create new Asset with this serial number"
        ├── "Search by this value"
        └── "Manual entry"
```

## Fallback Strategy

| Scenario | Action |
|----------|--------|
| Camera permission denied | Show manual input form |
| Barcode damaged/unreadable | Switch to manual serial number entry |
| No camera available (desktop) | Show file upload for barcode image |
| Scanner timeout (30s) | Prompt: "无法识别，手动输入？" |

## Continuous Scan Mode

For batch operations (inventory check, parts receiving):

1. Enable continuous scan mode
2. Each scan adds to a batch list
3. Show running count of scanned items
4. "Complete" button to finalize batch
5. Duplicate detection: warn if same code scanned twice

## Offline Behavior

Scanning works fully offline — all lookups are against local IndexedDB. No network required.
