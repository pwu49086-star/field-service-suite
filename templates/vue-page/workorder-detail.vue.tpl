<script setup lang="ts">
/**
 * Work Order Detail Page Template
 * Follows: ui-rules.md, workflow-rules.md, attachment-rules.md
 */

import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useWorkOrderStore } from '@/stores/workOrderStore';
import { useTimelineStore } from '@/stores/timelineStore';
import { useAttachmentService } from '@/services/attachmentService';
import type { WorkOrder, WorkOrderStatus } from '@/types';

const route = useRoute();
const router = useRouter();
const workOrderStore = useWorkOrderStore();
const timelineStore = useTimelineStore();
const attachmentService = useAttachmentService();

const workOrderId = route.params.id as string;
const isProcessing = ref(false);

const workorder = computed(() => workOrderStore.currentOrder);

const statusLabels: Record<string, string> = {
  draft: '草稿', pending: '待处理', in_progress: '进行中',
  paused: '已暂停', pending_parts: '等配件', pending_quote: '等报价',
  pending_payment: '等收款', completed: '已完成', cancelled: '已取消',
};

const statusColors: Record<string, string> = {
  draft: 'bg-gray-100 text-gray-700', pending: 'bg-amber-50 text-amber-700',
  in_progress: 'bg-blue-50 text-blue-700', completed: 'bg-green-50 text-green-700',
  cancelled: 'bg-red-50 text-red-700',
};

const nextActions = computed(() => {
  if (!workorder.value) return [];
  const status = workorder.value.status;
  const actions: { label: string; status: WorkOrderStatus; color: string }[] = [];
  if (status === 'pending') actions.push({ label: '开始处理', status: 'in_progress', color: 'bg-blue-600' });
  if (status === 'in_progress') {
    actions.push({ label: '需要配件', status: 'pending_parts', color: 'bg-purple-600' });
    actions.push({ label: '需要报价', status: 'pending_quote', color: 'bg-yellow-600' });
    actions.push({ label: '完成工单', status: 'completed', color: 'bg-green-600' });
  }
  if (status === 'pending_parts') actions.push({ label: '配件到位', status: 'in_progress', color: 'bg-blue-600' });
  if (status === 'pending_quote') actions.push({ label: '客户确认', status: 'in_progress', color: 'bg-blue-600' });
  return actions;
});

async function handleTransition(newStatus: WorkOrderStatus) {
  isProcessing.value = true;
  try {
    await workOrderStore.transitionStatus(workOrderId, newStatus);
  } catch (error) {
    console.error('Status transition failed:', error);
  } finally {
    isProcessing.value = false;
  }
}

async function handleCapturePhoto(purpose: string) {
  await attachmentService.captureAndAttach('image', workOrderId, 'workorder', purpose);
}

onMounted(async () => {
  await workOrderStore.fetchById(workOrderId);
  await timelineStore.fetchByWorkOrderId(workOrderId);
});
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
      <div class="flex items-center gap-3">
        <button @click="router.back()" class="p-1 text-gray-600">←</button>
        <div class="flex-1 min-w-0">
          <h1 class="text-lg font-semibold text-gray-900 truncate">
            {{ workorder?.orderNo || '工单详情' }}
          </h1>
        </div>
        <span v-if="workorder" :class="['px-2 py-0.5 rounded-full text-xs', statusColors[workorder.status]]">
          {{ statusLabels[workorder.status] }}
        </span>
      </div>
    </header>

    <!-- Content -->
    <main class="flex-1 overflow-y-auto px-4 py-3 space-y-3">
      <!-- Asset Info Card -->
      <div class="bg-white rounded-xl border border-gray-200 p-4" v-if="workorder">
        <h3 class="text-xs text-gray-400 mb-2">设备信息</h3>
        <p class="text-sm font-medium text-gray-900">{{ workorder.assetName }}</p>
        <p class="text-xs text-gray-500">SN: {{ workorder.assetSerialNumber }}</p>
        <p class="text-xs text-gray-500 mt-1">客户: {{ workorder.customerName }}</p>
      </div>

      <!-- Work Description -->
      <div class="bg-white rounded-xl border border-gray-200 p-4" v-if="workorder">
        <h3 class="text-xs text-gray-400 mb-2">工单内容</h3>
        <p class="text-sm text-gray-900">{{ workorder.description || '无描述' }}</p>
      </div>

      <!-- Parts Used -->
      <div class="bg-white rounded-xl border border-gray-200 p-4" v-if="workorder?.items?.length">
        <h3 class="text-xs text-gray-400 mb-2">费用明细</h3>
        <div class="space-y-1.5">
          <div v-for="item in workorder.items" :key="item.id" class="flex justify-between text-sm">
            <span class="text-gray-700">{{ item.description }}</span>
            <span class="text-gray-900">¥{{ item.amount }}</span>
          </div>
          <div class="border-t border-gray-100 pt-2 flex justify-between text-sm font-medium">
            <span>总计</span>
            <span>¥{{ workorder.totalAmount }}</span>
          </div>
        </div>
      </div>
    </main>

    <!-- Action Bar -->
    <div class="sticky bottom-0 bg-white border-t border-gray-200 px-4 py-3 space-y-2">
      <!-- Photo Actions -->
      <div class="flex gap-2">
        <button
          @click="handleCapturePhoto('photo_before')"
          class="flex-1 py-2.5 bg-gray-100 text-gray-700 rounded-xl text-sm active:bg-gray-200"
        >
          📷 拍照
        </button>
        <button
          @click="router.push('/scan')"
          class="flex-1 py-2.5 bg-gray-100 text-gray-700 rounded-xl text-sm active:bg-gray-200"
        >
          📱 扫码
        </button>
      </div>

      <!-- Status Actions -->
      <div v-if="nextActions.length" class="flex gap-2">
        <button
          v-for="action in nextActions"
          :key="action.status"
          @click="handleTransition(action.status)"
          :disabled="isProcessing"
          :class="[
            'flex-1 py-3 text-white rounded-xl text-sm font-medium active:opacity-80 transition-opacity',
            action.color
          ]"
        >
          {{ action.label }}
        </button>
      </div>
    </div>
  </div>
</template>
