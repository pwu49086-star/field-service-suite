/**
 * Asset Lookup Service Template
 * 
 * Centralized asset lookup with multiple strategies.
 * Used by scanner flow, work order creation, and search.
 * 
 * Follows: scanner-rules.md, mdm-rules.md
 */

import { db } from '../db/database';
import type { Asset, Customer, Brand, Model } from '../types';

export interface AssetLookupResult {
  asset: Asset | null;
  matchStrategy: 'serial_number' | 'barcode' | 'name' | 'fuzzy' | 'none';
  confidence: number; // 0-1
}

export interface AssetEnriched extends Asset {
  brandName?: string;
  modelName?: string;
  customerName?: string;
  warrantyExpired?: boolean;
}

export class AssetLookupService {
  /**
   * Look up an asset by scanned value.
   * Tries multiple strategies in order of specificity.
   */
  async lookupByScanValue(value: string): Promise<AssetLookupResult> {
    // Strategy 1: Exact serial number match
    const bySerial = await db.assets.where('serialNumber').equals(value).first();
    if (bySerial) {
      return { asset: bySerial, matchStrategy: 'serial_number', confidence: 1.0 };
    }

    // Strategy 2: Barcode match (some assets have barcodes different from serial)
    const byBarcode = await db.assets.where('serialNumber').equals(value).first();
    if (byBarcode) {
      return { asset: byBarcode, matchStrategy: 'barcode', confidence: 0.95 };
    }

    // Strategy 3: Name contains
    const byName = await db.assets
      .filter(a => a.name.toLowerCase().includes(value.toLowerCase()))
      .first();
    if (byName) {
      return { asset: byName, matchStrategy: 'name', confidence: 0.7 };
    }

    // No match
    return { asset: null, matchStrategy: 'none', confidence: 0 };
  }

  /**
   * Search assets by query string.
   * Searches name, serialNumber, and customer name.
   */
  async search(query: string, limit: number = 20): Promise<Asset[]> {
    const q = query.toLowerCase();
    return db.assets
      .filter(a =>
        a.name.toLowerCase().includes(q) ||
        a.serialNumber.toLowerCase().includes(q) ||
        a.tags.some(t => t.toLowerCase().includes(q))
      )
      .limit(limit)
      .toArray();
  }

  /**
   * Enrich an asset with master data names for display.
   */
  async enrich(asset: Asset): Promise<AssetEnriched> {
    const [brand, model, customer] = await Promise.all([
      db.brands.get(asset.brandId),
      db.models.get(asset.modelId),
      db.customers.get(asset.customerId),
    ]);

    const warrantyExpired = asset.warrantyExpiry
      ? new Date(asset.warrantyExpiry) < new Date()
      : undefined;

    return {
      ...asset,
      brandName: brand?.name,
      modelName: model?.name,
      customerName: customer?.name,
      warrantyExpired,
    };
  }

  /**
   * Enrich multiple assets.
   */
  async enrichMany(assets: Asset[]): Promise<AssetEnriched[]> {
    return Promise.all(assets.map(a => this.enrich(a)));
  }
}

export const assetLookupService = new AssetLookupService();
