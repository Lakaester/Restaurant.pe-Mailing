# Decisiones de arquitectura — MAILING / C.O.S.E.

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Última actualización:** 14/11/2026

> **[DECISIÓN]** aprobada · **[PROPUESTA]** pendiente · **[RIESGO]** abierto

---

## D-001 — Zammad es el motor de tickets y correo

**[DECISIÓN]**

Zammad 7.2.3 es la base del sistema. No se desarrolla desde cero la gestión de tickets ni el correo.

**Motivo:** las pruebas de recepción, respuesta y seguimiento funcionan de extremo a extremo.

**Implica:**
- Se conserva el núcleo de Zammad sin modificaciones.
- Las personalizaciones van en `addons/` y configuración.
- Las actualizaciones se hacen por etiquetas oficiales.

---

## D-002 — COSE mantiene la experiencia operativa

**[DECISIÓN]**

COSE sigue siendo la interfaz de trabajo del área. Zammad actúa como motor por debajo.

**Implica:**
- No se reemplaza la operación actual de golpe.
- La consola de tres paneles convivirá con la interfaz nativa de Zammad.
- COSE no se modifica en esta etapa.

---

## D-003 — BFF server-side

**[DECISIÓN]**

El futuro BFF será **server-side**.

**Motivo:** evita depender de CORS (deshabilitado en Zammad) y permite controlar credenciales y límites de uso.

**Implica:**
- El navegador nunca recibe el token de Zammad.
- El BFF concentra la autenticación, el rate limiting y la transformación de datos.

---

## D-004 — Autenticación del BFF con token dedicado

**[DECISIÓN]**

El BFF se autenticará contra Zammad con un **token de API dedicado**, no con usuario y contraseña.

**Estado del sistema:** `api_token_access = true`, `api_password_access = true`.

**Implica:**
- Se debe crear un token exclusivo para el BFF.
- El token se guarda en el gestor de secretos del servidor.
- No se usa la contraseña de ningún agente.

---

## D-005 — Rate limiting en BFF y proxy

**[DECISIÓN]**

El control de frecuencia se implementa en el BFF y en el proxy inverso.

**Motivo:** Zammad solo limita formularios y endpoints públicos; la API no tiene límites propios.

---

## D-006 — No activar todavía los triggers

**[DECISIÓN]**

Los tres triggers permanecen inactivos hasta definir las automatizaciones.

| Trigger | Estado |
|---|---|
| auto reply (on new tickets) | Inactivo |
| auto reply (on follow-up) | Inactivo |
| customer notification (owner change) | Inactivo |

**Implica:** ningún correo automático al cliente durante el piloto.

---

## D-007 — No activar todavía el worker

**[DECISIÓN]**

El worker permanece detenido hasta resolver la estrategia de recepción y la cola de trabajos.

**Implica:**
- No hay recepción automática de correo.
- No se procesan los trabajos acumulados.
- Los envíos manuales requieren ejecutar el trabajo correspondiente.

---

## D-008 — Descartar el trabajo 104

**[DECISIÓN]**

Se descartó el trabajo `Delayed::Job` ID 104 (envío del artículo 4).

**Implica:**
- El artículo 4 se conserva intacto en el ticket 91007.
- El correo correspondiente no se enviará nunca.
- No se elimina ni modifica ningún otro trabajo.

---

## D-009 — Dominio de producción

**[DECISIÓN]**

El dominio de producción será un **subdominio dedicado de Restaurant.pe**.

**Estado:** el subdominio **aún no existe**. Su definición y configuración quedan pendientes de coordinación con el equipo de TI.

**No se define en este documento** el nombre del subdominio, la fecha ni el responsable.

**Implica:**
- No se modifica `fqdn`, OAuth, DNS ni HTTPS todavía.
- Cuando exista el subdominio, habrá que:
  - actualizar `fqdn` y `http_type`;
  - registrar la nueva URI de callback en Google;
  - reemitir el token OAuth;
  - verificar los enlaces de los correos.

---

## D-010 — Recepción de Gmail por UID

**[DECISIÓN]**

Se evaluará una recepción basada en **UID** con control de duplicados.

**Motivo:** con `keep_on_server=true` Zammad solo importa mensajes no leídos. Si alguien lee el correo en Gmail antes de la consulta, se pierde.

**Implica:**
- Es una línea de trabajo del BFF, no una modificación del núcleo.
- Debe garantizar idempotencia (no duplicar artículos).

---

## D-011 — Elasticsearch pendiente

**[DECISIÓN]**

Mantener Elasticsearch como **decisión pendiente**.

**Estado actual:** desactivado; la búsqueda usa la base de datos.

**Implica:** evaluar volumen y rendimiento antes de producción.

---

## D-012 — SMTP real antes de producción

**[DECISIÓN]**

Configurar un servidor SMTP real antes de producción.

**Estado actual:** el canal de notificación usa `sendmail`, que no está instalado. Las notificaciones fallan.

**Implica:**
- Definir servidor, credenciales y remitente.
- Actualizar `notification_sender` al dominio real.

---

## D-013 — Política de correos grandes

**[DECISIÓN]**

Definir una política de correos grandes y revisar `postmaster_response`.

**Estado actual:** un correo de más de 10 MB provoca una respuesta automática de «mensaje demasiado grande» por el canal del buzón.

**Implica:**
- Decidir el límite (`postmaster_max_size`).
- Decidir si se mantiene, se desactiva o se redirige esa respuesta.

---

## D-014 — Backups automáticos y restauración probada

**[DECISIÓN]**

Automatizar los backups y probar una restauración.

**Estado actual:** tres backups manuales en `/home/acast/backups/mailing/`.

**Implica:**
- Definir frecuencia y retención.
- Documentar el procedimiento de restauración.
- Ejecutar una prueba real en una base temporal.

---

## Propuestas pendientes

| # | Propuesta | Estado |
|---|---|---|
| P-01 | Estrategia concreta de recepción (worker, cron o BFF por UID) | **[PROPUESTA]** |
| P-02 | Nombre del subdominio de producción | **[PROPUESTA]** — depende de TI |
| P-03 | Activación de Elasticsearch | **[PROPUESTA]** |
| P-04 | Automatizaciones a activar (triggers, schedulers, macros) | **[PROPUESTA]** |
| P-05 | Diseño funcional de la consola de tres paneles | **[PROPUESTA]** |
| P-06 | Contrato de API entre BFF y COSE | **[PROPUESTA]** |
| P-07 | Política de retención de tickets y adjuntos | **[PROPUESTA]** |
| P-08 | Validación legal de la licencia AGPL-3.0 | **[PROPUESTA]** |

---

## Restricciones vigentes

- No modificar el núcleo de Zammad.
- No modificar COSE.
- No conectar bases de datos de otros proyectos.
- No usar credenciales de otros sistemas.
- No desplegar en producción sin cerrar los riesgos abiertos.
