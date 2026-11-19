// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/**
 * Cliente REST de la vista Atenciones.
 * Usa la sesión del agente (cookie HttpOnly) y el token CSRF de la página.
 * No contiene credenciales ni tokens de servicio.
 */

export class ZammadRestError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message)
    this.name = 'ZammadRestError'
  }
}

const csrfToken = () =>
  document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content ?? ''

type Query = Record<string, string | number | boolean | undefined>

export async function zammadRest<T>(
  method: 'GET' | 'POST' | 'PUT',
  path: string,
  options: { query?: Query; body?: unknown } = {},
): Promise<T> {
  const params = new URLSearchParams()
  Object.entries(options.query ?? {}).forEach(([clave, valor]) => {
    if (valor !== undefined) params.set(clave, String(valor))
  })
  const queryString = params.toString()
  const url = `/api/v1${path}${queryString ? `?${queryString}` : ''}`

  const hasBody = options.body !== undefined
  const init: RequestInit = {
    method,
    credentials: 'same-origin',
    headers: {
      Accept: 'application/json',
      ...(hasBody ? { 'Content-Type': 'application/json' } : {}),
      'X-CSRF-Token': csrfToken(),
    },
  }
  // GET nunca lleva cuerpo; solo POST/PUT lo envían cuando existe.
  if (hasBody && method !== 'GET') init.body = JSON.stringify(options.body)
  const response = await fetch(url, init)

  if (!response.ok) {
    let mensaje = `Error ${response.status}`
    try {
      const cuerpo = (await response.json()) as { error?: string; error_human?: string }
      mensaje = cuerpo.error_human ?? cuerpo.error ?? mensaje
    } catch {
      // Respuesta sin JSON: se conserva el mensaje genérico.
    }
    throw new ZammadRestError(response.status, mensaje)
  }

  return (await response.json()) as T
}
