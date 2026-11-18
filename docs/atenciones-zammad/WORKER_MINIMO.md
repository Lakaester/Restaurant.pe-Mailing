# Worker mínimo — configuración propuesta

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Estado:** propuesta documentada. **No activada.**
**Fecha:** 14/11/2026

> Este documento no crea servicios ni modifica el arranque del sistema. Solo describe la configuración verificada en el código de Zammad 7.2.3.

---

## 1. Objetivo

Ejecutar únicamente los servicios necesarios para:

- Consultar el canal de correo cada 30 segundos.
- Importar los mensajes entrantes.
- Enviar las respuestas manuales y las notificaciones internas.

Todo lo demás queda desactivado para ahorrar memoria.

---

## 2. Servicios

| Servicio | Estado | Cola | Función |
|---|---|---|---|
| `ProcessScheduledJobs` | **Activo** | — | Planificador: `Channel.fetch_async` cada 30 s |
| `ProcessDelayedCommunicationInboundJobs` | **Activo** | `communication_inbound` | Procesa `ChannelFetchJob` |
| `ProcessDelayedJobs` | **Activo** | `default` | Envía respuestas y notificaciones |
| `ProcessDelayedAIJobs` | Desactivado | `ai` | No se usa IA |
| `ProcessSessionsJobs` | Desactivado | — | Solo websocket clásico |
| `ManageSessionsJobs` | Desactivado | — | Depende del anterior |

**[HECHO]** Por defecto `workers = 0`, así que todos los servicios corren como **hilos en un único proceso**.

---

## 3. Variables de entorno (verificadas)

```bash
# Desactivar servicios innecesarios
ZAMMAD_PROCESS_DELAYED_AI_JOBS_DISABLE=true
ZAMMAD_PROCESS_SESSIONS_JOBS_DISABLE=true
ZAMMAD_MANAGE_SESSIONS_JOBS_DISABLE=true

# Logs visibles en desarrollo
BACKGROUND_SERVICES_LOG_TO_STDOUT=1
```

**[HECHO]** El prefijo se deriva del nombre de la clase:
`ZAMMAD_#{service_name.underscore.upcase}` + `_DISABLE`.

---

## 4. Arranque

```bash
cd /home/acast/mailing

ZAMMAD_PROCESS_DELAYED_AI_JOBS_DISABLE=true \
ZAMMAD_PROCESS_SESSIONS_JOBS_DISABLE=true \
ZAMMAD_MANAGE_SESSIONS_JOBS_DISABLE=true \
BACKGROUND_SERVICES_LOG_TO_STDOUT=1 \
setsid nohup bundle exec script/background-worker.rb start \
  > tmp/mailing-run/worker.log 2>&1 &
```

---

## 5. Parada

```bash
# Cierre ordenado (30 s de gracia)
pkill -TERM -f 'background-worker'

# Comprobación
pgrep -af 'background-worker' || echo "detenido"
```

---

## 6. Supervisión

**[HECHO]** El worker **no se reinicia solo**:

- Monitoriza sus procesos hijos cada 5 s.
- Si un hijo muere, se envía TERM a sí mismo.
- Necesita un supervisor externo.

En producción, la forma soportada es un servicio `systemd` con `Restart=always`.
**No se ha creado ningún servicio** en esta etapa.

---

## 7. Límites de memoria

| Escenario | RAM estimada |
|---|---|
| Worker mínimo (3 servicios, hilos) | 400 – 600 MB |
| Worker completo (6 servicios, hilos) | 500 – 700 MB |
| Servicios en fork | 800 MB – 1,2 GB |

**[HECHO]** RAM disponible actual: ~1.500 MB.

**Umbral de alerta propuesto:** si `free -m` muestra menos de 600 MB disponibles, detener el worker.

---

## 8. Logs

| Log | Contenido |
|---|---|
| `tmp/mailing-run/worker.log` | Salida del worker |
| `log/development.log` | Procesamiento de correo, envíos, errores |

Líneas clave:

```
Starting BackgroundServices...
Skipping disabled service ProcessDelayedAIJobs.
execute Channel.fetch_async (try_count 0)...
Process email with msgid '...'
```

---

## 9. Verificación

```sql
-- El planificador debe actualizar last_run cada ~30 s
SELECT method, last_run, running FROM schedulers WHERE method = 'Channel.fetch_async';
```

```bash
# Cola de recepción
bin/rails runner 'puts Delayed::Job.where(queue: "communication_inbound").count'

# Cola de envío
bin/rails runner 'puts Delayed::Job.where(queue: "default").count'
```

---

## 10. Precondiciones antes de arrancar

| # | Condición | Estado |
|---|---|---|
| 1 | Trabajo 17 (`NotificationMailerJob`) en cola `blocked` | **Cumplida** |
| 2 | Sin trabajos de correo en colas procesables | **Cumplida** (0) |
| 3 | Cola `default` revisada y sin envíos no autorizados | **Cumplida** |
| 4 | Autorización explícita para arrancar | **Pendiente** |

---

## 11. Rollback

```bash
# Detener
pkill -TERM -f 'background-worker'

# Devolver el trabajo 17 a su cola original (si se desea)
bin/rails runner 'Delayed::Job.find(17)&.update!(queue: "default")'
```

No hay cambios permanentes: las variables se aplican solo al comando de arranque.

---

## 12. Riesgos

| # | Riesgo | Mitigación |
|---|---|---|
| 1 | Procesa toda la cola `default` | Revisada: 0 trabajos de correo |
| 2 | Editar código en desarrollo reinicia el worker | No editar durante las pruebas |
| 3 | Sin supervisor, una caída lo deja parado | systemd en producción |
| 4 | RAM justa | Perfil mínimo y umbral de alerta |
| 5 | Sin `ProcessSessionsJobs`, el websocket clásico pierde sesiones | La interfaz nueva usa Redis |
