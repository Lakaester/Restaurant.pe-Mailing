// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import type { RouteRecordRaw } from 'vue-router'

const route: RouteRecordRaw[] = [
  {
    path: '/cose/atenciones/:ticketId(\\d+)?',
    name: 'CoseAtenciones',
    component: () => import('./views/CoseAtencionesView.vue'),
    // Atenciones es la pantalla de entrada de los asesores.
    // Esta ruta se registra antes que Dashboard en el glob de páginas.
    alias: '/',
    props: true,
    meta: {
      title: __('Atenciones'),
      requiresAuth: true,
      icon: 'all-tickets',
      requiredPermission: ['ticket.agent'],
      mainNavigation: true,
      order: 100,
      pageKey: 'cose-atenciones',
      permanentItem: true,
    },
  },
]

export default route
