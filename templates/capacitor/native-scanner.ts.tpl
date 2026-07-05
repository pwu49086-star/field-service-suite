/**
 * Native Scanner Plugin Template
 * Unified barcode/QR scanner for browser and Capacitor native app.
 */
export interface NativeScanResult { value: string; format: string; }
export function isNativeApp(): boolean { return !!(window as any).Capacitor?.isNativePlatform?.(); }
export async function scanCode(): Promise<NativeScanResult> {
  if (isNativeApp()) {
    const { BarcodeScanner } = await import("@capacitor/barcode-scanner");
    const result = await BarcodeScanner.scan({ formats: "QR_CODE,DATA_MATRIX,CODE_128,EAN_13" });
    return { value: result.rawContent, format: result.format };
  }
  const { Html5Qrcode } = await import("html5-qrcode");
  return new Promise((resolve, reject) => {
    const scanner = new Html5Qrcode("scanner-container");
    scanner.start({ facingMode: "environment" }, { fps: 10, qrbox: { width: 250, height: 250 } }, (text, r) => { scanner.stop(); resolve({ value: text, format: r?.result?.format?.formatName || "unknown" }); }, () => {}).catch(reject);
  });
}
