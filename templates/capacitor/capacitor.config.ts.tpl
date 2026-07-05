import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "com.example.fieldservice",
  appName: "Field Service",
  webDir: "dist",
  server: { androidScheme: "https" },
  plugins: {
    Camera: { quality: 80, allowEditing: false, resultType: "base64" },
    BarcodeScanner: { formats: "QR_CODE,DATA_MATRIX,CODE_128,EAN_13" },
    Geolocation: { enableHighAccuracy: true, timeout: 10000 },
    LocalNotifications: { smallIcon: "ic_stat_icon", iconColor: "#2563EB" },
  },
};

export default config;
