/**
 * Attachment Service Template
 * 
 * Follows: attachment-rules.md, performance-rules.md
 * Handles file capture, compression, storage, and OCR triggering.
 */

import { db } from '@/db/database';
import type { Attachment, EntityAttachment } from '@/db/database';

export class AttachmentService {
  /**
   * Capture a photo from camera and create an attachment
   */
  async captureAndAttach(
    type: 'image' | 'video',
    entityId: string,
    entityType: EntityAttachment['entityType'],
    purpose: EntityAttachment['purpose']
  ): Promise<Attachment> {
    // Trigger camera
    const file = await this.captureFromCamera(type);

    // Process the file
    const processed = await this.processFile(file, type);

    // Create attachment record
    const attachment = await this.createAttachment(processed, type);

    // Link to entity
    await this.linkToEntity(attachment.id, entityId, entityType, purpose);

    // Trigger OCR if nameplate
    if (purpose === 'nameplate') {
      await this.triggerOCR(attachment);
    }

    return attachment;
  }

  /**
   * Select files from gallery and create attachments
   */
  async selectAndAttach(
    entityId: string,
    entityType: EntityAttachment['entityType'],
    purpose: EntityAttachment['purpose']
  ): Promise<Attachment[]> {
    const files = await this.selectFromGallery();
    const attachments: Attachment[] = [];

    for (const file of files) {
      const type = file.type.startsWith('image/') ? 'image' as const :
                   file.type.startsWith('video/') ? 'video' as const :
                   'document' as const;

      const processed = await this.processFile(file, type);
      const attachment = await this.createAttachment(processed, type);
      await this.linkToEntity(attachment.id, entityId, entityType, purpose);
      attachments.push(attachment);
    }

    return attachments;
  }

  /**
   * Get all attachments for an entity
   */
  async getByEntity(entityId: string, entityType: string): Promise<Attachment[]> {
    const links = await db.entityAttachments
      .where('entityId').equals(entityId)
      .and(link => link.entityType === entityType)
      .toArray();

    const ids = links.map(l => l.attachmentId);
    if (ids.length === 0) return [];

    return db.attachments.bulkGet(ids).then(a => a.filter(Boolean) as Attachment[]);
  }

  /**
   * Delete an attachment and its entity link
   */
  async delete(attachmentId: string): Promise<void> {
    await db.attachments.delete(attachmentId);
    await db.entityAttachments.where('attachmentId').equals(attachmentId).delete();
  }

  // ─── Private Methods ──────────────────────────────────────────

  private async captureFromCamera(type: string): Promise<File> {
    return new Promise((resolve, reject) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.capture = 'environment';
      input.accept = type === 'image' ? 'image/*' : 'video/*';
      input.onchange = () => {
        const file = input.files?.[0];
        if (file) resolve(file);
        else reject(new Error('No file selected'));
      };
      input.click();
    });
  }

  private async selectFromGallery(): Promise<File[]> {
    return new Promise((resolve, reject) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.multiple = true;
      input.accept = 'image/*,video/*,application/pdf,audio/*';
      input.onchange = () => {
        resolve(Array.from(input.files || []));
      };
      input.click();
    });
  }

  private async processFile(file: File, type: string): Promise<ProcessedFile> {
    if (type === 'image') {
      return this.compressImage(file);
    }
    return {
      blob: file,
      fileName: file.name,
      mimeType: file.type,
      fileSize: file.size,
      width: undefined,
      height: undefined,
      thumbnailBlob: undefined,
    };
  }

  private async compressImage(file: File): Promise<ProcessedFile> {
    // Use browser-image-compression library
    const compressed = await import('browser-image-compression').then(mod =>
      mod.default(file, {
        maxWidthOrHeight: 800,
        initialQuality: 0.8,
        useWebWorker: true,
      })
    );

    const thumbnail = await import('browser-image-compression').then(mod =>
      mod.default(file, {
        maxWidthOrHeight: 200,
        initialQuality: 0.6,
        useWebWorker: true,
      })
    );

    // Get dimensions
    const dimensions = await this.getImageDimensions(compressed);

    return {
      blob: compressed,
      fileName: file.name,
      mimeType: compressed.type,
      fileSize: compressed.size,
      width: dimensions.width,
      height: dimensions.height,
      thumbnailBlob: thumbnail,
    };
  }

  private async getImageDimensions(blob: Blob): Promise<{ width: number; height: number }> {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        URL.revokeObjectURL(img.src);
        resolve({ width: img.width, height: img.height });
      };
      img.onerror = () => resolve({ width: 0, height: 0 });
      img.src = URL.createObjectURL(blob);
    });
  }

  private async createAttachment(processed: ProcessedFile, type: string): Promise<Attachment> {
    const url = URL.createObjectURL(processed.blob);
    const thumbnailUrl = processed.thumbnailBlob
      ? URL.createObjectURL(processed.thumbnailBlob)
      : undefined;

    const attachment: Attachment = {
      id: crypto.randomUUID(),
      type: type as Attachment['type'],
      mimeType: processed.mimeType,
      fileName: processed.fileName,
      fileSize: processed.fileSize,
      url,
      thumbnailUrl,
      storageType: 'local',
      width: processed.width,
      height: processed.height,
      createdAt: new Date().toISOString(),
      createdBy: 'current-user', // Replace with actual user ID
    };

    await db.attachments.add(attachment);
    await db.syncQueue.add({
      entityType: 'attachment',
      entityId: attachment.id,
      action: 'create',
      data: { ...attachment, blob: processed.blob },
      timestamp: Date.now(),
      retryCount: 0,
      status: 'pending',
    });

    return attachment;
  }

  private async linkToEntity(
    attachmentId: string,
    entityId: string,
    entityType: EntityAttachment['entityType'],
    purpose: EntityAttachment['purpose']
  ): Promise<void> {
    const count = await db.entityAttachments
      .where('entityId').equals(entityId)
      .and(l => l.entityType === entityType)
      .count();

    await db.entityAttachments.add({
      id: crypto.randomUUID(),
      attachmentId,
      entityType,
      entityId,
      purpose,
      sortOrder: count + 1,
      createdAt: new Date().toISOString(),
    });
  }

  private async triggerOCR(attachment: Attachment): Promise<void> {
    // Import OCR engine dynamically
    // This will be implemented by the OCR engine module
    console.log('OCR triggered for attachment:', attachment.id);
  }
}

interface ProcessedFile {
  blob: Blob;
  fileName: string;
  mimeType: string;
  fileSize: number;
  width?: number;
  height?: number;
  thumbnailBlob?: Blob;
}

export const attachmentService = new AttachmentService();
