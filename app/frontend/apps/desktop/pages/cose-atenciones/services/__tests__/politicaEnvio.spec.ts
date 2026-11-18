// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import { describe, expect, it } from 'vitest'

import { decidirEnvio, modoEnvio, VARIABLE_ENVIO } from '../politicaEnvio'

describe('barrera de salida de correo', () => {
  it('solo se habilita con el valor exacto', () => {
    expect(modoEnvio(undefined)).toBe('bloqueado')
    expect(modoEnvio('')).toBe('bloqueado')
    expect(modoEnvio('true')).toBe('bloqueado')
    expect(modoEnvio(' HABILITADO ')).toBe('habilitado')
    expect(VARIABLE_ENVIO).toBe('VITE_COSE_ENVIO_CORREO')
  })

  it('bloquea aunque haya destinatario y texto', () => {
    const decision = decidirEnvio({ modo: 'bloqueado', texto: 'hola', destinatario: 'a@b.pe' })
    expect(decision.permitido).toBe(false)
    expect(decision.motivo).not.toBeNull()
  })

  it('con barrera levantada, exige destinatario y texto', () => {
    expect(decidirEnvio({ modo: 'habilitado', texto: 'hola', destinatario: null }).permitido).toBe(false)
    expect(decidirEnvio({ modo: 'habilitado', texto: '  ', destinatario: 'a@b.pe' }).permitido).toBe(false)
    expect(decidirEnvio({ modo: 'habilitado', texto: 'hola', destinatario: 'a@b.pe' }).permitido).toBe(true)
  })
})
