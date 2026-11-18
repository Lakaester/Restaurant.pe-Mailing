// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import { describe, expect, it } from 'vitest'

import { CATALOGO_COSE } from '../../catalog/catalogo-cose'
import {
  buscarSubcategoria,
  contarPorGrupo,
  dominioDeCliente,
  filtrarAtenciones,
  grupoDeEstado,
  hayPaginaSiguiente,
  nombreDeSubcategoria,
  normalizarDominio,
  textoDeCuerpo,
  valoresRepetidos,
  type AtencionFila,
  type FiltrosAtencion,
} from '../atencionesDominio'

const base: FiltrosAtencion = { texto: '', soloMias: false, estado: 'todos', canal: 'todos' }

const filas: AtencionFila[] = [
  { id: 1, numero: '1001', titulo: 'Factura duplicada', estado: 'new', grupo: 'abiertos', propietario: 'ana', propietarioId: 7, cliente: 'Juan Pérez', canal: 'email', actualizado: '2026-11-17T10:00:00Z', clasificacion: null, categoria: null, dominio: null },
  { id: 2, numero: '1002', titulo: 'Error web', estado: 'pending reminder', grupo: 'pendientes', propietario: null, propietarioId: null, cliente: 'Rosa Díaz', canal: 'email', actualizado: '2026-11-17T09:00:00Z', clasificacion: 'error_web', categoria: 'SOFTWARE', dominio: 'rosa.pe' },
  { id: 3, numero: '1003', titulo: 'Cierre antiguo', estado: 'closed', grupo: 'cerrados', propietario: 'ana', propietarioId: 7, cliente: 'Luis Ramos', canal: 'phone', actualizado: '2026-11-16T09:00:00Z', clasificacion: null, categoria: null, dominio: null },
]

describe('grupoDeEstado', () => {
  it('agrupa los estados de Zammad en abiertos, pendientes y cerrados', () => {
    expect(grupoDeEstado('new')).toBe('abiertos')
    expect(grupoDeEstado('open')).toBe('abiertos')
    expect(grupoDeEstado('pending reminder')).toBe('pendientes')
    expect(grupoDeEstado('pending close')).toBe('pendientes')
    expect(grupoDeEstado('closed')).toBe('cerrados')
    expect(grupoDeEstado('merged')).toBe('cerrados')
  })
})

describe('filtrarAtenciones', () => {
  it('sin filtros devuelve todas las filas', () => {
    expect(filtrarAtenciones(filas, base, 7)).toHaveLength(3)
  })

  it('busca por número, asunto o cliente sin distinguir mayúsculas', () => {
    expect(filtrarAtenciones(filas, { ...base, texto: '1002' }, 7).map((f) => f.id)).toEqual([2])
    expect(filtrarAtenciones(filas, { ...base, texto: 'FACTURA' }, 7).map((f) => f.id)).toEqual([1])
    expect(filtrarAtenciones(filas, { ...base, texto: 'rosa' }, 7).map((f) => f.id)).toEqual([2])
  })

  it('filtra por estado agrupado', () => {
    expect(filtrarAtenciones(filas, { ...base, estado: 'cerrados' }, 7).map((f) => f.id)).toEqual([3])
    expect(filtrarAtenciones(filas, { ...base, estado: 'pendientes' }, 7).map((f) => f.id)).toEqual([2])
  })

  it('"asignadas a mí" usa el identificador del agente, no el nombre', () => {
    expect(filtrarAtenciones(filas, { ...base, soloMias: true }, 7).map((f) => f.id)).toEqual([1, 3])
    expect(filtrarAtenciones(filas, { ...base, soloMias: true }, null)).toEqual([])
  })

  it('filtra por canal de correo', () => {
    expect(filtrarAtenciones(filas, { ...base, canal: 'email' }, 7).map((f) => f.id)).toEqual([1, 2])
  })

  it('combina filtros', () => {
    expect(filtrarAtenciones(filas, { ...base, soloMias: true, estado: 'abiertos' }, 7).map((f) => f.id)).toEqual([1])
  })

  it('contarPorGrupo cuenta por grupo', () => {
    expect(contarPorGrupo(filas)).toEqual({ abiertos: 1, pendientes: 1, cerrados: 1 })
  })
})

describe('catálogo oficial', () => {
  it('contiene 13 categorías y 65 subcategorías', () => {
    expect(CATALOGO_COSE).toHaveLength(13)
    expect(CATALOGO_COSE.reduce((n, c) => n + c.subcategorias.length, 0)).toBe(65)
  })

  it('reconoce exactamente tres valores repetidos entre categorías', () => {
    expect(valoresRepetidos().sort()).toEqual(
      ['caída_del_servidor', 'cambio_de_razón_social', 'redes_y_conexiones'].sort(),
    )
  })

  it('exige el par completo; una combinación inexistente no se acepta', () => {
    expect(buscarSubcategoria('FACTURACIÓN ELECTRÓNICA', 'Ajustes FE')).toEqual({ value: 'ajustes_fe' })
    expect(buscarSubcategoria('FACTURACIÓN ELECTRÓNICA', 'Error web')).toBeNull()
    expect(buscarSubcategoria('NO EXISTE', 'Ajustes FE')).toBeNull()
  })

  it('distingue el valor repetido según la categoría', () => {
    expect(buscarSubcategoria('FACTURACIÓN ELECTRÓNICA', 'Cambio de razón social')?.value).toBe('cambio_de_razón_social')
    expect(buscarSubcategoria('ADMINISTRATIVO', 'Cambio de razón social')?.value).toBe('cambio_de_razón_social')
  })

  it('reconstruye el nombre solo con el par completo', () => {
    expect(nombreDeSubcategoria('SERVIDOR', 'redes_y_conexiones')).toBe('Redes y conexiones')
    expect(nombreDeSubcategoria('OPERATIVO', 'redes_y_conexiones')).toBe('Redes y conexiones')
    expect(nombreDeSubcategoria(null, 'redes_y_conexiones')).toBeNull()
    expect(nombreDeSubcategoria('SERVIDOR', 'ajustes_fe')).toBeNull()
  })
})

describe('dominio', () => {
  it('extrae el dominio del correo en minúsculas', () => {
    expect(dominioDeCliente('Juan@Restaurant.PE')).toBe('restaurant.pe')
  })

  it('devuelve cadena vacía sin correo válido', () => {
    expect(dominioDeCliente(null)).toBe('')
    expect(dominioDeCliente('sin-arroba')).toBe('')
  })

  it('normaliza un dominio escrito a mano', () => {
    expect(normalizarDominio(' HTTPS://WWW.Restaurant.com.pe/ruta ')).toBe('restaurant.com.pe')
    expect(normalizarDominio('cliente-externo.example')).toBe('cliente-externo.example')
  })

  it('rechaza dominios sin punto o con espacios internos', () => {
    expect(normalizarDominio('intranet')).toBe('')
    expect(normalizarDominio('a b.com')).toBe('')
    expect(normalizarDominio(null)).toBe('')
  })
})

describe('paginación', () => {
  it('ofrece otra página solo si quedan filas', () => {
    expect(hayPaginaSiguiente(25, 50)).toBe(true)
    expect(hayPaginaSiguiente(50, 50)).toBe(false)
    expect(hayPaginaSiguiente(4, 4)).toBe(false)
    expect(hayPaginaSiguiente(0, 0)).toBe(false)
  })
})

describe('textoDeCuerpo', () => {
  it('no ejecuta ni muestra scripts de un correo HTML', () => {
    const texto = textoDeCuerpo('<p>Hola</p><script>alert(1)</script><style>p{}</style>', 'text/html')
    expect(texto).toContain('Hola')
    expect(texto).not.toContain('alert')
    expect(texto).not.toContain('p{}')
  })

  it('conserva el texto plano tal cual', () => {
    expect(textoDeCuerpo('línea 1\nlínea 2', 'text/plain')).toBe('línea 1\nlínea 2')
  })
})
