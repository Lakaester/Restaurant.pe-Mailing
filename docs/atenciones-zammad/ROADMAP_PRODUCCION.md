# Roadmap de producción — MAILING / C.O.S.E.

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Última actualización:** 14/11/2026

> No se asignan fechas ni responsables en este documento: dependen de coordinación con TI y de decisiones aún pendientes.

---

## Estado de las etapas

| Etapa | Contenido | Estado |
|---|---|---|
| 1 | Verificación del código y copia de trabajo | **Completada** |
| 2 | PostgreSQL local, Redis, Ruby, Node | **Completada** |
| 3 | Instalación de dependencias y base de datos | **Completada** |
| 4 | Primer acceso, tema C.O.S.E. | **Completada** |
| 5A | Descartar trabajo 104 y documentar auditoría | **Completada** |
| 5B | Estrategia de recepción de correo | **Siguiente** |
| 5C | Diseño del BFF y contrato de API | Pendiente |
| 5D | Infraestructura de producción | Pendiente |
| 5E | Puesta en marcha controlada | Pendiente |

---

## 5B — Estrategia de recepción de correo

**Objetivo:** garantizar que ningún correo se pierda.

**Problema a resolver:** con `keep_on_server=true`, Zammad solo importa mensajes no leídos.

**Opciones a evaluar:**

| Opción | Descripción |
|---|---|
| A | Worker permanente con chequeo cada N minutos |
| B | Consulta programada externa (cron) |
| C | Importación por UID desde el BFF |

**Criterios de salida:**
- Prueba con 3 correos, uno leído en Gmail antes de la consulta, y los 3 generan ticket.
- Sin duplicados tras dos consultas consecutivas.
- Procedimiento documentado.

---

## 5C — Diseño del BFF y contrato de API

**Objetivo:** definir cómo COSE consumirá Zammad.

**Puntos a definir:**
- Endpoints necesarios (listado, detalle, respuesta, clasificación).
- Autenticación con token dedicado.
- Rate limiting en BFF y proxy.
- Manejo de errores y reintentos.
- Idempotencia en la creación de artículos.

**Criterios de salida:**
- Contrato documentado y revisado.
- Prueba de integración con datos ficticios.
- Sin exponer credenciales al navegador.

---

## 5D — Infraestructura de producción

**Objetivo:** desplegar en los servidores de Restaurant.pe.

**Pendiente de TI:**
- Subdominio dedicado de Restaurant.pe.
- Certificado HTTPS.
- Acceso a PostgreSQL dedicado.
- Servidor SMTP.
- Política de backups.

**Puntos técnicos a cerrar:**
- `fqdn` y `http_type` definitivos.
- URI de callback de Google actualizada.
- Token OAuth reemitido.
- Elasticsearch (activar o no).
- Supervisor de procesos.
- Elasticsearch/Redis/memcached según decisión.

**Criterios de salida:**
- HTTPS válido.
- Servicios con arranque automático.
- Backup automático y restauración probada.

---

## 5E — Puesta en marcha controlada

**Objetivo:** pasar de piloto a operación real.

**Pasos:**
1. Activar el worker con la estrategia de recepción elegida.
2. Activar únicamente las automatizaciones aprobadas.
3. Configurar SMTP y verificar notificaciones.
4. Probar con un buzón real y un grupo reducido.
5. Medir durante un periodo definido.
6. Ampliar al resto del equipo.

**Criterios de salida:**
- Todos los criterios de aceptación cumplidos.
- Sin incidencias abiertas de severidad alta.

---

## Dependencias entre etapas

```
5B (recepción)
  └→ 5C (BFF) puede avanzar en paralelo
       └→ 5D (infraestructura) requiere subdominio de TI
            └→ 5E (puesta en marcha) requiere 5B, 5C y 5D cerradas
```

---

## Decisiones que bloquean el avance

| # | Decisión | Bloquea |
|---|---|---|
| 1 | Estrategia de recepción | 5B, 5E |
| 2 | Subdominio de producción (TI) | 5D |
| 3 | Servidor SMTP | 5D, 5E |
| 4 | Elasticsearch sí/no | 5D |
| 5 | Automatizaciones a activar | 5E |
| 6 | Contrato de API | 5C |

---

## Lo que NO forma parte de este roadmap

- Modificar el núcleo de Zammad.
- Cambiar COSE.
- Integrar WhatsApp o chats.
- Migrar datos de Zendesk productivo sin autorización expresa.
- Desplegar en producción sin cerrar los riesgos abiertos.
