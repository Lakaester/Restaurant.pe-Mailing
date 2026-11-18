# Migración al buzón dedicado de C.O.S.E.

**Proyecto:** MAILING (C.O.S.E.) sobre Zammad 7.2.3
**Estado:** procedimiento documentado. **No ejecutado.**
**Fecha:** 14/11/2026

> No se ha modificado el canal 4, sus credenciales ni el buzón piloto.

---

## 1. Situación actual

| Elemento | Valor |
|---|---|
| Canal | 4 — `Google::Account` |
| Cuenta | `vcastagnino@restaurant.pe` (cuenta personal) |
| Grupo | Soporte Especializado (3) |
| Dirección saliente | `vcastagnino@restaurant.pe` |
| Nombre visible | `C.O.S.E Soporte` |
| Firma | `C.O.S.E. \| Restaurant.pe` |
| `keep_on_server` | `true` |
| Estado | Activo |

**Problema:** es una cuenta personal que se lee en Gmail. Cualquier lectura humana marca el correo como leído y Zammad no lo importa.

---

## 2. Situación objetivo

| Elemento | Valor |
|---|---|
| Cuenta | Buzón **dedicado** de C.O.S.E. (nombre pendiente de TI) |
| Acceso humano | **Ninguno** fuera de Zammad |
| Grupo | Soporte Especializado |
| Dirección saliente | La del buzón dedicado |
| Firma | `C.O.S.E. \| Restaurant.pe` |
| `keep_on_server` | `true` |
| Recepción | Worker mínimo, consulta cada 30 s |

**Principio:** si solo Zammad lee el buzón, el flag `\Seen` lo controla únicamente Zammad y no se pierde ningún correo.

---

## 3. Prerrequisitos (pendientes de TI)

| # | Requisito | Estado |
|---|---|---|
| 1 | Crear el buzón dedicado | Pendiente |
| 2 | Definir su dirección | Pendiente |
| 3 | Confirmar quién tendrá acceso fuera de Zammad (idealmente nadie) | Pendiente |
| 4 | Decidir si se reutiliza el cliente OAuth actual o se crea uno nuevo | Pendiente |
| 5 | Registrar la URI de callback en Google (si cambia el dominio) | Pendiente |
| 6 | Subdominio de producción de Restaurant.pe | Pendiente |

---

## 4. Pasos de migración

### Fase A — Preparación (sin tocar el canal actual)

1. Confirmar el buzón dedicado y su dirección.
2. Decidir el cliente OAuth:
   - **Reutilizar** el actual si el dominio de callback no cambia.
   - **Crear uno nuevo** si cambia el dominio o se quiere aislar.
3. Verificar que la URI de callback registrada en Google coincide con `fqdn`:
   `http(s)://<dominio>/api/v1/external_credentials/google/callback`
4. Comprobar que el buzón está vacío o solo tiene correos de prueba.

### Fase B — Conexión del nuevo buzón

5. En Zammad: **Administración → Canales → Google Email → Añadir cuenta**.
6. Autorizar con la cuenta dedicada.
7. El canal se crea **inactivo**.
8. Antes de activarlo, verificar:
   - Carpeta `INBOX`.
   - **`keep_on_server = true`**.
   - Grupo = Soporte Especializado.
9. Asignar la dirección saliente del grupo al nuevo buzón.
10. Mantener la firma `C.O.S.E. | Restaurant.pe`.

### Fase C — Validación

11. Activar el canal nuevo.
12. Enviar un correo de prueba desde una cuenta externa.
13. Verificar:
    - Ticket creado en Soporte Especializado.
    - Correo marcado como leído, **no borrado**.
    - Sin respuestas automáticas.
14. Responder manualmente y verificar remitente, firma y asunto.
15. Responder desde el cliente y comprobar que se añade al mismo ticket.
16. Repetir con dos correos seguidos para comprobar que no hay duplicados.

### Fase D — Retirada del canal piloto

17. Solo cuando la Fase C esté validada:
    - Desactivar el canal piloto.
    - Conservar sus datos hasta confirmar que no falta nada.
18. No eliminar el canal piloto en la misma sesión de la validación.

---

## 5. Lista de comprobación

| # | Comprobación | Criterio |
|---|---|---|
| 1 | Canal nuevo activo | Sí |
| 2 | `keep_on_server = true` | Sí |
| 3 | Grupo del canal | Soporte Especializado |
| 4 | Dirección saliente del grupo | La del buzón dedicado |
| 5 | Firma asignada | C.O.S.E. |
| 6 | Recepción de correo nuevo | Ticket creado |
| 7 | Correo permanece en Gmail | Marcado como leído |
| 8 | Respuesta manual | Enviada por el canal nuevo |
| 9 | Seguimiento | Mismo ticket |
| 10 | Sin duplicados | Confirmado |
| 11 | Sin respuestas automáticas | Confirmado |
| 12 | Acceso humano al buzón | Ninguno |

---

## 6. Rollback

Mientras el canal piloto siga existiendo y activo:

```ruby
# Desactivar el canal nuevo
Channel.find(<id_nuevo>).update!(active: false)

# Reactivar el piloto si fuera necesario
Channel.find(4).update!(active: true)

# Devolver la dirección saliente al piloto
Group.find(3).update!(email_address_id: 2)
```

**Recomendación:** no retirar el canal piloto hasta que la validación esté cerrada.

---

## 7. Riesgos de la migración

| # | Riesgo | Mitigación |
|---|---|---|
| 1 | Perder correos durante la transición | Mantener ambos canales hasta validar |
| 2 | URI de callback incorrecta | Verificar en Google antes de conectar |
| 3 | Token OAuth del buzón nuevo | Autorizar con la cuenta correcta |
| 4 | Lectura humana del buzón nuevo | Definir acceso restringido desde el inicio |
| 5 | Duplicados si ambos canales están activos | Activar el nuevo y desactivar el viejo el mismo día |
| 6 | Firma o dirección mal asignadas | Revisar la lista de comprobación |

---

## 8. Lo que no se hace en esta etapa

- No se modifica el canal 4.
- No se cambian credenciales ni tokens.
- No se conecta ningún buzón.
- No se activa ni desactiva ningún canal.
- No se toca el worker.
