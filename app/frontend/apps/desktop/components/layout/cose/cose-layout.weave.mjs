// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/**
 * C.O.S.E. — extensiones del layout de escritorio aplicadas en tiempo de
 * compilación (capa "addon weave" de Zammad, ver
 * .dev/agent_docs/frontend_addon_layer.md).
 *
 * Sustituye a los parches que antes modificaban directamente:
 *   - components/layout/LayoutPage.vue
 *   - components/layout/LayoutSidebar/LeftSidebar/LeftSidebarHeader.vue
 *
 * Los archivos del núcleo quedan idénticos a Zammad 7.2.3. Si una
 * actualización de Zammad cambia los anclajes usados aquí, la compilación
 * falla con un mensaje que apunta a este archivo (comportamiento buscado:
 * mejor un build roto que una interfaz rota en silencio).
 */

const LAYOUT_EXTERIOR_CLASS =
  'flex h-full max-h-full flex-col overflow-hidden print:h-auto print:max-h-none print:overflow-visible'

// Rejilla original de Zammad, pero ocupando el alto restante bajo la cabecera.
const LAYOUT_GRID_CLASS =
  'grid min-h-0 flex-1 grid-cols-(--grid-columns) grid-rows-[minmax(0,1fr)] overflow-y-clip duration-100 print:h-auto print:max-h-none print:grid-cols-1 print:overflow-visible'

export const addonWeaveRules = [
  {
    target: 'apps/desktop/components/layout/LayoutPage.vue',
    // Se añade al final del <script setup> original: reutiliza `watch`,
    // `onBeforeMount`, `isSmallestScreen` y `togglePrimaryNavSidebar`, ya
    // declarados por el núcleo.
    scriptSetup: [
      "import CoseHeader from '#desktop/components/layout/cose/CoseHeader.vue'",
      '',
      '// C.O.S.E.: navegación principal desplegada (con etiquetas) desde 768 px;',
      '// por debajo, el rail de iconos nativo de Zammad. Se registra después del',
      '// onBeforeMount del núcleo, por lo que prevalece en el estado inicial.',
      'onBeforeMount(() => {',
      "  togglePrimaryNavSidebar(isSmallestScreen.value, { storage: 'session' })",
      '  watch(isSmallestScreen, (isSmallest) => {',
      "    togglePrimaryNavSidebar(isSmallest, { storage: 'session' })",
      '  })',
      '})',
    ].join('\n'),
    template: [
      {
        // Contenedor exterior en columna: cabecera C.O.S.E. + rejilla de Zammad.
        match: { root: true, element: 'div' },
        wrap: {
          open: `<div class="${LAYOUT_EXTERIOR_CLASS}" data-test-id="cose-layout">\n<CoseHeader />\n`,
          close: '\n</div>',
        },
        setAttribute: { name: 'class', value: LAYOUT_GRID_CLASS },
      },
      {
        // El contenido debe poder encogerse dentro de la rejilla.
        match: { id: 'main-content' },
        setAttribute: { name: 'class', value: 'relative min-h-0 overflow-hidden' },
      },
    ],
  },
  {
    target: 'apps/desktop/components/layout/LayoutSidebar/LeftSidebar/LeftSidebarHeader.vue',
    // Servido por Rails desde public/; como expresión enlazada, Vite no intenta
    // resolverlo como módulo.
    scriptSetup: "const __coseLogoIcono = '/cose/logo-icono.png'",
    template: [
      {
        match: { component: 'CommonIcon', attr: { name: 'name', value: 'logo' } },
        replace:
          '<img :src="__coseLogoIcono" alt="C.O.S.E." class="cose-logo-sidebar" data-test-id="cose-sidebar-logo" />',
      },
    ],
  },
]
