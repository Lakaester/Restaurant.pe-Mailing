<!-- Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/ -->

<!--
  C.O.S.E. — Atenciones.
  Tres zonas, como el módulo Atenciones de C.O.S.E.: bandeja, conversación y
  panel operativo. Todos los datos y acciones van a la API REST de Zammad; la
  interfaz no da por exitosa una operación hasta que Zammad la confirma.
  El envío de correo está tras una barrera explícita (ver services/politicaEnvio.ts).
-->

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import { CATALOGO_COSE } from '../catalog/catalogo-cose.ts'
import { useAtenciones } from '../composables/useAtenciones.ts'
import {
  formatearFecha,
  grupoDeEstado,
  nombreDeSubcategoria,
  textoDeCuerpo,
  type FiltroCanal,
  type FiltroEstado,
} from '../services/atencionesDominio.ts'
import { VARIABLE_ENVIO } from '../services/politicaEnvio.ts'

const props = defineProps<{ ticketId?: string }>()
const router = useRouter()

const valorEnvio =
  (import.meta.env.VITE_COSE_ENVIO_CORREO as string | undefined) ??
  (import.meta.env as unknown as Record<string, string | undefined>)[VARIABLE_ENVIO]

const at = useAtenciones(valorEnvio)

type PestanaPanel = 'resumen' | 'actividad' | 'operacion' | 'historial'
const PESTANAS_PANEL: Array<{ valor: PestanaPanel; texto: string }> = [
  { valor: 'resumen', texto: 'Resumen' },
  { valor: 'actividad', texto: 'Actividad' },
  { valor: 'operacion', texto: 'Operación' },
  { valor: 'historial', texto: 'Historial' },
]
const pestanaPanel = ref<PestanaPanel>('resumen')
const modoComposer = ref<'respuesta' | 'nota'>('nota')
const textoComposer = ref('')
const categoriaSel = ref('')
const subcategoriaSel = ref('')
const dominioEditable = ref('')

const subcategorias = computed(
  () => CATALOGO_COSE.find((c) => c.categoria === categoriaSel.value)?.subcategorias ?? [],
)

const grupoActual = computed(() => grupoDeEstado(at.ticket.value?.state ?? ''))

const clasificacionActual = computed(() => {
  const value = at.ticket.value?.categoria_subcategoria
  if (!value) return null
  const categoria = at.ticket.value?.cose_categoria ?? null
  const nombre = nombreDeSubcategoria(categoria, value)
  return { categoria, value, nombre }
})

const puedeResponder = computed(() => at.envio.value === 'habilitado')

const etiquetaEstado = (nombre: string) => nombre.replace(/_/g, ' ')

function conteoDe(filtro: FiltroEstado): number {
  return filtro === 'todos' ? at.filas.value.length : at.conteos.value[filtro]
}

const estadosFiltro: Array<{ valor: FiltroEstado; texto: string }> = [
  { valor: 'todos', texto: 'Todas' },
  { valor: 'abiertos', texto: 'Abiertas' },
  { valor: 'pendientes', texto: 'Pendientes' },
  { valor: 'cerrados', texto: 'Cerradas' },
]

const canalesFiltro: Array<{ valor: FiltroCanal; texto: string }> = [
  { valor: 'todos', texto: __('Todos los canales') },
  { valor: 'email', texto: __('Correo') },
]

function abrir(id: number) {
  router.replace({ name: 'CoseAtenciones', params: { ticketId: String(id) } })
  void at.seleccionar(id)
}

function cerrarSeleccion() {
  router.replace({ name: 'CoseAtenciones' })
  void at.seleccionar(null)
}

async function enviar() {
  const ok =
    modoComposer.value === 'respuesta'
      ? await at.responder(textoComposer.value)
      : await at.agregarNota(textoComposer.value)
  if (ok) textoComposer.value = ''
}

async function guardarClasificacion() {
  if (await at.clasificar(categoriaSel.value, subcategoriaSel.value)) {
    categoriaSel.value = ''
    subcategoriaSel.value = ''
  }
}

async function guardarDominio() {
  if (await at.guardarDominio(dominioEditable.value)) {
    dominioEditable.value = at.ticket.value?.dominio ?? ''
  }
}

function adjuntosDe(articulo: {
  id: number
  attachments?: Array<number | { id: number; filename?: string }>
}) {
  return (articulo.attachments ?? []).map((adj) => {
    const id = typeof adj === 'number' ? adj : adj.id
    const nombre =
      typeof adj === 'number' ? `Adjunto #${adj}` : adj.filename || `Adjunto #${adj.id}`
    const ticketId = at.ticket.value?.id
    return {
      id,
      nombre,
      url: `/api/v1/ticket_attachment/${ticketId}/${articulo.id}/${id}`,
    }
  })
}

onMounted(async () => {
  await at.cargarBandeja()
  if (props.ticketId) void at.seleccionar(Number(props.ticketId))
})

watch(
  () => props.ticketId,
  (nuevo) => {
    const id = nuevo ? Number(nuevo) : null
    if (id !== at.seleccionadoId.value) void at.seleccionar(id)
  },
)

watch(
  () => at.ticket.value?.id,
  () => {
    dominioEditable.value = at.ticket.value?.dominio ?? ''
    categoriaSel.value = at.ticket.value?.cose_categoria ?? ''
    subcategoriaSel.value = ''
  },
)
</script>

<template>
  <div class="cose-at">
    <!-- ZONA 2: BANDEJA -->
    <aside class="cose-at__bandeja" aria-label="Bandeja de atenciones">
      <header class="cose-at__cabecera">
        <h2>Bandeja</h2>
        <span class="cose-at__contador">
          {{ at.filasVisibles.value.length }} de {{ at.total.value }}
        </span>
      </header>

      <div class="cose-at__buscador">
        <input
          v-model="at.filtros.texto"
          type="search"
          placeholder="Buscar cliente, asunto o ticket"
          aria-label="Buscar atención"
        />
      </div>

      <div class="cose-at__filtros">
        <button
          v-for="opcion in estadosFiltro"
          :key="opcion.valor"
          type="button"
          :class="[
            'cose-at__chip',
            { 'cose-at__chip--activo': at.filtros.estado === opcion.valor },
          ]"
          @click="at.filtros.estado = opcion.valor"
        >
          {{ opcion.texto }}
          <small>{{ conteoDe(opcion.valor) }}</small>
        </button>
      </div>

      <div class="cose-at__fila-opciones">
        <select v-model="at.filtros.canal" aria-label="Canal">
          <option v-for="c in canalesFiltro" :key="c.valor" :value="c.valor">{{ c.texto }}</option>
        </select>
        <label class="cose-at__check" for="filtro-solo-mias">
          <input id="filtro-solo-mias" v-model="at.filtros.soloMias" type="checkbox" />
          Asignadas a mí
        </label>
      </div>

      <p v-if="at.errorBandeja.value" class="cose-at__error" role="alert">
        {{ at.errorBandeja.value }}
      </p>
      <p v-else-if="at.cargandoBandeja.value && !at.filas.value.length" class="cose-at__vacio">
        Cargando atenciones…
      </p>
      <p v-else-if="!at.filasVisibles.value.length" class="cose-at__vacio">
        No hay atenciones con estos filtros.
      </p>

      <ul class="cose-at__lista">
        <li
          v-for="fila in at.filasVisibles.value"
          :key="fila.id"
          :class="[
            'cose-at__item',
            { 'cose-at__item--activo': at.seleccionadoId.value === fila.id },
          ]"
          role="button"
          tabindex="0"
          @click="abrir(fila.id)"
          @keydown.enter="abrir(fila.id)"
        >
          <div class="cose-at__item-top">
            <strong>#{{ fila.numero }}</strong>
            <span class="cose-at__hora">{{ formatearFecha(fila.actualizado) }}</span>
          </div>
          <div class="cose-at__cliente">{{ fila.cliente || 'Cliente sin nombre' }}</div>
          <div class="cose-at__asunto">{{ fila.titulo }}</div>
          <div class="cose-at__item-pie">
            <span :class="['cose-at__estado', `cose-at__estado--${fila.grupo}`]">
              {{ etiquetaEstado(fila.estado) }}
            </span>
            <span class="cose-at__responsable">{{ fila.propietario || 'Sin asignar' }}</span>
          </div>
        </li>
      </ul>

      <footer v-if="at.hayMas.value" class="cose-at__pie-bandeja">
        <button
          type="button"
          class="cose-at__btn-secundario"
          :disabled="at.cargandoBandeja.value"
          @click="at.cargarMas()"
        >
          {{ at.cargandoBandeja.value ? 'Cargando…' : 'Cargar más' }}
        </button>
        <span class="cose-at__meta"
          >{{ at.filas.value.length }} de {{ at.total.value }} cargadas</span
        >
      </footer>
    </aside>

    <!-- ZONA 3: CONVERSACIÓN -->
    <section class="cose-at__centro" aria-label="Conversación">
      <div v-if="!at.seleccionadoId.value" class="cose-at__vacio-grande">
        <h3>Seleccione una atención</h3>
        <p>La conversación, las respuestas y las acciones aparecen aquí.</p>
      </div>

      <template v-else>
        <header class="cose-at__ticket-cabecera">
          <div>
            <p class="cose-at__meta">
              Ticket <strong>#{{ at.ticket.value?.number ?? '…' }}</strong>
              ·
              <span :class="['cose-at__estado', `cose-at__estado--${grupoActual}`]">
                {{ at.ticket.value?.state ?? '' }}
              </span>
              · Canal: {{ at.ticket.value?.create_article_type ?? 'correo' }}
            </p>
            <h3>{{ at.ticket.value?.title ?? 'Cargando…' }}</h3>
            <p class="cose-at__meta">
              Cliente: {{ at.ticket.value?.customer ?? '—' }} ·
              {{ at.emailCli.value ?? 'Sin correo' }}
            </p>
          </div>
          <button type="button" class="cose-at__btn-secundario" @click="cerrarSeleccion">
            Cerrar
          </button>
        </header>

        <div class="cose-at__acciones">
          <button
            type="button"
            class="cose-at__btn-secundario"
            :disabled="at.operando.value || !at.ticket.value"
            @click="at.asignarAMi()"
          >
            Asignar a mí
          </button>
          <select
            class="cose-at__select"
            :disabled="at.operando.value || !at.ticket.value"
            aria-label="Cambiar estado"
            :value="at.ticket.value?.state_id ?? ''"
            @change="at.cambiarEstado(Number(($event.target as HTMLSelectElement).value))"
          >
            <option v-for="estado in at.estados.value" :key="estado.id" :value="estado.id">
              {{ etiquetaEstado(estado.name) }}
            </option>
          </select>
          <button
            type="button"
            class="cose-at__btn-primario"
            :disabled="at.operando.value || !at.ticket.value"
            @click="at.resolver()"
          >
            Resolver atención
          </button>
        </div>

        <p v-if="at.errorDetalle.value" class="cose-at__error" role="alert">
          {{ at.errorDetalle.value }}
        </p>
        <p v-if="at.errorOperacion.value" class="cose-at__error" role="alert">
          {{ at.errorOperacion.value }}
        </p>
        <p v-if="at.mensajeOperacion.value" class="cose-at__ok" role="status">
          {{ at.mensajeOperacion.value }}
        </p>

        <div class="cose-at__hilo">
          <p v-if="at.cargandoDetalle.value && !at.articulos.value.length" class="cose-at__vacio">
            Cargando conversación…
          </p>
          <article
            v-for="articulo in at.articulos.value"
            :id="`article-${articulo.id}`"
            :key="articulo.id"
            :class="['cose-at__mensaje', { 'cose-at__mensaje--nota': articulo.internal }]"
          >
            <header>
              <strong>{{ articulo.from || articulo.sender || 'Sistema' }}</strong>
              <span v-if="articulo.internal" class="cose-at__etiqueta">Nota interna</span>
              <span class="cose-at__hora">{{ formatearFecha(articulo.created_at) }}</span>
            </header>
            <div class="cose-at__cuerpo">
              {{ textoDeCuerpo(articulo.body, articulo.content_type) }}
            </div>
            <ul v-if="adjuntosDe(articulo).length" class="cose-at__adjuntos">
              <li v-for="adj in adjuntosDe(articulo)" :key="adj.id">
                <a :href="adj.url" target="_blank" rel="noopener">{{ adj.nombre }}</a>
              </li>
            </ul>
          </article>
        </div>

        <footer class="cose-at__composer">
          <div class="cose-at__pestanas" role="tablist">
            <button
              type="button"
              role="tab"
              :aria-selected="modoComposer === 'nota'"
              :class="{ activo: modoComposer === 'nota' }"
              @click="modoComposer = 'nota'"
            >
              Nota interna
            </button>
            <button
              type="button"
              role="tab"
              :aria-selected="modoComposer === 'respuesta'"
              :class="{ activo: modoComposer === 'respuesta' }"
              @click="modoComposer = 'respuesta'"
            >
              Responder por correo
              <span v-if="!puedeResponder" class="cose-at__etiqueta">bloqueado</span>
            </button>
          </div>
          <textarea
            v-model="textoComposer"
            rows="4"
            :aria-label="modoComposer === 'respuesta' ? 'Respuesta al cliente' : 'Nota interna'"
            :placeholder="
              modoComposer === 'respuesta'
                ? 'Escriba la respuesta al cliente…'
                : 'Nota visible solo para el equipo…'
            "
          />
          <p v-if="modoComposer === 'respuesta'" class="cose-at__aviso">
            {{
              puedeResponder
                ? `Destinatario: ${at.emailCli.value ?? 'sin correo registrado'}`
                : at.decidirRespuesta('x').motivo
            }}
          </p>
          <div class="cose-at__composer-pie">
            <span v-if="modoComposer === 'nota'" class="cose-at__meta">
              Las notas internas no se envían al cliente.
            </span>
            <button
              type="button"
              class="cose-at__btn-primario"
              :disabled="
                at.operando.value ||
                !at.ticket.value ||
                !textoComposer.trim() ||
                (modoComposer === 'respuesta' && !puedeResponder)
              "
              @click="enviar"
            >
              {{ modoComposer === 'respuesta' ? 'Enviar respuesta' : 'Guardar nota' }}
            </button>
          </div>
        </footer>
      </template>
    </section>

    <!-- ZONA 4: PANEL OPERATIVO -->
    <aside class="cose-at__panel" aria-label="Panel operativo">
      <template v-if="at.seleccionadoId.value && at.ticket.value">
        <section class="cose-at__bloque">
          <h4>Cliente</h4>
          <dl>
            <dt>Correo</dt>
            <dd>{{ at.emailCli.value ?? 'Sin correo' }}</dd>
            <dt>Dominio del correo</dt>
            <dd>{{ at.dominio.value || '—' }}</dd>
            <dt>Responsable</dt>
            <dd>{{ at.ticket.value.owner ?? 'Sin asignar' }}</dd>
            <dt>Actualizado</dt>
            <dd>{{ formatearFecha(at.ticket.value.updated_at) }}</dd>
          </dl>
        </section>

        <section class="cose-at__bloque">
          <h4>Registro operativo</h4>
          <p class="cose-at__meta">
            Clasificación vigente:
            <strong v-if="clasificacionActual">
              {{ clasificacionActual.categoria ?? 'Sin categoría' }} ·
              {{ clasificacionActual.nombre ?? clasificacionActual.value }}
            </strong>
            <span v-else>sin clasificar</span>
          </p>
          <p v-if="clasificacionActual && !clasificacionActual.categoria" class="cose-at__aviso">
            Este valor existe en dos categorías del catálogo y no tiene categoría guardada. Vuelva a
            clasificar para completar el par.
          </p>
          <label for="clasificacion-categoria">
            Categoría
            <select
              id="clasificacion-categoria"
              v-model="categoriaSel"
              @change="subcategoriaSel = ''"
            >
              <option value="">Seleccione…</option>
              <option v-for="c in CATALOGO_COSE" :key="c.categoria" :value="c.categoria">
                {{ c.categoria }}
              </option>
            </select>
          </label>
          <label for="clasificacion-subcategoria">
            Subcategoría
            <select
              id="clasificacion-subcategoria"
              v-model="subcategoriaSel"
              :disabled="!categoriaSel"
            >
              <option value="">Seleccione…</option>
              <option v-for="s in subcategorias" :key="s.value + s.label" :value="s.label">
                {{ s.label }}
              </option>
            </select>
          </label>
          <button
            type="button"
            class="cose-at__btn-primario"
            :disabled="at.operando.value || !subcategoriaSel"
            @click="guardarClasificacion"
          >
            Guardar clasificación
          </button>
        </section>

        <section class="cose-at__bloque">
          <h4>Dominio del cliente</h4>
          <label for="dominio-cliente">
            Dominio registrado
            <input
              id="dominio-cliente"
              v-model="dominioEditable"
              type="text"
              placeholder="restaurante.com.pe"
              aria-label="Dominio del cliente"
            />
          </label>
          <button
            type="button"
            class="cose-at__btn-secundario"
            :disabled="at.operando.value || !dominioEditable.trim()"
            @click="guardarDominio"
          >
            Guardar dominio
          </button>
        </section>

        <nav class="cose-at__pestanas-panel" role="tablist" aria-label="Información de la atención">
          <button
            v-for="p in PESTANAS_PANEL"
            :key="p.valor"
            type="button"
            role="tab"
            :aria-selected="pestanaPanel === p.valor"
            :class="{ activo: pestanaPanel === p.valor }"
            @click="pestanaPanel = p.valor"
          >
            {{ p.texto }}
          </button>
        </nav>

        <section v-if="pestanaPanel === 'resumen'" class="cose-at__bloque">
          <dl>
            <dt>Número</dt>
            <dd>#{{ at.ticket.value.number }}</dd>
            <dt>Estado</dt>
            <dd>{{ at.ticket.value.state }}</dd>
            <dt>Grupo</dt>
            <dd>{{ at.ticket.value.group ?? '—' }}</dd>
            <dt>Mensajes</dt>
            <dd>{{ at.articulos.value.length }}</dd>
            <dt>Adjuntos</dt>
            <dd>{{ at.articulos.value.reduce((n, a) => n + (a.attachments?.length ?? 0), 0) }}</dd>
          </dl>
          <p class="cose-at__meta">
            Integración SLA pendiente: el motor SLA aún no está conectado a esta vista. No se
            muestran plazos calculados.
          </p>
        </section>

        <section v-else-if="pestanaPanel === 'actividad'" class="cose-at__bloque">
          <ul class="cose-at__timeline">
            <li v-for="articulo in at.articulos.value" :key="articulo.id">
              <span class="cose-at__hora">{{ formatearFecha(articulo.created_at) }}</span>
              {{ articulo.internal ? 'Nota interna' : 'Mensaje' }} ·
              {{ articulo.from || articulo.sender || 'Sistema' }}
            </li>
          </ul>
        </section>

        <section v-else-if="pestanaPanel === 'operacion'" class="cose-at__bloque">
          <dl>
            <dt>Categoría</dt>
            <dd>{{ clasificacionActual?.categoria ?? 'Sin clasificar' }}</dd>
            <dt>Subcategoría</dt>
            <dd>
              {{ clasificacionActual?.nombre ?? clasificacionActual?.value ?? 'Sin clasificar' }}
            </dd>
            <dt>Dominio</dt>
            <dd>{{ at.ticket.value.dominio || 'Sin registrar' }}</dd>
            <dt>Responsable</dt>
            <dd>{{ at.ticket.value.owner ?? 'Sin asignar' }}</dd>
            <dt>Estado</dt>
            <dd>{{ at.ticket.value.state }}</dd>
          </dl>
        </section>

        <section v-else class="cose-at__bloque">
          <ul class="cose-at__timeline">
            <li v-for="(h, i) in at.historial.value" :key="h.id ?? i">
              <span class="cose-at__hora">{{ formatearFecha(h.created_at) }}</span>
              {{ h.attribute ?? h.type ?? 'Cambio' }}: {{ h.value_from ?? '—' }} →
              {{ h.value_to ?? '—' }}
            </li>
          </ul>
        </section>
      </template>
      <p v-else class="cose-at__vacio">
        El panel operativo muestra los datos de la atención seleccionada.
      </p>
    </aside>
  </div>
</template>

<style scoped>
.cose-at {
  --at-primary: var(--cose-primary, #b45309);
  --at-primary-hover: var(--cose-primary-hover, #92400e);
  --at-primary-10: var(--cose-primary-10, #fde8d7);
  --at-primary-5: var(--cose-primary-5, #fff6ee);
  --at-text: var(--cose-text, #4c5b5f);
  --at-muted: var(--cose-text-muted, #6e7678);
  --at-border: var(--cose-border, #e1e5e6);
  --at-bg: var(--cose-bg, #f5f6f5);
  --at-success: var(--cose-success, #1f7a5a);
  --at-warning: var(--cose-warning, #b54708);
  --at-danger: var(--cose-danger, #b42318);

  display: flex;
  flex: 1;
  min-height: 0;
  height: 100%;
  overflow: hidden;
  background: #fff;
  color: var(--at-text);
  font-size: 13px;
}

.cose-at__bandeja {
  width: clamp(210px, 18vw, 280px);
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  min-height: 0;
  border-right: 1px solid var(--at-border);
}

.cose-at__cabecera,
.cose-at__ticket-cabecera {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 10px 12px;
  border-bottom: 1px solid var(--at-border);
}

.cose-at__cabecera h2 {
  font-size: 13px;
  font-weight: 600;
  margin: 0;
}

.cose-at__contador,
.cose-at__meta,
.cose-at__hora {
  color: var(--at-muted);
  font-size: 11px;
}

.cose-at__buscador,
.cose-at__filtros,
.cose-at__fila-opciones {
  padding: 8px 10px;
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.cose-at__buscador input,
.cose-at__fila-opciones select,
.cose-at__select,
.cose-at__composer textarea,
.cose-at__panel select,
.cose-at__panel input {
  width: 100%;
  border: 1px solid var(--at-border);
  border-radius: 6px;
  padding: 6px 8px;
  background: #fff;
  color: var(--at-text);
  font: inherit;
}

.cose-at__chip {
  border: 1px solid var(--at-border);
  background: #fff;
  border-radius: 999px;
  padding: 3px 9px;
  cursor: pointer;
  color: var(--at-text);
}

.cose-at__chip--activo {
  background: var(--at-primary-10);
  border-color: var(--at-primary);
  color: var(--at-primary-hover);
  font-weight: 600;
}

.cose-at__check {
  display: flex;
  align-items: center;
  gap: 4px;
  white-space: nowrap;
}

.cose-at__lista {
  list-style: none;
  margin: 0;
  padding: 0;
  overflow-y: auto;
  flex: 1;
  min-height: 0;
}

.cose-at__item {
  padding: 10px 12px;
  border-bottom: 1px solid var(--at-border);
  cursor: pointer;
}

.cose-at__item:hover {
  background: var(--at-bg);
}

.cose-at__item--activo {
  background: var(--at-primary-5);
  box-shadow: inset 3px 0 0 var(--at-primary);
}

.cose-at__item-top,
.cose-at__item-pie {
  display: flex;
  justify-content: space-between;
  gap: 6px;
  align-items: center;
}

.cose-at__cliente {
  font-weight: 600;
  margin-top: 2px;
}

.cose-at__asunto {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cose-at__estado {
  border-radius: 999px;
  padding: 1px 8px;
  font-size: 11px;
  background: var(--at-bg);
}

.cose-at__estado--abiertos {
  color: var(--at-success);
  background: #e7f4ee;
}

.cose-at__estado--pendientes {
  color: var(--at-warning);
  background: #fdf1e6;
}

.cose-at__estado--cerrados {
  color: var(--at-muted);
}

.cose-at__pie-bandeja {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: center;
  padding: 8px;
  border-top: 1px solid var(--at-border);
}

.cose-at__centro {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  border-right: 1px solid var(--at-border);
}

.cose-at__ticket-cabecera h3 {
  margin: 2px 0;
  font-size: 15px;
}

.cose-at__acciones {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  padding: 8px 12px;
  border-bottom: 1px solid var(--at-border);
}

.cose-at__acciones .cose-at__select {
  width: auto;
}

.cose-at__hilo {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  background: var(--at-bg);
}

.cose-at__mensaje {
  background: #fff;
  border: 1px solid var(--at-border);
  border-radius: 8px;
  padding: 10px 12px;
  margin-bottom: 10px;
}

.cose-at__mensaje--nota {
  background: #fffbeb;
  border-color: #f5d28a;
}

.cose-at__mensaje header {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 6px;
}

.cose-at__cuerpo {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  line-height: 1.45;
}

.cose-at__etiqueta {
  background: #fde68a;
  border-radius: 4px;
  padding: 0 6px;
  font-size: 11px;
}

.cose-at__adjuntos {
  list-style: none;
  padding: 0;
  margin: 8px 0 0;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.cose-at__adjuntos a {
  color: var(--at-primary);
  text-decoration: underline;
}

.cose-at__composer {
  border-top: 1px solid var(--at-border);
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.cose-at__pestanas,
.cose-at__pestanas-panel {
  display: flex;
  gap: 4px;
}

.cose-at__pestanas button,
.cose-at__pestanas-panel button {
  border: 0;
  background: transparent;
  padding: 6px 10px;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  color: var(--at-muted);
}

.cose-at__pestanas button.activo,
.cose-at__pestanas-panel button.activo {
  color: var(--at-primary-hover);
  border-bottom-color: var(--at-primary);
  font-weight: 600;
}

.cose-at__composer-pie {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cose-at__panel {
  width: clamp(210px, 22vw, 460px);
  flex-shrink: 0;
  overflow-y: auto;
  padding: 12px;
  background: #fff;
  container-type: inline-size;
}

.cose-at__bloque {
  border: 1px solid var(--at-border);
  border-radius: 8px;
  padding: 10px 12px;
  margin: 10px 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.cose-at__bloque h4 {
  margin: 0;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--at-muted);
}

.cose-at__bloque dl {
  display: grid;
  grid-template-columns: max-content 1fr;
  gap: 4px 12px;
  margin: 0;
}

.cose-at__bloque dt {
  color: var(--at-muted);
}

.cose-at__bloque dd {
  margin: 0;
  overflow-wrap: anywhere;
}

/* Panel estrecho: la etiqueta va sobre el valor para que el correo y el
   dominio no se partan letra por letra. */
@container (max-width: 320px) {
  .cose-at__bloque dl {
    grid-template-columns: 1fr;
    gap: 0;
  }

  .cose-at__bloque dt {
    font-size: 11px;
    margin-top: 6px;
  }

  .cose-at__bloque dt:first-child {
    margin-top: 0;
  }
}

.cose-at__bloque label {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 12px;
}

.cose-at__timeline {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.cose-at__btn-primario,
.cose-at__btn-secundario {
  border-radius: 6px;
  padding: 6px 12px;
  cursor: pointer;
  font: inherit;
}

.cose-at__btn-primario {
  background: var(--at-primary);
  color: #fff;
  border: 1px solid var(--at-primary);
}

.cose-at__btn-primario:hover:not(:disabled) {
  background: var(--at-primary-hover);
}

.cose-at__btn-secundario {
  background: #fff;
  color: var(--at-text);
  border: 1px solid var(--at-border);
}

button:disabled,
select:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.cose-at__error {
  color: var(--at-danger);
  margin: 6px 12px;
}

.cose-at__ok {
  color: var(--at-success);
  margin: 6px 12px;
}

.cose-at__aviso {
  color: var(--at-warning);
  margin: 0;
  font-size: 12px;
}

.cose-at__vacio,
.cose-at__vacio-grande {
  color: var(--at-muted);
  padding: 16px;
  text-align: center;
}

/* Las tres columnas se conservan en escritorio; solo se apilan en pantallas
   realmente pequeñas. Antes el corte era de 1100 px y ocultaba el flujo. */
@media (max-width: 700px) {
  .cose-at {
    flex-direction: column;
    overflow-y: auto;
  }

  .cose-at__bandeja,
  .cose-at__panel {
    width: auto;
    max-height: 40vh;
  }
}
</style>
