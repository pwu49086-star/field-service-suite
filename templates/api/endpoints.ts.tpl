/**
 * API Endpoint Definitions Template
 */
export const API_ENDPOINTS = {
  customers: { list: "GET /api/v1/customers", get: "GET /api/v1/customers/:id", create: "POST /api/v1/customers", update: "PUT /api/v1/customers/:id" },
  assets: { list: "GET /api/v1/assets", get: "GET /api/v1/assets/:id", create: "POST /api/v1/assets", bySerial: "GET /api/v1/assets/serial/:serialNumber", timeline: "GET /api/v1/assets/:id/timeline" },
  workorders: { list: "GET /api/v1/workorders", get: "GET /api/v1/workorders/:id", create: "POST /api/v1/workorders", transition: "PUT /api/v1/workorders/:id/transition" },
  timeline: { list: "GET /api/v1/timeline", byAsset: "GET /api/v1/timeline?assetId=:id", create: "POST /api/v1/timeline" },
  sync: { push: "POST /api/v1/sync/push", pull: "GET /api/v1/sync/pull?since=:timestamp" },
  auth: { login: "POST /api/v1/auth/login", refresh: "POST /api/v1/auth/refresh" },
} as const;
