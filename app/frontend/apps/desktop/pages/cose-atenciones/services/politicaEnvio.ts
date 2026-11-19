// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/* eslint-disable zammad/zammad-detect-translatable-string --
   C.O.S.E. es una interfaz solo en español y sus textos/valores de catálogo no
   forman parte del catálogo de traducción de Zammad (fuente en inglés). Ver
   docs/decisiones.md (D-010). */

/**
 * Barrera de salida de correo.
 *
 * Responder por correo usa el canal configurado en Zammad y produce un envío
 * real e irreversible. Mientras no exista un canal aislado verificado, la
 * vista mantiene la respuesta deshabilitada y ofrece la nota interna.
 *
 * El valor se lee de `VITE_COSE_ENVIO_CORREO`:
 *   - ausente o cualquier valor distinto de `habilitado`  -> bloqueado
 *   - exactamente `habilitado`                            -> habilitado
 */

export type ModoEnvio = 'bloqueado' | 'habilitado'

export interface DecisionEnvio {
  permitido: boolean
  motivo: string | null
}

export const VARIABLE_ENVIO = 'VITE_COSE_ENVIO_CORREO'

export function modoEnvio(valor: string | null | undefined): ModoEnvio {
  return (valor ?? '').trim().toLowerCase() === 'habilitado' ? 'habilitado' : 'bloqueado'
}

/**
 * Decide si se puede enviar. El orden importa: primero la barrera de salida y
 * después las validaciones de contenido, para que el mensaje sea el correcto.
 */
export function decidirEnvio(params: {
  modo: ModoEnvio
  texto: string
  destinatario: string | null | undefined
}): DecisionEnvio {
  if (params.modo !== 'habilitado') {
    return {
      permitido: false,
      motivo:
        'Envío de correo deshabilitado: falta un canal aislado verificado. Use «Nota interna» o habilite la variable indicada en la guía de operación.',
    }
  }
  if (!params.destinatario) {
    return {
      permitido: false,
      motivo: 'El cliente no tiene correo electrónico registrado; no se puede responder por correo.',
    }
  }
  if (!params.texto.trim()) {
    return { permitido: false, motivo: 'La respuesta no puede estar vacía.' }
  }
  return { permitido: true, motivo: null }
}
