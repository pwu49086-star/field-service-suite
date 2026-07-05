<script setup lang="ts">
/**
 * Scanner Page Template
 * Follows: scanner-rules.md, ui-rules.md
 */

import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useScanner } from '@/composables/useScanner';
import { useAssetStore } from '@/stores/assetStore';

const router = useRouter();
const { startScan, stopScan, isScanning } = useScanner();
const assetStore = useAssetStore();

const scanResult = ref<string | null>(null);
const error = ref<string | null>(null);
const isProcessing = ref(false);

async function handleScan() {
  error.value = null;
  scanResult.value = null;
  isProcessing.value = true;

  try {
    const result = await startScan('scanner-container');
    if (!result) return;

    scanResult.value = result.value;

    // Try to find matching asset
    const asset = await assetStore.getBySerialNumber(result.value);
    if (asset) {
      router.replace(`/assets/${asset.id}`);
    } else {
      // Not found — show options
      // Stay on page to show options
    }
  } catch (err: any) {
    error.value = err.message || '扫码失败';
  } finally {
    isProcessing.value = false;
  }
}

function handleManualEntry() {
  router.push({ path: '/assets/new', query: { serialNumber: scanResult.value || '' } });
}

function handleSearch() {
  router.push({ path: '/assets', query: { q: scanResult.value || '' } });
}

onMounted(() => {
  handleScan();
});

onUnmounted(() => {
  stopScan();
});
</script>

<template>
  <div class="flex flex-col h-full bg-black">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-black/80 px-4 py-3">
      <div class="flex items-center gap-3">
        <button @click="router.back()" class="p-1 text-white">←</button>
        <h1 class="text-lg font-semibold text-white">扫码</h1>
      </div>
    </header>

    <!-- Scanner Area -->
    <div class="flex-1 relative">
      <div id="scanner-container" class="w-full h-full"></div>

      <!-- Scan Overlay -->
      <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="w-64 h-64 border-2 border-white/50 rounded-2xl">
          <div class="absolute top-0 left-0 w-8 h-8 border-t-2 border-l-2 border-blue-500 rounded-tl-lg"></div>
          <div class="absolute top-0 right-0 w-8 h-8 border-t-2 border-r-2 border-blue-500 rounded-tr-lg"></div>
          <div class="absolute bottom-0 left-0 w-8 h-8 border-b-2 border-l-2 border-blue-500 rounded-bl-lg"></div>
          <div class="absolute bottom-0 right-0 w-8 h-8 border-b-2 border-r-2 border-blue-500 rounded-br-lg"></div>
        </div>
      </div>
    </div>

    <!-- Result Area -->
    <div class="bg-white px-4 py-6 rounded-t-2xl">
      <!-- Error -->
      <div v-if="error" class="text-center">
        <p class="text-red-600 text-sm mb-4">{{ error }}</p>
        <button
          @click="handleScan"
          class="px-6 py-3 bg-blue-600 text-white rounded-xl text-sm font-medium"
        >
          重试
        </button>
      </div>

      <!-- Result Found -->
      <div v-else-if="scanResult" class="text-center">
        <p class="text-gray-500 text-sm mb-1">扫描结果</p>
        <p class="text-gray-900 font-mono text-lg mb-4">{{ scanResult }}</p>

        <div class="flex gap-3">
          <button
            @click="handleSearch"
            class="flex-1 py-3 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium"
          >
            搜索
          </button>
          <button
            @click="handleManualEntry"
            class="flex-1 py-3 bg-blue-600 text-white rounded-xl text-sm font-medium"
          >
            新建资产
          </button>
        </div>
      </div>

      <!-- Scanning -->
      <div v-else class="text-center">
        <div v-if="isProcessing" class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-3"></div>
        <p class="text-gray-500 text-sm">将二维码/条码放入扫描框内</p>
      </div>
    </div>
  </div>
</template>
