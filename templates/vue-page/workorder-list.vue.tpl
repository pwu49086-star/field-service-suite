<script setup lang="ts">
/**
 * Work Order List Page Template
 * Follows: ui-rules.md, workflow-rules.md
 */

import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useWorkOrderStore } from '@/stores/workOrderStore';
import type { WorkOrder, WorkOrderStatus } from '@/types';

const router = useRouter();
const workOrderStore = useWorkOrderStore();

const searchQuery = ref('');
const activeTab = ref<WorkOrderStatus | 'all'>('all');

const statusTabs = [
  { key: 'all' as const, label: '全部' },
  { key: 'pending' as const, label: '待处理' },
  { key: 'in_progress' as const, label: '进行中' },
  { key: 'completed' as const, label: '已完成' },
];

const statusColors: Record<string, string> = {
  draft: 'bg-gray-100 text-gray-700',
  pending: 'bg-amber-50 text-amber-700',
  in_progress: 'bg-blue-50 text-blue-700',
  paused: 'bg-orange-50 text-orange-700',
  pending_parts: 'bg-purple-50 text-purple-700',
  pending_quote: 'bg-yellow-50 text-yellow-700',
  pending_payment: 'bg-pink-50 text-pink-700',
  completed: 'bg-green-50 text-green-700',
  cancelled: 'bg-red-50 text-red-700',
};

const statusLabels: Record<string, string> = {
  draft: '草稿',
  pending: '待处理',
  in_progress: '进行中',
  paused: '已暂停',
  pending_parts: '等配件',
  pending_quote: '等报价',
  pending_payment: '等收款',
  completed: '已完成',
  cancelled: '已取消',
};

const filteredOrders = computed(() => {
  let items = workOrderStore.workorders;
  if (activeTab.value !== 'all') {
    items = items.filter(w => w.status === activeTab.value);
  }
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase();
    items = items.filter(w =>
      w.orderNo.toLowerCase().includes(q) ||
      w.description?.toLowerCase().includes(q)
    );
  }
  return items;
});

function navigateToDetail(id: string) {
  router.push(`/work-orders/${id}`);
}

onMounted(async () => {
  await workOrderStore.fetchAll();
});
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
      <div class="flex items-center justify-between">
        <h1 class="text-lg font-semibold text-gray-900">工单列表</h1>
        <button
          @click="router.push('/work-orders/new')"
          class="px-3 py-1.5 bg-blue-600 text-white text-sm rounded-lg"
        >
          新建
        </button>
      </div>

      <!-- Search -->
      <div class="mt-3">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="搜索工单号或描述..."
          class="w-full px-4 py-3 bg-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <!-- Status Tabs -->
      <div class="mt-3 flex gap-2 overflow-x-auto pb-1">
        <button
          v-for="tab in statusTabs"
          :key="tab.key"
          @click="activeTab = tab.key"
          :class="[
            'px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors',
            activeTab === tab.key
              ? 'bg-blue-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          ]"
        >
          {{ tab.label }}
        </button>
      </div>
    </header>

    <!-- Content -->
    <main class="flex-1 overflow-y-auto px-4 py-3">
      <div v-if="filteredOrders.length === 0" class="flex flex-col items-center justify-center py-16">
        <div class="text-6xl mb-4">📋</div>
        <p class="text-gray-500 text-sm">暂无工单</p>
      </div>

      <div v-else class="space-y-3">
        <div
          v-for="order in filteredOrders"
          :key="order.id"
          @click="navigateToDetail(order.id)"
          class="bg-white rounded-xl border border-gray-200 p-4 active:bg-gray-50 transition-colors cursor-pointer"
        >
          <div class="flex items-start justify-between mb-2">
            <span class="text-xs text-gray-400 font-mono">{{ order.orderNo }}</span>
            <span :class="['px-2 py-0.5 rounded-full text-xs', statusColors[order.status]]">
              {{ statusLabels[order.status] }}
            </span>
          </div>
          <h3 class="text-sm font-medium text-gray-900">{{ order.description || '无描述' }}</h3>
          <div class="flex items-center gap-4 mt-2 text-xs text-gray-400">
            <span>{{ order.type === 'repair' ? '维修' : order.type === 'maintenance' ? '保养' : order.type }}</span>
            <span>{{ order.scheduledDate || '未排期' }}</span>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
