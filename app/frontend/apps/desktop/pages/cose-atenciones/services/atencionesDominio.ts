// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/**
 * Reglas puras de la vista Atenciones: filtrado, agrupación de estados,
 * clasificación oficial, dominio y saneado del cuerpo de los artículos.
 * Sin dependencias de Vue ni de red, para poder probarlas de forma aislada.
 */

import { CATALOGO_COSE, type CatalogoCategoria } from '../catalog/catalogo-cose'

export type GrupoEstado = 'abiertos' | 'pendientes' | 'cerrados'
export type FiltroEstado = 'todos' | GrupoEstado
export type FiltroCanal = 'todos' | 'email'

export interface FiltrosAtencion {
  texto: string
  soloMias: boolean
  estado: FiltroEstado
  canal: FiltroCanal
}

export interface AtencionFila {
  id: number
  numero: string
  titulo: string
  estado: string
  grupo: GrupoEstado
  propietario: string | null
  propietarioId: number | null
  cliente: string
  canal: string
  actualizado: string
  clasificacion: string | null
  categoria: string | null
  dominio: string | null
}

export function grupoDeEstado(nombre: string): GrupoEstado {
  const estado = nombre.trim().toLowerCase()
  if (estado === 'closed' || estado === 'merged' || estado === 'removed') return 'cerrados'
  if (estado.startsWith('pending')) return 'pendientes'
  return 'abiertos'
}

export function filtrarAtenciones(
  filas: AtencionFila[],
  filtros: FiltrosAtencion,
  meId: number | null,
): AtencionFila[] {
  const texto = filtros.texto.trim().toLowerCase()
  return filas.filter((fila) => {
    if (filtros.estado !== 'todos' && fila.grupo !== filtros.estado) return false
    if (filtros.canal !== 'todos' && fila.canal.toLowerCase() !== filtros.canal) return false
    if (filtros.soloMias && (meId === null || fila.propietarioId !== meId)) return false
    if (texto) {
      const coincide = [fila.numero, fila.titulo, fila.cliente]
        .some((valor) => valor.toLowerCase().includes(texto))
      if (!coincide) return false
    }
    return true
  })
}

export function contarPorGrupo(filas: AtencionFila[]): Record<GrupoEstado, number> {
  return filas.reduce<Record<GrupoEstado, number>>(
    (acumulado, fila) => ({ ...acumulado, [fila.grupo]: acumulado[fila.grupo] + 1 }),
    { abiertos: 0, pendientes: 0, cerrados: 0 },
  )
}

/** Dominio a partir de un correo. Devuelve cadena vacía si no hay arroba. */
export function dominioDeCliente(email: string | null | undefined): string {
  const valor = (email ?? '').trim().toLowerCase()
  const arroba = valor.lastIndexOf('@')
  return arroba >= 0 ? valor.slice(arroba + 1) : ''
}

/**
 * Normaliza un dominio escrito a mano: quita esquema, `www.`, ruta y espacios.
 * Devuelve cadena vacía si no es un dominio con al menos un punto.
 */
export function normalizarDominio(valor: string | null | undefined): string {
  let dominio = (valor ?? '').trim().toLowerCase()
  dominio = dominio.replace(/^[a-z]+:\/\//, '')
  dominio = dominio.split(/[/?#]/)[0] ?? ''
  dominio = dominio.replace(/^www\./, '')
  dominio = dominio.replace(/\.+$/, '')
  const etiqueta = '[a-z0-9](?:[a-z0-9-]*[a-z0-9])?'
  const patron = new RegExp(`^${etiqueta}(?:\\.${etiqueta})+$`)
  return patron.test(dominio) ? dominio : ''
}

/**
 * Un `value` puede repetirse entre categorías (3 casos). Por eso la búsqueda
 * exige el par completo; nunca se infiere la categoría desde el `value`.
 */
export function buscarSubcategoria(
  categoria: string,
  subcategoria: string,
  catalogo: CatalogoCategoria[] = CATALOGO_COSE,
): { value: string } | null {
  const padre = catalogo.find((c) => c.categoria === categoria)
  const hija = padre?.subcategorias.find((s) => s.label === subcategoria)
  return hija ? { value: hija.value } : null
}

/** Nombre legible de una hoja a partir del par. Sin categoría, no se adivina. */
export function nombreDeSubcategoria(
  categoria: string | null | undefined,
  value: string | null | undefined,
  catalogo: CatalogoCategoria[] = CATALOGO_COSE,
): string | null {
  if (!categoria || !value) return null
  const padre = catalogo.find((c) => c.categoria === categoria)
  return padre?.subcategorias.find((s) => s.value === value)?.label ?? null
}

/**
 * Valores del catálogo que aparecen en más de una categoría. Con ellos el
 * `value` solo no basta para reconstruir el par.
 */
export function valoresRepetidos(catalogo: CatalogoCategoria[] = CATALOGO_COSE): string[] {
  const apariciones = new Map<string, number>()
  catalogo.forEach((c) =>
    c.subcategorias.forEach((s) => apariciones.set(s.value, (apariciones.get(s.value) ?? 0) + 1)),
  )
  return [...apariciones.entries()].filter(([, n]) => n > 1).map(([valor]) => valor)
}

/** Texto plano de un cuerpo de artículo. DOMParser no ejecuta scripts ni carga recursos. */
export function textoDeCuerpo(cuerpo: string, tipoContenido: string | null | undefined): string {
  if (!cuerpo) return ''
  if ((tipoContenido ?? '').toLowerCase() !== 'text/html') return cuerpo
  const documento = new DOMParser().parseFromString(cuerpo, 'text/html')
  documento.querySelectorAll('style, script, head, title').forEach((nodo) => nodo.remove())
  return (documento.body?.innerText ?? documento.body?.textContent ?? '').trim()
}

export function formatearFecha(valor: string | null | undefined): string {
  if (!valor) return '—'
  const fecha = new Date(valor)
  if (Number.isNaN(fecha.getTime())) return '—'
  return fecha.toLocaleString('es-PE', {
    timeZone: 'America/Lima',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

/** Una página más solo existe si ya hay menos filas cargadas que el total. */
export function hayPaginaSiguiente(cargadas: number, total: number): boolean {
  return total > 0 && cargadas < total
}
