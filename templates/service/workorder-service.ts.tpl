/**
 * Work Order Service Template
 * 
 * Follows: workflow-rules.md, mdm-rules.md, database-rules.md
 * Handles work order CRUD and state machine transitions.
 */

import { db } from '@/db/database';
import { MasterDataService } from './master-dataService';
import type { WorkOrder, WorkOrderStatus, WorkItem } from '@/db/database';

// ─── State Machine ────────────────────────────────────────────────

const TRANSITIONS: Record<string, string[]> = {
  draft:           ['pending', 'cancelled'],
  pending:         ['in_progress', 'cancelled'],
  in_progress:     ['paused', 'pending_parts', 'pending_quote', 'pending_payment', 'completed'],
  paused:          ['in_progress', 'cancelled'],
  pending_parts:   ['in_progress'],
  pending_quote:   ['in_progress', 'cancelled'],
  pending_payment: ['completed'],
  completed:       [],
  cancelled:       [],
};

function canTransition(from: WorkOrderStatus, to: WorkOrderStatus): boolean {
  return TRANSITIONS[from]?.includes(to) ?? false;
}

// ─── Service ──────────────────────────────────────────────────────

export class WorkOrderService extends MasterDataService<WorkOrder> {
  protected table = db.workorders;
  protected entityType = 'workorder';

  async create(data: Omit<WorkOrder, 'id' | 'createdAt' | 'updatedAt' | 'orderNo'>): Promise<WorkOrder> {
    const orderNo = await this.generateOrderNo();
    return super.create({ ...data, orderNo } as any);
  }

  async transitionStatus(id: string, newStatus: WorkOrderStatus): Promise<WorkOrder> {
    const order = await this.getById(id);
    if (!order) throw new Error(`WorkOrder ${id} not found`);

    if (!canTransition(order.status, newStatus)) {
      throw new Error(`Invalid transition: ${order.status} → ${newStatus}`);
    }

    const now = new Date().toISOString();
    const updates: Partial<WorkOrder> = {
      status: newStatus,
      updatedAt: now,
    };

    // Side effects for specific transitions
    if (newStatus === 'in_progress' && !order.startedAt) {
      updates.startedAt = now;
    }
    if (newStatus === 'completed') {
      updates.completedAt = now;
      if (order.startedAt) {
        updates.duration = Math.round(
          (new Date(now).getTime() - new Date(order.startedAt).getTime()) / 60000
        );
      }
    }

    const updated = await this.update(id, updates);

    // Create timeline event for status change
    await this.createTimelineEvent(updated, order.status, newStatus);

    return updated;
  }

  async assignTechnician(id: string, technicianId: string): Promise<WorkOrder> {
    return this.update(id, { technicianId } as any);
  }

  async addItems(id: string, newItems: WorkItem[]): Promise<WorkOrder> {
    const order = await this.getById(id);
    if (!order) throw new Error(`WorkOrder ${id} not found`);

    const items = [...order.items, ...newItems];
    const totalAmount = items.reduce((sum, item) => sum + item.amount, 0);

    return this.update(id, { items, totalAmount } as any);
  }

  async getByAssetId(assetId: string): Promise<WorkOrder[]> {
    return this.table.where('assetId').equals(assetId).reverse().sortBy('createdAt');
  }

  async getByCustomerId(customerId: string): Promise<WorkOrder[]> {
    return this.table.where('customerId').equals(customerId).reverse().sortBy('createdAt');
  }

  async getByStatus(status: WorkOrderStatus): Promise<WorkOrder[]> {
    return this.table.where('status').equals(status).reverse().sortBy('createdAt');
  }

  // ─── Private ──────────────────────────────────────────────────

  private async generateOrderNo(): Promise<string> {
    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10).replace(/-/g, '');
    const count = await this.table
      .where('createdAt')
      .startsWith(today.toISOString().slice(0, 10))
      .count();
    return `WO-${dateStr}-${String(count + 1).padStart(3, '0')}`;
  }

  private async createTimelineEvent(
    order: WorkOrder,
    fromStatus: WorkOrderStatus,
    toStatus: WorkOrderStatus
  ): Promise<void> {
    const statusLabels: Record<string, string> = {
      pending: '待处理',
      in_progress: '开始处理',
      paused: '已暂停',
      pending_parts: '等待配件',
      pending_quote: '等待报价确认',
      pending_payment: '等待收款',
      completed: '已完成',
      cancelled: '已取消',
    };

    await db.timelineEvents.add({
      id: crypto.randomUUID(),
      assetId: order.assetId,
      customerId: order.customerId,
      workorderId: order.id,
      type: order.type,
      title: `工单状态: ${statusLabels[toStatus] || toStatus}`,
      description: `从 ${statusLabels[fromStatus] || fromStatus} 变更为 ${statusLabels[toStatus] || toStatus}`,
      timestamp: new Date().toISOString(),
      technicianId: order.technicianId,
      status: toStatus === 'completed' || toStatus === 'cancelled' ? 'completed' : 'in_progress',
      metadata: { fromStatus, toStatus },
      attachmentIds: [],
      partsUsed: [],
      createdAt: new Date().toISOString(),
      createdBy: order.technicianId || 'system',
    });
  }
}

export const workOrderService = new WorkOrderService();
