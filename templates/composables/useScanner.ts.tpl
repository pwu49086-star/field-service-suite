/**
 * Scanner Composable Template
 * 
 * Follows: scanner-rules.md, offline-rules.md
 * Wraps html5-qrcode with fallback strategies.
 */

import { ref, onUnmounted } from 'vue';

export interface ScanResult {
  value: string;
  format: string;
  timestamp: number;
}

export function useScanner() {
  const isScanning = ref(false);
  const error = ref<string | null>(null);
  let scanner: any = null;

  async function startScan(containerId: string, options?: {
    formats?: string[];
    continuous?: boolean;
    scanDelay?: number;
  }): Promise<ScanResult | null> {
    error.value = null;
    isScanning.value = true;

    try {
      const { Html5Qrcode } = await import('html5-qrcode');
      scanner = new Html5Qrcode(containerId);

      const result = await scanner.start(
        { facingMode: 'environment' },
        {
          fps: 10,
          qrbox: { width: 250, height: 250 },
          aspectRatio: 1.0,
        },
        (decodedText: string, result: any) => {
          if (!options?.continuous) {
            scanner?.stop();
            isScanning.value = false;
          }
        },
        () => {} // Ignore errors during scanning
      );

      // Return first result
      return {
        value: result?.decodedText || '',
        format: result?.result?.format?.formatName || 'unknown',
        timestamp: Date.now(),
      };
    } catch (err: any) {
      error.value = err.message || '扫码失败';
      isScanning.value = false;
      return null;
    }
  }

  async function stopScan() {
    try {
      if (scanner) {
        await scanner.stop();
        scanner = null;
      }
    } catch {
      // Ignore stop errors
    }
    isScanning.value = false;
  }

  onUnmounted(() => {
    stopScan();
  });

  return { isScanning, error, startScan, stopScan };
}
