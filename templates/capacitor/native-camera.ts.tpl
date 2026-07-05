/**
 * Native Camera Plugin Template
 * Unified camera interface for browser and Capacitor native app.
 */
export interface CameraPhoto { base64: string; webPath: string; format: string; width: number; height: number; }
export function isNativeApp(): boolean { return !!(window as any).Capacitor?.isNativePlatform?.(); }
export async function takePhoto(options: { quality?: number; source?: "camera" | "gallery" } = {}): Promise<CameraPhoto> {
  if (isNativeApp()) {
    const { Camera, CameraResultType, CameraSource } = await import("@capacitor/camera");
    const photo = await Camera.getPhoto({ quality: options.quality || 80, resultType: CameraResultType.Base64, source: options.source === "gallery" ? CameraSource.Photos : CameraSource.Camera });
    return { base64: photo.base64String || "", webPath: photo.webPath || "", format: "jpeg", width: photo.width || 0, height: photo.height || 0 };
  }
  return new Promise((resolve, reject) => {
    const input = document.createElement("input"); input.type = "file"; input.accept = "image/*"; if (options.source !== "gallery") input.capture = "environment";
    input.onchange = async () => { const file = input.files?.[0]; if (!file) return reject(new Error("No file")); const mod = await import("browser-image-compression"); const compressed = await mod.default(file, { maxWidthOrHeight: 800, initialQuality: 0.8, useWebWorker: true }); const reader = new FileReader(); reader.onloadend = () => { resolve({ base64: (reader.result as string).split(",")[1], webPath: URL.createObjectURL(compressed), format: "jpeg", width: 0, height: 0 }); }; reader.readAsDataURL(compressed); };
    input.click();
  });
}
