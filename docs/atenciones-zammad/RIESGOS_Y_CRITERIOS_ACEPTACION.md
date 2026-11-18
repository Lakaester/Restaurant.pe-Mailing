# Riesgos y criterios de aceptación — MAILING / C.O.S.E.

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Última actualización:** 14/11/2026

---

## 1. Riesgos abiertos

| # | Riesgo | Nivel | Impacto | Mitigación propuesta | Estado |
|---|---|---|---|---|---|
| R-01 | `fqdn = localhost:3000` | **Alto** | Enlaces de correo y OAuth inválidos fuera del equipo | Definir subdominio real y actualizar `fqdn`/`http_type` | Abierto |
| R-02 | Recepción depende del flag `\Seen` | **Alto** | Correos leídos en Gmail antes de la consulta no se importan | Worker frecuente, cron o importación por UID en el BFF | Abierto |
| R-03 | Sin HTTPS | **Alto** | Credenciales y datos en claro | Certificado TLS en el proxy de producción | Abierto |
| R-04 | Backups solo manuales | **Alto** | Pérdida de datos ante fallo | Automatizar y probar restauración | Abierto |
| R-05 | Cola con trabajo de correo pendiente | Medio | `NotificationMailerJob` (registro) fallaría al arrancar el worker | Resolver antes de arrancar el worker | Abierto |
| R-06 | Sin MTA para notificaciones | Medio | Avisos internos no salen | Configurar SMTP real | Abierto |
| R-07 | API sin rate limiting | Medio | Abuso si se expone | Rate limit en BFF y proxy | Abierto |
| R-08 | CORS deshabilitado | Bajo | Obliga a BFF server-side | Ya asumido en la arquitectura | Mitigado |
| R-09 | Elasticsearch desactivado | Medio | Búsqueda más lenta con volumen | Decidir activación antes de producción | Abierto |
| R-10 | Procesos sin supervisor | Medio | Caen al reiniciar WSL | Servicio systemd o supervisor en producción | Abierto |
| R-11 | Respuesta automática por correo > 10 MB | Bajo | Envío no deseado al remitente | Revisar `postmaster_max_size` y `postmaster_response` | Abierto |
| R-12 | Seguimientos sin número de ticket | Bajo | Podrían crear un ticket nuevo | Definir regla de negocio y formación | Abierto |
| R-13 | Licencia AGPL-3.0 | Medio | Obligaciones si se publica el servicio | Validación legal antes de desarrollo de addons | Abierto |
| R-14 | Token OAuth compartido por chat | Medio | Secreto comprometido | Rotar el secreto antes de producción | Abierto |
| R-15 | `postmaster_follow_up_search_in = subject_references` | Bajo | Seguimientos sin número crean ticket nuevo | Evaluar añadir búsqueda en cuerpo | Abierto |

---

## 2. Riesgos cerrados o mitigados

| # | Riesgo | Cómo se cerró |
|---|---|---|
| C-01 | Respuestas automáticas al cliente | Los 3 triggers están inactivos |
| C-02 | Borrado de correos en Gmail | `keep_on_server=true`; solo marca como leído |
| C-03 | Importación de correos históricos | Solo se importan no leídos |
| C-04 | Envío accidental del artículo 4 | Trabajo 104 descartado |
| C-05 | Duplicación de conversaciones | Seguimiento verificado: mismo ticket, sin duplicado |
| C-06 | Grupo incorrecto en tickets nuevos | Canal 4 apunta a Soporte Especializado |

---

## 3. Criterios de aceptación para producción

| # | Criterio | Cómo se verifica | Estado |
|---|---|---|---|
| A-01 | Dominio real con HTTPS | `https://<subdominio>` responde con certificado válido | Pendiente |
| A-02 | Recepción sin depender de la lectura | Enviar 3 correos, leer uno en Gmail, comprobar que los 3 generan ticket | Pendiente |
| A-03 | Sin duplicados | Dos consultas consecutivas no crean artículos repetidos | Pendiente |
| A-04 | Sin respuestas automáticas no deseadas | Correo normal y correo > 10 MB | Pendiente |
| A-05 | Cola sin correos pendientes | `Delayed::Job` sin trabajos de correo | Pendiente |
| A-06 | Notificaciones funcionando | Un aviso interno llega al buzón configurado | Pendiente |
| A-07 | BFF autenticado por token | Sin contraseña de usuario en ninguna llamada | Pendiente |
| A-08 | Rate limiting activo | Prueba de carga controlada | Pendiente |
| A-09 | Backup y restauración | Restaurar en base temporal y comparar | Pendiente |
| A-10 | Arranque automático | Reiniciar el servidor y comprobar que todo vuelve | Pendiente |
| A-11 | Auditoría de tickets | Historial completo visible en cada ticket | Verificado en local |
| A-12 | Permisos por grupo | Agente sin acceso a grupos ajenos | Verificado en local |
| A-13 | Clasificación operativa | Dominio y categoría persisten y filtran | Verificado en local |
| A-14 | Tema C.O.S.E. | Interfaz con colores y tipografía institucionales | Verificado en local |

---

## 4. Criterios ya validados en local

| # | Criterio | Evidencia |
|---|---|---|
| V-01 | Recepción de correo real | Ticket 91007 creado en Soporte Especializado |
| V-02 | Respuesta manual con firma | Artículo 3, `delivery_status=success`, canal 4 |
| V-03 | Asunto con número de ticket | `RE: Prueba [Ticket#91007]` |
| V-04 | Seguimiento en el mismo hilo | Artículo 5 en el ticket 91007 |
| V-05 | Sin ticket duplicado | Tickets totales sin cambios |
| V-06 | Sin respuestas automáticas | 0 triggers activos con email |
| V-07 | Correo permanece en Gmail | Marcado como leído, no borrado |
| V-08 | Permisos por grupo | Victor 4 tickets / agent1 0 en Soporte Especializado |
| V-09 | Atributos y filtros | Selector devuelve resultados correctos |
| V-10 | Vistas con columnas | 6 vistas con 10 columnas |

---

## 5. Reglas operativas mientras se cierran los riesgos

1. No abrir en Gmail los correos destinados a Zammad.
2. No arrancar el worker hasta definir la estrategia de recepción.
3. No activar triggers sin aprobación.
4. No exponer Zammad a Internet sin HTTPS ni rate limiting.
5. No usar el buzón piloto para correo real de clientes.
6. Mantener los backups manuales hasta automatizarlos.

---

## 6. Revisión

Este documento debe revisarse:
- Al cerrar cada riesgo.
- Antes de cada cambio de infraestructura.
- Antes de la puesta en marcha con clientes reales.
