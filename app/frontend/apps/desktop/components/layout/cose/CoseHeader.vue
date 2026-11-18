<!-- Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'

import { useSessionStore } from '#shared/stores/session.ts'

const { user } = useSessionStore()

const route = useRoute()

// Navegación de producto C.O.S.E. Vive en el shell para que las etiquetas sean
// legibles aunque el rail nativo de Zammad esté colapsado.
const navegacion = [
  { texto: __('Atenciones'), to: '/desktop/', rutas: ['CoseAtenciones'] },
  { texto: __('SLA'), to: '/desktop/cose/sla', rutas: ['CoseSla'] },
  { texto: __('Visión general'), to: '/desktop/dashboard', rutas: ['Dashboard'] },
  {
    texto: __('Base de conocimiento'),
    to: '/desktop/knowledge-base',
    rutas: ['KnowledgeBase'],
  },
]

const esActiva = (item: { rutas: string[] }) => item.rutas.includes(String(route.name ?? ''))

// Servido directamente por Rails desde public/ (no lo procesa Vite).
const logoIcono = '/cose/logo-icono.png'

interface Contador {
  etiqueta: string
  valor: number | null
  color: string
}

const contadores = ref<Contador[]>([
  { etiqueta: 'Abiertas', valor: null, color: 'primary' },
  { etiqueta: 'Pendientes', valor: null, color: 'warning' },
  { etiqueta: 'Cerradas', valor: null, color: 'success' },
])

// El buscador de esta instancia solo resuelve `*`; los selectores por estado
// devuelven 0. Se cuenta sobre la página real (tope 200) sin inventar datos.
const consultarContadores = async () => {
  const respuesta = await fetch(
    '/api/v1/tickets/search?query=*&per_page=200&with_total_count=true',
    { headers: { Accept: 'application/json' }, credentials: 'same-origin' },
  )
  if (!respuesta.ok) throw new Error(String(respuesta.status))
  const datos = await respuesta.json()
  const tickets: Array<{ state_id?: number }> = Array.isArray(datos) ? datos : (datos.records ?? [])

  const porEstado = (ids: number[]) =>
    tickets.filter((ticket) => ids.includes(Number(ticket.state_id))).length

  const valores = [porEstado([1, 2]), porEstado([3, 6]), porEstado([4])]
  contadores.value.forEach((contador, indice) => {
    contador.valor = valores[indice]
  })
}

const cargarContadores = async () => {
  try {
    await consultarContadores()
    return
  } catch {
    // El backend puede tardar en el primer arranque; se reintenta una vez.
    await new Promise((listo) => setTimeout(listo, 2000))
  }

  try {
    await consultarContadores()
  } catch {
    contadores.value.forEach((contador) => {
      contador.valor = null
    })
  }
}

onMounted(cargarContadores)
</script>

<template>
  <div class="cose-shell">
    <header class="cose-header" data-test-id="cose-header">
      <div class="cose-header__brand">
        <img class="cose-header__logo" :src="logoIcono" alt="Restaurant.pe" />
        <div class="cose-header__nombres">
          <strong class="cose-header__producto">C.O.S.E.</strong>
          <span class="cose-header__unit"> Centro de Operaciones de Soporte Especializado </span>
        </div>
      </div>

      <div class="cose-header__indicadores" aria-label="Indicadores de atención">
        <span v-for="contador in contadores" :key="contador.etiqueta" class="cose-header__chip">
          <i class="cose-header__punto" :class="`cose-header__punto--${contador.color}`" />
          <b>{{ contador.valor === null ? '—' : contador.valor }}</b>
          <span>{{ contador.etiqueta }}</span>
        </span>
      </div>

      <div class="cose-header__usuario">
        <span class="cose-header__avatar">{{
          String(user?.fullname || '?')
            .split(' ')
            .slice(0, 2)
            .map((parte) => parte[0])
            .join('')
            .toUpperCase()
        }}</span>
        <span class="cose-header__nombre">{{ user?.fullname }}</span>
        <a class="cose-header__salir" href="/logout" :title="$t('Sign out')">{{
          $t('Sign out')
        }}</a>
      </div>
    </header>

    <nav class="cose-nav" aria-label="Navegación principal C.O.S.E.">
      <RouterLink
        v-for="item in navegacion"
        :key="item.to"
        :to="item.to"
        class="cose-nav__item"
        :class="{ 'cose-nav__item--activo': esActiva(item) }"
      >
        {{ item.texto }}
      </RouterLink>
    </nav>
  </div>
</template>

<style scoped>
.cose-shell {
  --cose-primary: #b45309;
  --cose-warning: #b54708;
  --cose-success: #1f7a5a;
  --cose-charcoal: #4c5b5f;
  --cose-muted: #6e7678;
  --cose-border: #e1e5e6;
  --cose-bg: #f5f6f5;

  display: flex;
  flex-direction: column;
  flex: 0 0 auto;
  background: #fff;
}

.cose-header {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px 20px;
  min-height: 56px;
  padding: 6px 16px;
  border-bottom: 1px solid var(--cose-border);
  background: #fff;
  color: var(--cose-charcoal);
  font-family: Montserrat, 'Fira Sans', sans-serif;
  font-size: 12px;
}

.cose-header__brand {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.cose-header__logo {
  width: 32px;
  height: 32px;
  object-fit: contain;
}

.cose-header__nombres {
  display: flex;
  flex-direction: column;
  line-height: 1.15;
}

.cose-header__producto {
  color: var(--cose-primary);
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.08em;
}

.cose-header__unit {
  color: var(--cose-muted);
  font-size: 10px;
  white-space: nowrap;
}

.cose-header__indicadores {
  display: flex;
  flex: 1 1 auto;
  flex-wrap: wrap;
  gap: 6px;
  justify-content: center;
}

.cose-header__chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border: 1px solid var(--cose-border);
  border-radius: 8px;
  background: var(--cose-bg);
  white-space: nowrap;
}

.cose-header__chip b {
  font-size: 13px;
}

.cose-header__chip span {
  color: var(--cose-muted);
}

.cose-header__punto {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--cose-muted);
}

.cose-header__punto--primary {
  background: var(--cose-primary);
}

.cose-header__punto--warning {
  background: var(--cose-warning);
}

.cose-header__punto--success {
  background: var(--cose-success);
}

.cose-header__usuario {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: auto;
}

.cose-header__avatar {
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--cose-primary);
  color: #fff;
  font-size: 11px;
  font-weight: 600;
}

.cose-header__nombre {
  max-width: 180px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.cose-header__salir {
  border: 1px solid var(--cose-border);
  border-radius: 6px;
  padding: 4px 8px;
  color: var(--cose-primary);
  text-decoration: none;
}

@media (min-width: 760px) {
  .cose-header {
    flex-wrap: nowrap;
    min-height: 56px;
    padding: 4px 12px;
  }

  .cose-header__chip {
    padding: 3px 8px;
  }

  .cose-header__usuario {
    flex: 0 0 auto;
  }
}

/* Barra de módulos: siempre visible y con etiquetas. */
.cose-nav {
  display: flex;
  align-items: center;
  gap: 2px;
  min-height: 36px;
  padding: 0 12px;
  border-bottom: 1px solid var(--cose-border);
  background: #fff;
  font-family: Montserrat, 'Fira Sans', sans-serif;
  font-size: 12px;
  flex: 0 0 auto;
  overflow-x: auto;
}

.cose-nav__item {
  position: relative;
  padding: 9px 12px 10px;
  color: var(--cose-muted);
  text-decoration: none;
  white-space: nowrap;
  border-radius: 6px 6px 0 0;
}

.cose-nav__item:hover {
  background: var(--cose-bg);
  color: var(--cose-charcoal);
}

.cose-nav__item--activo {
  color: var(--cose-primary);
  font-weight: 600;
}

.cose-nav__item--activo::after {
  content: '';
  position: absolute;
  left: 10px;
  right: 10px;
  bottom: 0;
  height: 2px;
  border-radius: 2px;
  background: var(--cose-primary);
}

@media (max-width: 1150px) {
  .cose-header__unit {
    display: none;
  }
}

@media (max-width: 860px) {
  .cose-header__nombre {
    display: none;
  }

  .cose-header__indicadores {
    justify-content: flex-start;
  }
}
</style>
