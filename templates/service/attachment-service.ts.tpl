/**
 * Attachment Service Template
 * Follows: attachment-rules.md, performance-rules.md
 */

import { db } from '../db/database';
import type { Attachment, EntityAttachment } from '../types';

export class AttachmentService {
  async captureAndAttach(type: 'image' | 'video', entityId: string, entityType: EntityAttachment['entityType'], purpose: string): Promise<Attachment> {
    const file = await this.captureFromCamera(type);
    const processed = await this.processFile(file, type);
    const attachment = await this.createAttachment(processed, type);
    await this.linkToEntity(attachment.id, entityId, entityType, purpose);
    return attachment;
  }

  async getByEntity(entityId: string, entityType: string): Promise<Attachment[]> {
    const links = await db.entityAttachments.where('entityId').equals(entityId).and(l => l.entityType === entityType).toArray();
    const ids = links.map(l => l.attachmentId);
    return ids.length ? db.attachments.bulkGet(ids).then(a => a.filter(Boolean) as Attachment[]) : [];
  }

  async delete(attachmentId: string): Promise<void> {
    await db.attachments.delete(attachmentId);
    await db.entityAttachments.where('attachmentId').equals(attachmentId).delete();
  }

  // ─── Private ──────────────────────────────────────────────────

  private async captureFromCamera(type: string): Promise<File> {
    return new Promise((resolve, reject) => {
      const input = document.createElement('input');
      input.type = 'file'; input.capture = 'environment';
      input.accept = type === 'image' ? 'image/*' : 'video/*';
      input.onchange = () => { const f = input.files?.[0]; f ? resolve(f) : reject(new Error('No file')); };
      input.click();
    });
  }

  private async processFile(file: File, type: string) {
    if (type === 'image') {
      const mod = await import('browser-image-compression');
      const compressed = await mod.default(file, { maxWidthOrHeight: 800, initialQuality: 0.8, useWebWorker: true });
      const thumbnail = await mod.default(file, { maxWidthOrHeight: 200, initialQuality: 0.6, useWebWorker: true });
      return { blob: compressed, thumbnailBlob: thumbnail, fileName: file.name, mimeType: compressed.type, fileSize: compressed.size };
    }
    return { blob: file, thumbnailBlob: undefined, fileName: file.name, mimeType: file.type, fileSize: file.size };
  }

  private async createAttachment(processed: any, type: string): Promise<Attachment> {
    const url = URL.createObjectURL(processed.blob);
    const thumbnailUrl = processed.thumbnailBlob ? URL.createObjectURL(processed.thumbnailBlob) : undefined;
    const attachment: Attachment = {
      id: crypto.randomUUID(), type: type as Attachment['type'], mimeType: processed.mimeType,
      fileName: processed.fileName, fileSize: processed.fileSize, url, thumbnailUrl,
      storageType: 'local', createdAt: new Date().toISOString(), createdBy: 'current-user',
    };
    await db.attachments.add(attachment);
    await db.syncQueue.add({ entityType: 'attachment', entityId: attachment.id, action: 'create', data: attachment, timestamp: Date.now(), retryCount: 0, status: 'pending' });
    return attachment;
  }

  private async linkToEntity(attachmentId: string, entityId: string, entityType: string, purpose: string) {
    const count = await db.entityAttachments.where('entityId').equals(entityId).and(l => l.entityType === entityType).count();
    await db.entityAttachments.add({ id: crypto.randomUUID(), attachmentId, entityType, entityId, purpose, sortOrder: count + 1, createdAt: new Date().toISOString() });
  }
}

export const attachmentService = new AttachmentService();
