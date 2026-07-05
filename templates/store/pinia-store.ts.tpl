/**
 * Pinia Store Template
 * 
 * Follows: coding-rules.md, database-rules.md
 * Reactive bridge between UI and Service layer.
 */

import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { workOrderService } from '@/services/workOrderService';
import { db } from '@/db/database';
import type { WorkOrder, WorkOrderStatus, WorkOrderDisplay } from '@/types';

export const useWorkOrderStore = defineStore('workOrder', () => {
  // ─── State ─────────────────────────────────────────────────────

  const workorders = ref<WorkOrderDisplay[]>([]);
  const currentOrder = ref<WorkOrderDisplay | null>(null);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  // ─── Getters ───────────────────────────────────────────────────

  const pendingCount = computed(() =>
    workorders.value.filter(w => w.status === 'pending').length
  );

  const inProgressCount = computed(() =>
    workorders.value.filter(w => w.status === 'in_progress').length
  );

  const todayOrders = computed(() => {
    const today = new Date().toISOString().slice(0, 10);
    return workorders.value.filter(w => w.scheduledDate === today);
  });

  // ─── Enrichment (join master data names for display) ────────────

  async function enrichOrder(order: WorkOrder): Promise<WorkOrderDisplay> {
    const [asset, customer, technician] = await Promise.all([
      db.assets.get(order.assetId),
      db.customers.get(order.customerId),
      order.technicianId ? db.technicians.get(order.technicianId) : Promise.resolve(undefined),
    ]);
    return {
      ...order,
      assetName: asset?.name,
      assetSerialNumber: asset?.serialNumber,
      customerName: customer?.name,
      technicianName: technician?.name,
    };
  }

  // ─── Actions ───────────────────────────────────────────────────

  async function fetchAll(options?: { status?: WorkOrderStatus }) {
    isLoading.value = true;
    error.value = null;
    try {
      const orders = await workOrderService.list(options);
      workorders.value = await Promise.all(orders.map(enrichOrder));
    } catch (e: any) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  async function fetchById(id: string) {
    isLoading.value = true;
    error.value = null;
    try {
      const order = await workOrderService.getById(id);
      currentOrder.value = order ? await enrichOrder(order) : null;
    } catch (e: any) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  async function create(data: Parameters<typeof workOrderService.create>[0]) {
    isLoading.value = true;
    error.value = null;
    try {
      const order = await workOrderService.create(data);
      workorders.value.unshift(order);
      return order;
    } catch (e: any) {
      error.value = e.message;
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  async function transitionStatus(id: string, newStatus: WorkOrderStatus) {
    error.value = null;
    try {
      const updated = await workOrderService.transitionStatus(id, newStatus);
      const enriched = await enrichOrder(updated);
      const index = workorders.value.findIndex(w => w.id === id);
      if (index !== -1) workorders.value[index] = enriched;
      if (currentOrder.value?.id === id) currentOrder.value = enriched;
      return enriched;
    } catch (e: any) {
      error.value = e.message;
      throw e;
    }
  }

  function clearError() {
    error.value = null;
  }

  return {
    // State
    workorders,
    currentOrder,
    isLoading,
    error,
    // Getters
    pendingCount,
    inProgressCount,
    todayOrders,
    // Actions
    fetchAll,
    fetchById,
    create,
    transitionStatus,
    clearError,
  };
});
