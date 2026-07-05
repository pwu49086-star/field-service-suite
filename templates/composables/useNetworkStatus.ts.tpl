/**
 * Network Status Composable Template
 * 
 * Follows: offline-rules.md
 * Detects online/offline status and triggers sync on reconnect.
 */

import { ref, onMounted, onUnmounted } from 'vue';

export function useNetworkStatus() {
  const isOnline = ref(navigator.onLine);
  const wasOffline = ref(false);

  function handleOnline() {
    if (!isOnline.value) {
      wasOffline.value = true;
    }
    isOnline.value = true;
  }

  function handleOffline() {
    isOnline.value = false;
    wasOffline.value = false;
  }

  onMounted(() => {
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
  });

  onUnmounted(() => {
    window.removeEventListener('online', handleOnline);
    window.removeEventListener('offline', handleOffline);
  });

  return { isOnline, wasOffline };
}
