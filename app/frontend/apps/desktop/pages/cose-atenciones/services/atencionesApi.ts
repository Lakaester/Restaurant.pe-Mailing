// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/**
 * Operaciones de la vista Atenciones sobre la API REST nativa de Zammad 7.2.3.
 *
 * Contratos verificados contra el sistema en ejecución:
 *   - `GET /tickets/search` acepta `query`, `page`, `per_page` (tope 200),
 *     `with_total_count`, `expand`, `sort_by`, `order_by`.
 *   - `GET /ticket_articles/by_ticket/:id` con `expand=true`.
 *   - `POST /tickets/:id` no existe; la actualización es `PUT /tickets/:id`.
 *   - Campos propios ya existentes: `categoria_subcategoria` (tree_select) y
 *     `dominio` (input). `cose_categoria` guarda la categoría padre.
 */

import { grupoDeEstado, type AtencionFila } from './atencionesDominio.ts'
import { zammadRest } from './zammadRest.ts'

export const CAMPO_CLASIFICACION = 'categoria_subcategoria'
export const CAMPO_CATEGORIA_PADRE = 'cose_categoria'
export const CAMPO_DOMINIO = 'dominio'

export const TAMANO_PAGINA = 25
export const TAMANO_MAXIMO = 200

export interface ZammadUsuarioActual {
  id: number
  login: string
  email: string | null
  firstname: string | null
  lastname: string | null
}

export interface ZammadEstado {
  id: number
  name: string
}

export interface ZammadTicket {
  id: number
  number: string
  title: string
  state_id: number
  state?: string
  owner_id: number
  owner?: string
  customer_id: number
  customer?: string
  group?: string
  create_article_type?: string
  updated_at: string
  categoria_subcategoria?: string | null
  cose_categoria?: string | null
  dominio?: string | null
}

export interface ZammadArticulo {
  id: number
  ticket_id: number
  type?: string
  sender?: string
  internal: boolean
  subject?: string | null
  body: string
  content_type?: string
  created_at: string
  from?: string | null
  attachments?: Array<number | { id: number; filename?: string; size?: number | string }>
}

export interface ZammadEntradaHistorial {
  id: number
  object?: string
  type?: string
  attribute?: string
  value_from?: string | null
  value_to?: string | null
  created_at: string
  created_by?: string
}

export interface PaginaTickets {
  records: ZammadTicket[]
  total_count: number
}

export const usuarioActual = () => zammadRest<ZammadUsuarioActual>('GET', '/users/me')

export const listarEstados = () => zammadRest<ZammadEstado[]>('GET', '/ticket_states')

/** Página real de la bandeja. `per_page` está topado a 200 por el backend. */
export function buscarTickets(
  page = 1,
  perPage = TAMANO_PAGINA,
): Promise<PaginaTickets> {
  return zammadRest<PaginaTickets>('GET', '/tickets/search', {
    query: {
      query: '*',
      expand: true,
      with_total_count: true,
      page,
      per_page: Math.min(perPage, TAMANO_MAXIMO),
      sort_by: 'updated_at',
      order_by: 'desc',
    },
  })
}

export const detalleTicket = (id: number) =>
  zammadRest<ZammadTicket>('GET', `/tickets/${id}`, { query: { expand: true } })

export const emailCliente = async (usuarioId: number): Promise<string | null> => {
  const usuario = await zammadRest<{ email?: string | null }>('GET', `/users/${usuarioId}`)
  return usuario.email ?? null
}

export const articulosTicket = (ticketId: number) =>
  zammadRest<ZammadArticulo[]>('GET', `/ticket_articles/by_ticket/${ticketId}`, {
    query: { expand: true },
  })

interface RespuestaHistorial {
  history: ZammadEntradaHistorial[]
  assets?: Record<string, unknown>
}

/**
 * `/ticket_history/:id` no devuelve un array: responde `{ history, assets }`.
 * Se desenvuelve aquí para que la pestaña Historial reciba siempre una lista.
 */
export async function historialTicket(ticketId: number): Promise<ZammadEntradaHistorial[]> {
  const respuesta = await zammadRest<RespuestaHistorial>('GET', `/ticket_history/${ticketId}`)
  return Array.isArray(respuesta?.history) ? respuesta.history : []
}

export const actualizarTicket = (ticketId: number, cambios: Record<string, unknown>) =>
  zammadRest<ZammadTicket>('PUT', `/tickets/${ticketId}`, {
    query: { expand: true },
    body: cambios,
  })

/** Guarda el par completo: hoja en el tree_select y categoría padre aparte. */
export const clasificarTicket = (
  ticketId: number,
  categoria: string,
  valorHoja: string,
) =>
  actualizarTicket(ticketId, {
    [CAMPO_CLASIFICACION]: valorHoja,
    [CAMPO_CATEGORIA_PADRE]: categoria,
  })

export const registrarDominio = (ticketId: number, dominio: string) =>
  actualizarTicket(ticketId, { [CAMPO_DOMINIO]: dominio })

export const responderCorreo = (params: {
  ticketId: number
  cuerpo: string
  destinatario: string | null
  asunto: string
}) =>
  zammadRest<ZammadArticulo>('POST', '/ticket_articles', {
    body: {
      ticket_id: params.ticketId,
      type: 'email',
      sender: 'Agent',
      internal: false,
      subject: params.asunto,
      body: params.cuerpo,
      content_type: 'text/plain',
      ...(params.destinatario ? { to: params.destinatario } : {}),
    },
  })

export const notaInterna = (ticketId: number, cuerpo: string) =>
  zammadRest<ZammadArticulo>('POST', '/ticket_articles', {
    body: {
      ticket_id: ticketId,
      type: 'note',
      sender: 'Agent',
      internal: true,
      body: cuerpo,
      content_type: 'text/plain',
    },
  })

export function filaDeTicket(ticket: ZammadTicket): AtencionFila {
  const estado = ticket.state ?? ''
  return {
    id: ticket.id,
    numero: ticket.number,
    titulo: ticket.title,
    estado,
    grupo: grupoDeEstado(estado),
    propietario: ticket.owner ?? null,
    propietarioId: ticket.owner_id ?? null,
    cliente: ticket.customer ?? '',
    canal: ticket.create_article_type ?? '',
    actualizado: ticket.updated_at,
    clasificacion: ticket.categoria_subcategoria ?? null,
    categoria: ticket.cose_categoria ?? null,
    dominio: ticket.dominio ?? null,
  }
}
