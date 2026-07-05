# Attachment System Rules

## Unified Attachment Model

All file-based assets (images, video, PDF, audio, document) use a single Attachment entity. Any business entity can reference attachments.

## Supported Types

| Type | MIME Types | Max Size | Processing |
|------|-----------|---------|------------|
| image | image/jpeg, image/png, image/webp | 5MB (raw), 500KB (compressed) | Compress, thumbnail, EXIF extraction |
| video | video/mp4, video/webm | 50MB | Thumbnail extraction |
| pdf | application/pdf | 10MB | Preview generation |
| audio | audio/mpeg, audio/wav, audio/webm | 20MB | Waveform preview |
| document | application/msword, text/plain | 10MB | Text extraction |

## Attachment Schema

```typescript
interface Attachment {
  id: string;              // UUID
  type: AttachmentType;    // 'image' | 'video' | 'pdf' | 'audio' | 'document'
  mimeType: string;        // 'image/jpeg'
  fileName: string;        // 'photo_001.jpg'
  fileSize: number;        // bytes
  url: string;             // Original file URL or blob reference
  thumbnailUrl?: string;   // Thumbnail URL (images/videos)
  storageType: 'local' | 'indexeddb' | 'cloud';
  createdAt: string;       // ISO datetime
}
```

## Entity Association

Attachments are linked to entities via a join record:

```typescript
interface EntityAttachment {
  id: string;
  attachmentId: string;           // → Attachment.id
  entityType: EntityType;         // 'asset' | 'workorder' | 'customer' | 'timeline_event' | 'part'
  entityId: string;               // UUID of the linked entity
  purpose: AttachmentPurpose;     // What this attachment represents
  sortOrder: number;              // Display order
  createdAt: string;
}

type AttachmentPurpose =
  | 'nameplate'          // 设备铭牌照片
  | 'photo_before'       // 维修前照片
  | 'photo_after'        // 维修后照片
  | 'photo_site'         // 现场环境照片
  | 'signature'          // 客户签名
  | 'receipt'            // 收据/发票
  | 'document'           // 合同/保修卡
  | 'other';             // 其他
```

## Image Processing Pipeline

```
Camera Capture / File Select
    ↓
Resize (max 800px width)
    ↓
Compress (80% JPEG quality)
    ↓
Generate Thumbnail (200px)
    ↓
Extract EXIF (GPS, timestamp)
    ↓
Store in IndexedDB (Blob)
    ↓
Queue for cloud upload (if online)
    ↓
Replace local URL with cloud URL (after upload)
```

## Storage Strategy

1. **Offline**: Store as IndexedDB Blob via Dexie
2. **Sync**: Upload to cloud storage when online
3. **After upload**: Replace local blob URL with cloud URL
4. **Cleanup**: Delete local blobs older than 30 days after successful upload
5. **Thumbnails**: Keep locally permanently (small size)

## OCR Trigger

When an attachment has `purpose: 'nameplate'`, automatically trigger the OCR engine:

```typescript
async function onAttachmentCreated(attachment: Attachment, entityAttachment: EntityAttachment) {
  if (entityAttachment.purpose === 'nameplate') {
    const ocrResult = await ocrEngine.recognize(attachment, 'nameplate');
    if (ocrResult.confidence > 0.7) {
      await autoPopulateAssetFields(entityAttachment.entityId, ocrResult.fields);
    } else {
      await showOCRConfirmation(entityAttachment.entityId, ocrResult);
    }
  }
}
```
