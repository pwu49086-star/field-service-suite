<script setup lang="ts">
/**
 * Asset List Page Template
 * 
 * Usage: Replace {{Asset}} with your entity name.
 * Follows: ui-rules.md, database-rules.md, offline-rules.md
 */

import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAssetStore } from '@/stores/assetStore';
import { useScanner } from '@/composables/useScanner';
import type { Asset, AssetFilter } from '@/types';

const router = useRouter();
const assetStore = useAssetStore();
const { startScan } = useScanner();

// State
const searchQuery = ref('');
const activeFilter = ref<string>('all');
const isLoading = ref(false);

// Computed
const filteredAssets = computed(() => {
  let items = assetStore.assets;
  if (activeFilter.value !== 'all') {
    items = items.filter(a => a.status === activeFilter.value);
  }
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    items = items.filter(a =>
      a.name.toLowerCase().includes(query) ||
      a.serialNumber.toLowerCase().includes(query)
    );
  }
  return items;
});

// Methods
async function handleScan() {
  try {
    const result = await startScan();
    if (result) {
      const asset = await assetStore.getBySerialNumber(result.value);
      if (asset) {
        router.push(`/assets/${asset.id}`);
      } else {
        // Asset not found — offer to create
        router.push({ path: '/assets/new', query: { serialNumber: result.value } });
      }
    }
  } catch (error) {
    console.error('Scan failed:', error);
  }
}

function navigateToDetail(id: string) {
  router.push(`/assets/${id}`);
}

function navigateToCreate() {
  router.push('/assets/new');
}

// Lifecycle
onMounted(async () => {
  isLoading.value = true;
  await assetStore.fetchAll();
  isLoading.value = false;
});
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
      <div class="flex items-center justify-between">
        <h1 class="text-lg font-semibold text-gray-900">资产列表</h1>
        <button
          @click="handleScan"
          class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"
          aria-label="扫码"
        >
          📷
        </button>
      </div>

      <!-- Search -->
      <div class="mt-3">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="搜索资产名称或序列号..."
          class="w-full px-4 py-3 bg-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <!-- Filters -->
      <div class="mt-3 flex gap-2 overflow-x-auto pb-1">
        <button
          v-for="filter in ['all', 'active', 'maintenance', 'inactive']"
          :key="filter"
          @click="activeFilter = filter"
          :class="[
            'px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors',
            activeFilter === filter
              ? 'bg-blue-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          ]"
        >
          {{ filter === 'all' ? '全部' : filter === 'active' ? '运行中' : filter === 'maintenance' ? '维护中' : '已停用' }}
        </button>
      </div>
    </header>

    <!-- Content -->
    <main class="flex-1 overflow-y-auto px-4 py-3">
      <!-- Loading -->
      <div v-if="isLoading" class="flex justify-center py-12">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredAssets.length === 0" class="flex flex-col items-center justify-center py-16">
        <div class="text-6xl mb-4">📦</div>
        <p class="text-gray-500 text-sm">暂无资产</p>
        <button
          @click="navigateToCreate"
          class="mt-4 px-6 py-2.5 bg-blue-600 text-white rounded-xl text-sm font-medium"
        >
          添加资产
        </button>
      </div>

      <!-- Asset List -->
      <div v-else class="space-y-3">
        <div
          v-for="asset in filteredAssets"
          :key="asset.id"
          @click="navigateToDetail(asset.id)"
          class="bg-white rounded-xl border border-gray-200 p-4 active:bg-gray-50 transition-colors cursor-pointer"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1 min-w-0">
              <h3 class="text-sm font-medium text-gray-900 truncate">{{ asset.name }}</h3>
              <p class="text-xs text-gray-500 mt-1">SN: {{ asset.serialNumber }}</p>
            </div>
            <span
              :class="[
                'px-2 py-0.5 rounded-full text-xs',
                asset.status === 'active' ? 'bg-green-50 text-green-700' :
                asset.status === 'maintenance' ? 'bg-amber-50 text-amber-700' :
                'bg-gray-100 text-gray-600'
              ]"
            >
              {{ asset.status === 'active' ? '运行中' : asset.status === 'maintenance' ? '维护中' : '已停用' }}
            </span>
          </div>
          <p class="text-xs text-gray-400 mt-2">
            安装日期: {{ asset.installDate || '未记录' }}
          </p>
        </div>
      </div>
    </main>

    <!-- FAB -->
    <button
      @click="navigateToCreate"
      class="fixed bottom-20 right-4 w-14 h-14 bg-blue-600 text-white rounded-full shadow-lg flex items-center justify-center text-2xl active:bg-blue-700 transition-colors"
      aria-label="添加资产"
    >
      +
    </button>
  </div>
</template>
