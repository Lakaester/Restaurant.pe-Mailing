// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import { computed, reactive, ref } from 'vue'

import {
  buscarSubcategoria,
  contarPorGrupo,
  dominioDeCliente,
  filtrarAtenciones,
  hayPaginaSiguiente,
  normalizarDominio,
  type AtencionFila,
  type FiltrosAtencion,
} from '../services/atencionesDominio'
import { decidirEnvio, modoEnvio, type ModoEnvio } from '../services/politicaEnvio'
import {
  actualizarTicket,
  articulosTicket,
  buscarTickets,
  clasificarTicket,
  detalleTicket,
  emailCliente,
  filaDeTicket,
  historialTicket,
  listarEstados,
  notaInterna,
  registrarDominio,
  responderCorreo,
  TAMANO_PAGINA,
  usuarioActual,
  type ZammadArticulo,
  type ZammadEntradaHistorial,
  type ZammadEstado,
  type ZammadTicket,
  type ZammadUsuarioActual,
} from '../services/atencionesApi'
import { ZammadRestError } from '../services/zammadRest'

export function useAtenciones(valorEnvio: string | undefined = undefined) {
  const yo = ref<ZammadUsuarioActual | null>(null)
  const estados = ref<ZammadEstado[]>([])
  const filas = ref<AtencionFila[]>([])
  const cargandoBandeja = ref(false)
  const errorBandeja = ref<string | null>(null)
  const pagina = ref(1)
  const total = ref(0)

  const envio = ref<ModoEnvio>(modoEnvio(valorEnvio))

  const filtros = reactive<FiltrosAtencion>({
    texto: '',
    soloMias: false,
    estado: 'todos',
    canal: 'todos',
  })

  const seleccionadoId = ref<number | null>(null)
  const ticket = ref<ZammadTicket | null>(null)
  const emailCli = ref<string | null>(null)
  const articulos = ref<ZammadArticulo[]>([])
  const historial = ref<ZammadEntradaHistorial[]>([])
  const cargandoDetalle = ref(false)
  const errorDetalle = ref<string | null>(null)
  const operando = ref(false)
  const errorOperacion = ref<string | null>(null)
  const mensajeOperacion = ref<string | null>(null)

  const filasVisibles = computed(() => filtrarAtenciones(filas.value, filtros, yo.value?.id ?? null))
  const conteos = computed(() => contarPorGrupo(filas.value))
  const dominio = computed(() => dominioDeCliente(emailCli.value))
  const hayMas = computed(() => hayPaginaSiguiente(filas.value.length, total.value))
  const idEstadoCerrado = computed(
    () => estados.value.find((e) => e.name.trim().toLowerCase() === 'closed')?.id ?? null,
  )

  function mensajeDe(error: unknown): string {
    if (error instanceof ZammadRestError) {
      if (error.status === 401) return 'La sesión expiró. Vuelva a iniciar sesión.'
      if (error.status === 403) return 'No tiene permisos para esta acción.'
      if (error.status === 404) return 'La atención no existe o no está disponible.'
      return error.message
    }
    return error instanceof Error ? error.message : 'Error inesperado'
  }

  /** Carga la primera página de la bandeja. */
  async function cargarBandeja() {
    cargandoBandeja.value = true
    errorBandeja.value = null
    try {
      const [usuario, pagina1, estadosZammad] = await Promise.all([
        yo.value ? Promise.resolve(yo.value) : usuarioActual(),
        buscarTickets(1, TAMANO_PAGINA),
        estados.value.length ? Promise.resolve(estados.value) : listarEstados(),
      ])
      yo.value = usuario
      estados.value = estadosZammad
      pagina.value = 1
      total.value = pagina1.total_count ?? pagina1.records.length
      filas.value = pagina1.records.map(filaDeTicket)
    } catch (error) {
      errorBandeja.value = mensajeDe(error)
    } finally {
      cargandoBandeja.value = false
    }
  }

  /** Añade la página siguiente sin recargar las anteriores. */
  async function cargarMas() {
    if (cargandoBandeja.value || !hayMas.value) return
    cargandoBandeja.value = true
    errorBandeja.value = null
    try {
      const siguiente = pagina.value + 1
      const resultado = await buscarTickets(siguiente, TAMANO_PAGINA)
      const conocidos = new Set(filas.value.map((f) => f.id))
      const nuevas = resultado.records.map(filaDeTicket).filter((f) => !conocidos.has(f.id))
      filas.value = [...filas.value, ...nuevas]
      pagina.value = siguiente
      total.value = resultado.total_count ?? total.value
    } catch (error) {
      errorBandeja.value = mensajeDe(error)
    } finally {
      cargandoBandeja.value = false
    }
  }

  async function cargarDetalle(id: number) {
    cargandoDetalle.value = true
    errorDetalle.value = null
    try {
      const detalle = await detalleTicket(id)
      const [correo, arts, hist] = await Promise.all([
        emailCliente(detalle.customer_id),
        articulosTicket(id),
        historialTicket(id),
      ])
      if (seleccionadoId.value !== id) return
      ticket.value = detalle
      emailCli.value = correo
      articulos.value = arts
      historial.value = hist
    } catch (error) {
      if (seleccionadoId.value === id) errorDetalle.value = mensajeDe(error)
    } finally {
      if (seleccionadoId.value === id) cargandoDetalle.value = false
    }
  }

  async function seleccionar(id: number | null) {
    seleccionadoId.value = id
    ticket.value = null
    emailCli.value = null
    articulos.value = []
    historial.value = []
    errorDetalle.value = null
    mensajeOperacion.value = null
    errorOperacion.value = null
    if (id === null) return
    cargandoDetalle.value = true
    await cargarDetalle(id)
  }

  /** Ejecuta una operación y solo confirma cuando Zammad responde. */
  async function operar(descripcion: string, accion: () => Promise<unknown>) {
    if (seleccionadoId.value === null) return false
    operando.value = true
    errorOperacion.value = null
    mensajeOperacion.value = null
    const id = seleccionadoId.value
    try {
      await accion()
      mensajeOperacion.value = `${descripcion} confirmado por Zammad.`
      await cargarDetalle(id)
      await cargarBandeja()
      return true
    } catch (error) {
      errorOperacion.value = mensajeDe(error)
      return false
    } finally {
      operando.value = false
    }
  }

  function decidirRespuesta(texto: string) {
    return decidirEnvio({
      modo: envio.value,
      texto,
      destinatario: emailCli.value,
    })
  }

  const responder = (texto: string) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    const decision = decidirRespuesta(texto)
    if (!decision.permitido) {
      errorOperacion.value = decision.motivo
      return Promise.resolve(false)
    }
    return operar('Respuesta enviada por correo', () =>
      responderCorreo({
        ticketId: actual.id,
        cuerpo: texto,
        destinatario: emailCli.value,
        asunto: `Re: ${actual.title}`,
      }),
    )
  }

  const agregarNota = (texto: string) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    if (!texto.trim()) {
      errorOperacion.value = 'La nota no puede estar vacía.'
      return Promise.resolve(false)
    }
    return operar('Nota interna guardada', () => notaInterna(actual.id, texto))
  }

  const asignarAMi = () => {
    const actual = ticket.value
    if (!actual || !yo.value) return Promise.resolve(false)
    return operar('Asignación', () => actualizarTicket(actual.id, { owner_id: yo.value!.id }))
  }

  const asignarA = (usuarioId: number) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    return operar('Asignación', () => actualizarTicket(actual.id, { owner_id: usuarioId }))
  }

  const cambiarEstado = (idEstado: number) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    return operar('Cambio de estado', () => actualizarTicket(actual.id, { state_id: idEstado }))
  }

  const resolver = () => {
    if (idEstadoCerrado.value === null) {
      errorOperacion.value = 'Zammad no tiene un estado «closed» configurado.'
      return Promise.resolve(false)
    }
    return cambiarEstado(idEstadoCerrado.value)
  }

  const clasificar = (categoria: string, subcategoria: string) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    if (!categoria || !subcategoria) {
      errorOperacion.value = 'Seleccione categoría y subcategoría.'
      return Promise.resolve(false)
    }
    const par = buscarSubcategoria(categoria, subcategoria)
    if (!par) {
      errorOperacion.value = 'La combinación no pertenece al catálogo oficial.'
      return Promise.resolve(false)
    }
    return operar('Clasificación', () => clasificarTicket(actual.id, categoria, par.value))
  }

  const guardarDominio = (valor: string) => {
    const actual = ticket.value
    if (!actual) return Promise.resolve(false)
    const limpio = normalizarDominio(valor)
    if (!limpio) {
      errorOperacion.value = 'Dominio no válido. Ejemplo: restaurante.com.pe'
      return Promise.resolve(false)
    }
    return operar('Dominio', () => registrarDominio(actual.id, limpio))
  }

  return {
    yo,
    estados,
    filas,
    filasVisibles,
    conteos,
    filtros,
    envio,
    pagina,
    total,
    hayMas,
    cargandoBandeja,
    errorBandeja,
    seleccionadoId,
    ticket,
    emailCli,
    dominio,
    articulos,
    historial,
    cargandoDetalle,
    errorDetalle,
    operando,
    errorOperacion,
    mensajeOperacion,
    cargarBandeja,
    cargarMas,
    seleccionar,
    decidirRespuesta,
    responder,
    agregarNota,
    asignarAMi,
    asignarA,
    cambiarEstado,
    resolver,
    clasificar,
    guardarDominio,
  }
}
