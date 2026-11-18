# INVENTARIO DE CANALES Y SLA — ZENDESK

**Etapa:** 5F — Inventario funcional real de Zendesk
**Fecha:** 14/11/2026
**Actualizado:** 14/11/2026 con capturas de Canales y configuración global de correo.
**Modo:** solo lectura. No se conectó ni modificó ningún canal.

---

## 0. Trazabilidad de fuentes

| Fuente | Tipo | Fecha | Uso |
|---|---|---|---|
| Captura `Centro de administración → Canales` | Evidencia visual | 14/11/2026 | Opciones de canal visibles |
| Captura `Canales → Correo electrónico` | Evidencia visual | 14/11/2026 | Configuración global de correo |
| Captura `Administrar direcciones de soporte` | Evidencia visual | 14/11/2026 | Dirección `clientes@restaurant.pe` |
| Código de COSE | Evidencia técnica | 14/11/2026 | Canales usados por COSE y metas SLA |
| Respuestas del negocio | Evidencia verbal | 14/11/2026 | SLA y horario |

---

## 1. Canales

### 1.0 Opciones visibles en el menú de Canales (14/11/2026)

Estas son **opciones del menú**, no canales activos.

| Opción visible | Estado | Observación |
|---|---|---|
| Text | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Páginas de Facebook | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Cuentas de X Corp. | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| Talk | `PENDIENTE_DE_VALIDACION` | Muestra invitación a prueba gratuita; no implica canal activo |
| Email | `VERIFICADO_ACTIVO` | Único canal confirmado por uso y dirección visible |
| Web Widget | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |
| SDK para móviles | `PENDIENTE_DE_VALIDACION` | Opción de menú; no implica canal activo |

**Dirección de correo observada:** `clientes@restaurant.pe` es la única dirección visible en “Administrar direcciones de soporte”. El buzón exclusivo de Soporte Especializado **no se observó** en esa pantalla; no se concluye que no exista. Su asociación a grupos y su ubicación en Zendesk quedan `PENDIENTE_DE_VALIDACION`.

### 1.1 Canales confirmados

| Canal | Estado | Evidencia | Fuente | Volumen | Grupo que recibe |
|---|---|---|---|---|---|
| Correo electrónico | `VERIFICADO_ACTIVO` | COSE lee/escribe tickets por API; negocio confirma | Negocio + COSE | `PENDIENTE_DE_ACCESO` | `PENDIENTE_DE_ACCESO` |

**Conclusión:** el correo es el único canal confirmado como realmente utilizado en Zendesk.

### 1.1.1 Configuración global de correo observada (14/11/2026)

| Configuración | Estado |
|---|---|
| Respuestas del agente IA para tickets de voz | Activada |
| Enviar correo electrónico a través de Gmail | Desactivada |
| Contenido enriquecido en correo electrónico | Activado |
| Aceptar correos electrónicos con comodín | Desactivada |
| Respuestas de correo personalizadas | Activada |
| Go-to Actions de Gmail | Activada |
| Delimitador de correo | Desactivado |
| Autenticación SPF, DKIM y DMARC | Activada |
| Perfil de autenticación | Mínimo |
| Dominio personalizado para DKIM | Desactivado |
| Tickets de correo de varios destinatarios | Desactivado |

**Precaución:** la opción global de Gmail desactivada **no demuestra** que no existan integraciones Gmail independientes. No se modificó ninguna configuración.

### 1.2 Canales no confirmados

| Canal | Estado | Evidencia | Observación |
|---|---|---|---|
| WhatsApp | `PENDIENTE_DE_ACCESO` | COSE tiene proveedor Meta, pero no se confirmó que sea canal de Zendesk | No asumir que Zendesk lo gestiona |
| Chat web | `PENDIENTE_DE_ACCESO` | No implementado en COSE | Podría existir en Zendesk sin uso |
| Formularios web | `PENDIENTE_DE_ACCESO` | No evidenciado | — |
| Teléfono / Talk | `PENDIENTE_DE_ACCESO` | No evidenciado | — |
| Redes sociales | `PENDIENTE_DE_ACCESO` | No evidenciado | — |
| Otros | `PENDIENTE_DE_ACCESO` | No evidenciado | — |

### 1.3 Canales en COSE que no son Zendesk

| Canal COSE | Fuente | Estado | Observación |
|---|---|---|---|
| WhatsApp Meta | `modules/meta` (`MetaService`) | `VERIFICADO_ACTIVO` en COSE | No se confirmó como canal Zendesk |
| WhatsApp Whaticket | Declarado en filtros | `NO_ENCONTRADO` como provider | Solo etiqueta de subcanal |
| Chat / Instagram / Facebook / Bot | Declarados en DTO | `NO_ENCONTRADO` | Sin provider |

**Regla:** no se debe afirmar que Zendesk atiende WhatsApp, chat o redes. La evidencia solo demuestra que COSE tiene un proveedor Meta independiente.

---

## 2. SLA

### 2.1 SLA definido por el negocio

| Elemento | Valor | Fuente | Estado |
|---|---|---|---|
| Nombre | Soporte en Línea | Negocio | `VERIFICADO_ACTIVO` |
| Lunes a viernes | 09:00–23:00 | Negocio | `VERIFICADO_ACTIVO` |
| Sábados y domingos | 09:00–20:00 | Negocio | `VERIFICADO_ACTIVO` |
| Editable | Sí | Negocio | `VERIFICADO_ACTIVO` |
| Zona horaria | No confirmada; no se asume | — | `PENDIENTE_DE_VALIDACION` |
| Feriados | No informados | — | `PENDIENTE_DE_VALIDACION` |

### 2.2 Metas de SLA calculadas en COSE

`backend/src/repositories/unificado.repository.ts`:

```ts
export const SLA_MINUTOS = {
  primeraRespuesta: { whatsapp: 15, correo: 1440, otro: 60 }, // 15 min / 24 h / 1 h
  resolucion: { whatsapp: 120, correo: 1440, otro: 480 },     // PROVISIONAL
};
```

| Métrica | WhatsApp | Correo | Otro | Estado |
|---|---:|---:|---:|---|
| Primera respuesta | 15 min | 1440 min (24 h) | 60 min | `VERIFICADO_ACTIVO` en COSE BI |
| Resolución | 120 min | 1440 min (24 h) | 480 min | `VERIFICADO_ACTIVO` en COSE BI; **provisional** |

**Advertencia:** la resolución está marcada como “PROVISIONAL: aún por definir por categoría” en el propio código. No debe tratarse como meta definitiva.

### 2.3 Qué existe realmente en Zendesk

| Elemento | Estado | Evidencia |
|---|---|---|
| Política SLA de Zendesk | `PENDIENTE_DE_ACCESO` | No hay inventario |
| Nombre de la política | `PENDIENTE_DE_ACCESO` | — |
| Primera respuesta | `PENDIENTE_DE_ACCESO` | — |
| Próxima respuesta | `PENDIENTE_DE_ACCESO` | — |
| Resolución | `PENDIENTE_DE_ACCESO` | — |
| Horario de la política | `PENDIENTE_DE_ACCESO` | — |
| Feriados | `PENDIENTE_DE_ACCESO` | — |
| Pausas/suspensiones | `PENDIENTE_DE_ACCESO` | — |
| Escalamiento | `PENDIENTE_DE_ACCESO` | — |
| Grupos/canales afectados | `PENDIENTE_DE_ACCESO` | — |

**Evidencia administrativa del 14/11/2026:** las capturas compartidas corresponden a Canales, Correo y Direcciones de soporte. **No incluyeron la configuración de SLA.** Por tanto, la política SLA de Zendesk sigue `PENDIENTE_DE_ACCESO`.

**Reconciliación importante:** `AUDITORIA_MODULO_ATENCIONES_COSE.md` dice “no hay SLA propio (se depende de Zendesk)”. Eso se refiere a que el **módulo Atenciones** no aplica SLA. COSE sí **calcula** cumplimiento en el dashboard BI (`/dashboard/sla`). Son dos capas:

- **SLA operativo:** lo aplica Zendesk (no verificado) o Zammad (no configurado).
- **SLA analítico:** lo calcula COSE sobre `v_unificado_norm` (verificado).

### 2.4 Equivalencia en Zammad

| Capacidad | Zammad | Estado en nuestra instalación |
|---|---|---|
| Políticas SLA | `Sla` (`first_response_time`, `response_time`, `update_time`, `solution_time`, `condition`, `calendar_id`) | **0 SLA** |
| Calendario laboral | `Calendar.business_hours` | 1 calendario: `My Calendar`, `America/Los_Angeles`, L–V 09:00–17:00, sáb/dom inactivos |
| Feriados | `Calendar.public_holidays` | Vacío |
| Zona horaria | `Calendar.timezone` | `America/Los_Angeles` (incorrecta para Perú) |
| Escalamiento | `Ticket::Escalation` | Depende de SLA |
| Pausa | Estados pendientes | Configurable |

**Brecha:** el calendario actual **no coincide** con el horario del negocio. Hay que crear un calendario `America/Lima` con L–V 09:00–23:00 y S–D 09:00–20:00, y cargar feriados.

### 2.5 Decisión pendiente

| # | Decisión | Opciones |
|---|---|---|
| 1 | ¿Dónde vive el SLA operativo? | Zammad / COSE / ambos con una sola fuente |
| 2 | ¿Se replica la meta de 24 h para correo? | Sí / No / ajustar |
| 3 | ¿La resolución provisional se mantiene? | Sí / definir por categoría |
| 4 | ¿Se usa el calendario del negocio para SLA? | Sí / No |
| 5 | ¿Se cargan feriados? | Sí / No |
| 6 | ¿Se activa escalamiento? | Sí / No |

---

## 3. Preguntas concretas para el administrador

### 3.1 Respondidas parcialmente el 14/11/2026

| # | Pregunta | Respuesta observada |
|---|---|---|
| 1 | ¿Qué canales están disponibles? | Text, Facebook, X, Talk, Email, Web Widget, SDK móvil (opciones de menú) |
| 2 | ¿Qué dirección de correo existe? | `clientes@restaurant.pe` visible |
| 3 | ¿Qué configuración global de correo? | Tabla de §1.1.1 |

### 3.2 Siguen abiertas

1. ¿Qué **políticas SLA** existen en Zendesk? Nombre, métricas, metas y estado.
2. ¿La política “Soporte en Línea” existe en Zendesk o solo es una definición de negocio?
3. ¿Qué **horario** tiene configurado Zendesk? ¿Coincide con L–V 09:00–23:00 y S–D 09:00–20:00?
4. ¿Qué **zona horaria** usa Zendesk?
5. ¿Qué **feriados** están cargados?
6. ¿Hay **pausas** de SLA (por estado pendiente, por cliente, por canal)?
7. ¿Hay **escalamiento** por SLA vencido? ¿A quién notifica?
8. ¿Qué canales están **activos** y cuáles se usan realmente?
9. ¿Cuál es el **volumen mensual** por canal?
10. ¿Qué **grupo** recibe cada canal?
11. ¿Dónde está el **buzón exclusivo de Soporte Especializado** y a qué grupo está asociado?

**Evidencia necesaria:** captura o exportación de la configuración de canales y SLA. No se requieren credenciales en el documento.

---

## 4. Conclusión

- **Canal confirmado:** correo.
- **Dirección visible:** `clientes@restaurant.pe`; el buzón exclusivo de Soporte Especializado no se observó y sigue pendiente de localizar.
- **Opciones de canal visibles:** Text, Facebook, X, Talk, Email, Web Widget y SDK móvil; no equivalen a canales activos.
- **Configuración global de correo:** observada (11 preferencias); no se modificó.
- **SLA confirmado por negocio:** Soporte en Línea, con horario L–V 09:00–23:00 y S–D 09:00–20:00.
- **SLA de Zendesk:** no verificado; las capturas no incluyeron SLA.
- **SLA de COSE:** calculado en BI con metas de 24 h para correo; resolución provisional.
- **Zammad:** puede configurar SLA y calendario, pero hoy tiene 0 SLA y un calendario con horario incorrecto.

**Brecha P0:** sin un calendario y una política SLA equivalentes, no se puede afirmar paridad operativa. La evidencia administrativa aclara canales y correo, pero **no cierra SLA**.
