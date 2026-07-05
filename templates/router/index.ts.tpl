/**
 * Router Configuration Template
 * 
 * Follows: naming-rules.md, ui-rules.md
 * Standard route structure for field service app.
 */

import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  // ─── Home / Dashboard ─────────────────────────────────────────
  {
    path: '/',
    name: 'Home',
    component: () => import('@/pages/HomePage.vue'),
  },

  // ─── Work Orders ──────────────────────────────────────────────
  {
    path: '/work-orders',
    name: 'WorkOrderList',
    component: () => import('@/pages/WorkOrderList.vue'),
  },
  {
    path: '/work-orders/new',
    name: 'WorkOrderCreate',
    component: () => import('@/pages/WorkOrderCreate.vue'),
  },
  {
    path: '/work-orders/:id',
    name: 'WorkOrderDetail',
    component: () => import('@/pages/WorkOrderDetail.vue'),
    props: true,
  },

  // ─── Assets ───────────────────────────────────────────────────
  {
    path: '/assets',
    name: 'AssetList',
    component: () => import('@/pages/AssetList.vue'),
  },
  {
    path: '/assets/new',
    name: 'AssetCreate',
    component: () => import('@/pages/AssetCreate.vue'),
  },
  {
    path: '/assets/:id',
    name: 'AssetDetail',
    component: () => import('@/pages/AssetDetail.vue'),
    props: true,
  },

  // ─── Scanner ──────────────────────────────────────────────────
  {
    path: '/scan',
    name: 'Scanner',
    component: () => import('@/pages/ScannerPage.vue'),
  },

  // ─── Settings ─────────────────────────────────────────────────
  {
    path: '/me',
    name: 'Settings',
    component: () => import('@/pages/SettingsPage.vue'),
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
