// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import type { RouteRecordRaw } from 'vue-router'

const route: RouteRecordRaw[] = [
  {
    path: '/cose/sla',
    name: 'CoseSla',
    component: () => import('./views/CoseSlaView.vue'),
    meta: {
      title: __('SLA'),
      requiresAuth: true,
      icon: 'all-tickets',
      requiredPermission: ['ticket.agent'],
      mainNavigation: true,
      order: 210,
      pageKey: 'cose-sla',
      permanentItem: true,
    },
  },
]

export default route
