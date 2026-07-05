<script setup lang="ts">
/**
 * Timeline View Page Template
 * Follows: timeline-rules.md, ui-rules.md
 */

import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useTimelineStore } from '@/stores/timelineStore';
import type { TimelineEvent, TimelineEventType } from '@/types';

const route = useRoute();
const timelineStore = useTimelineStore();

const assetId = route.params.assetId as string;
const activeFilter = ref<TimelineEventType | 'all'>('all');

const eventTypes = [
  { key: 'all' as const, label: '全部', icon: '📋' },
  { key: 'installation' as const, label: '安装', icon: '🔧' },
  { key: 'repair' as const, label: '维修', icon: '🔩' },
  { key: 'maintenance' as const, label: '保养', icon: '🧹' },
  { key: 'inspection' as const, label: '巡检', icon: '🔍' },
  { key: 'quote' as const, label: '报价', icon: '💰' },
  { key: 'payment' as const, label: '收款', icon: '✅' },
  { key: 'callback' as const, label: '回访', icon: '📞' },
];

const filteredEvents = computed(() => {
  if (activeFilter.value === 'all') return timelineStore.events;
  return timelineStore.events.filter(e => e.type === activeFilter.value);
});

const groupedEvents = computed(() => {
  const groups: Record<string, TimelineEvent[]> = {};
  const today = new Date().toDateString();
  const yesterday = new Date(Date.now() - 86400000).toDateString();

  for (const event of filteredEvents.value) {
    const date = new Date(event.timestamp).toDateString();
    let label: string;
    if (date === today) label = '今天';
    else if (date === yesterday) label = '昨天';
    else label = new Date(event.timestamp).toLocaleDateString('zh-CN');

    if (!groups[label]) groups[label] = [];
    groups[label].push(event);
  }
  return groups;
});

onMounted(async () => {
  await timelineStore.fetchByAssetId(assetId);
});
</script>

<template>
  <div class="flex flex-col h-full">
    <!-- Header -->
    <header class="sticky top-0 z-10 bg-white border-b border-gray-200 px-4 py-3">
      <h1 class="text-lg font-semibold text-gray-900">资产时间线</h1>

      <!-- Filter Chips -->
      <div class="mt-3 flex gap-2 overflow-x-auto pb-1">
        <button
          v-for="type in eventTypes"
          :key="type.key"
          @click="activeFilter = type.key"
          :class="[
            'px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors',
            activeFilter === type.key
              ? 'bg-blue-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          ]"
        >
          {{ type.icon }} {{ type.label }}
        </button>
      </div>
    </header>

    <!-- Timeline -->
    <main class="flex-1 overflow-y-auto px-4 py-3">
      <div v-if="filteredEvents.length === 0" class="text-center py-16 text-gray-400 text-sm">
        暂无事件记录
      </div>

      <div v-else>
        <div v-for="(events, dateLabel) in groupedEvents" :key="dateLabel" class="mb-6">
          <h3 class="text-xs font-medium text-gray-400 mb-3 sticky top-0 bg-gray-50 py-1 px-2 rounded">
            {{ dateLabel }}
          </h3>

          <div class="relative">
            <div class="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>

            <div v-for="event in events" :key="event.id" class="relative pl-10 pb-4">
              <div class="absolute left-2.5 w-3 h-3 rounded-full bg-blue-500 border-2 border-white"></div>

              <div class="bg-white rounded-lg border border-gray-200 p-3 active:bg-gray-50">
                <div class="flex items-center justify-between mb-1">
                  <span class="text-xs text-gray-400">
                    {{ new Date(event.timestamp).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }) }}
                  </span>
                  <span v-if="event.technicianName" class="text-xs text-gray-400">
                    {{ event.technicianName }}
                  </span>
                </div>
                <h4 class="text-sm font-medium text-gray-900">{{ event.title }}</h4>
                <p v-if="event.description" class="text-xs text-gray-500 mt-1">{{ event.description }}</p>

                <!-- Attachment Previews -->
                <div v-if="event.attachmentIds?.length" class="flex gap-2 mt-2">
                  <div
                    v-for="attId in event.attachmentIds.slice(0, 3)"
                    :key="attId"
                    class="w-12 h-12 bg-gray-100 rounded-lg overflow-hidden"
                  >
                    <img :src="attId" class="w-full h-full object-cover" loading="lazy" />
                  </div>
                  <div
                    v-if="event.attachmentIds.length > 3"
                    class="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center text-xs text-gray-500"
                  >
                    +{{ event.attachmentIds.length - 3 }}
                  </div>
                </div>

                <!-- Parts Used -->
                <div v-if="event.partsUsed?.length" class="mt-2 text-xs text-gray-500">
                  配件: {{ event.partsUsed.map(p => p.partName).join(', ') }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
