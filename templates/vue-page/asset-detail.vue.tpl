<script setup lang="ts">
/**
 * Asset Detail Page Template
 * 
 * Shows asset info, timeline, and attachments.
 * Follows: ui-rules.md, timeline-rules.md, attachment-rules.md
 */

import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAssetStore } from '@/stores/assetStore';
import { useTimelineStore } from '@/stores/timelineStore';
import type { Asset, TimelineEvent } from '@/types';

const route = useRoute();
const router = useRouter();
const assetStore = useAssetStore();
const timelineStore = useTimelineStore();

const assetId = route.params.id as string;
const activeTab = ref<'timeline' | 'details' | 'attachments'>('timeline');

const asset = computed(() => assetStore.currentAsset);
const timeline = computed(() => timelineStore.events);

const timelineTypeIcons: Record<string, string> = {
  installation: '🔧',
  repair: '🔩',
  maintenance: '🧹',
  inspection: '🔍',
  quote: '💰',
  payment: '✅',
  callback: '📞',
  transfer: '📦',
  scrap: '🗑️',
  note: '📝',
};

onMounted(async () => {
  await assetStore.fetchById(assetId);
  await timelineStore.fetchByAssetId(assetId);
});

function goBack() {
  router.back();
}

function navigateToWorkOrder() {
  router.push({ path: '/work-orders/new', query: { assetId } });
}

function navigateToScan() {
  router.push('/scan');
}
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
      <div class="flex items-center gap-3">
        <button @click="goBack" class="p-1 text-gray-600">←</button>
        <h1 class="text-lg font-semibold text-gray-900 flex-1 truncate">
          {{ asset?.name || '资产详情' }}
        </h1>
        <span
          :class="[
            'px-2 py-0.5 rounded-full text-xs',
            asset?.status === 'active' ? 'bg-green-50 text-green-700' :
            asset?.status === 'maintenance' ? 'bg-amber-50 text-amber-700' :
            'bg-gray-100 text-gray-600'
          ]"
        >
          {{ asset?.status }}
        </span>
      </div>
    </header>

    <!-- Asset Summary Card -->
    <div class="px-4 py-3 bg-white border-b border-gray-100" v-if="asset">
      <div class="space-y-1.5">
        <div class="flex justify-between text-sm">
          <span class="text-gray-500">序列号</span>
          <span class="text-gray-900 font-mono">{{ asset.serialNumber }}</span>
        </div>
        <div class="flex justify-between text-sm">
          <span class="text-gray-500">品牌/型号</span>
          <span class="text-gray-900">{{ asset.brandName }} {{ asset.modelName }}</span>
        </div>
        <div class="flex justify-between text-sm">
          <span class="text-gray-500">安装日期</span>
          <span class="text-gray-900">{{ asset.installDate || '未记录' }}</span>
        </div>
        <div class="flex justify-between text-sm">
          <span class="text-gray-500">保修到期</span>
          <span :class="asset.warrantyExpired ? 'text-red-600' : 'text-gray-900'">
            {{ asset.warrantyExpiry || '未记录' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Tab Bar -->
    <div class="flex border-b border-gray-200 bg-white">
      <button
        v-for="tab in ['timeline', 'details', 'attachments'] as const"
        :key="tab"
        @click="activeTab = tab"
        :class="[
          'flex-1 py-3 text-sm font-medium text-center border-b-2 transition-colors',
          activeTab === tab
            ? 'border-blue-600 text-blue-600'
            : 'border-transparent text-gray-500'
        ]"
      >
        {{ tab === 'timeline' ? '时间线' : tab === 'details' ? '详情' : '附件' }}
      </button>
    </div>

    <!-- Tab Content -->
    <main class="flex-1 overflow-y-auto">
      <!-- Timeline Tab -->
      <div v-if="activeTab === 'timeline'" class="px-4 py-3">
        <div v-if="timeline.length === 0" class="text-center py-12 text-gray-400 text-sm">
          暂无事件记录
        </div>
        <div v-else class="relative">
          <div class="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>
          <div
            v-for="event in timeline"
            :key="event.id"
            class="relative pl-10 pb-6"
          >
            <div class="absolute left-2.5 w-3 h-3 rounded-full bg-blue-500 border-2 border-white"></div>
            <div class="bg-white rounded-lg border border-gray-200 p-3">
              <div class="flex items-center gap-2 mb-1">
                <span>{{ timelineTypeIcons[event.type] || '📝' }}</span>
                <span class="text-xs text-gray-500">{{ event.timestamp }}</span>
              </div>
              <h4 class="text-sm font-medium text-gray-900">{{ event.title }}</h4>
              <p v-if="event.description" class="text-xs text-gray-500 mt-1">{{ event.description }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Details Tab -->
      <div v-if="activeTab === 'details'" class="px-4 py-3">
        <div class="bg-white rounded-xl border border-gray-200 p-4">
          <h3 class="text-sm font-medium text-gray-900 mb-3">行业扩展信息</h3>
          <div class="space-y-2">
            <div v-for="(value, key) in (asset?.extension || {})" :key="key" class="flex justify-between text-sm">
              <span class="text-gray-500">{{ key }}</span>
              <span class="text-gray-900">{{ value }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Attachments Tab -->
      <div v-if="activeTab === 'attachments'" class="px-4 py-3">
        <div class="text-center py-12 text-gray-400 text-sm">
          暂无附件
        </div>
      </div>
    </main>

    <!-- Action Bar -->
    <div class="sticky bottom-0 bg-white border-t border-gray-200 px-4 py-3 flex gap-3">
      <button
        @click="navigateToScan"
        class="flex-1 py-3 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium active:bg-gray-200"
      >
        📷 扫码
      </button>
      <button
        @click="navigateToWorkOrder"
        class="flex-1 py-3 bg-blue-600 text-white rounded-xl text-sm font-medium active:bg-blue-700"
      >
        创建工单
      </button>
    </div>
  </div>
</template>
