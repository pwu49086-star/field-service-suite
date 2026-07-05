# Attachment Model

## Overview

Unified attachment system for all file types. Any business entity can reference attachments.

## Supported Types

| Type | Extensions | Max Size | Processing |
|------|-----------|---------|------------|
| image | jpg, png, webp | 5MB raw → 500KB compressed | Compress, thumbnail, EXIF |
| video | mp4, webm | 50MB | Thumbnail extraction |
| pdf | pdf | 10MB | Preview |
| audio | mp3, wav, webm | 20MB | Waveform |
| document | doc, txt | 10MB | Text extraction |

## Association Model

Attachments are linked to entities via `EntityAttachment`:

```
Attachment (file data)
    ↕ EntityAttachment (join table)
Asset / WorkOrder / Customer / TimelineEvent / Part
```

**Purposes**: nameplate, photo_before, photo_after, photo_site, signature, receipt, document, other

## Image Processing Pipeline

```
Camera → Resize (800px) → Compress (80%) → Thumbnail (200px) → EXIF → Store → Queue Upload
```

## OCR Trigger

When `purpose === 'nameplate'`, automatically trigger OCR engine to extract asset fields.
