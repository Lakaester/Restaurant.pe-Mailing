# SEGURIDAD DE LA INTEGRACIÓN BFF–ZAMMAD PARA EL MOTOR SLA — 5G.4.3

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.3
**Fecha:** 16/11/2026
**Modo:** diseño. **No se crearon credenciales, usuarios, roles ni tokens.**

---

## 1. Principio

El BFF necesita **dos capacidades separadas** frente a Zammad:

| Capacidad | Uso | Privilegio |
|---|---|---|
| Lectura para sondeo | Lectura de tickets, artículos e historial | Mínimo: solo lectura |
| Administración | Operaciones administrativas del propio BFF (no escriben en Zammad) | Restringido, aislado |

**Regla:** el BFF **no escribe en Zammad** en ninguna fase del diseño. La capacidad administrativa, si existe, se limita a operaciones del propio BFF (gestión de políticas en su base), no a Zammad.

---

## 2. Credencial de sondeo (solo lectura)

### 2.1 Limitación verificada

**VERIFICADO (código).** `app/controllers/user_access_token_controller.rb` 14-48: un token tiene una lista de permisos como `["cti.agent","ticket.agent"]`. **No existe un permiso de solo lectura** en el token.

Un token con `ticket.agent` puede crear, modificar y eliminar tickets según los permisos del usuario al que pertenece.

**Consecuencia:** la garantía de solo lectura **no** puede venir del token. Debe venir del **usuario y su rol**.

### 2.2 Mecanismo propuesto

1. Usuario de servicio dedicado, por ejemplo `sla-readonly`.
2. Rol de servicio que solo tenga **acceso de lectura** al grupo `Soporte Especializado`.
3. Sin permisos de administración ni de cualquier otro grupo.
4. Token de API del usuario de servicio, con expiración.

**INFERIDO:** `TicketPolicy::ReadScope` usa `ACCESS_TYPE = :read` (`app/policies/ticket_policy/read_scope.rb`). El acceso de lectura al grupo debería limitar la lista de tickets a lectura. **PENDIENTE** de prueba con un rol real.

**PENDIENTE:** confirmar que un usuario con solo lectura no puede ejecutar `PUT /api/v1/tickets/:id` ni `POST /api/v1/ticket_articles`. Esta prueba debe hacerse en entorno aislado.

### 2.3 Restricciones del usuario de sondeo

| Atributo | Valor |
|---|---|
| Tipo | Agente |
| Roles | Solo el de lectura |
| Grupos | Solo `Soporte Especializado` (lectura) |
| Permisos de administración | Ninguno |
| Contraseña | Deshabilitada para inicio de sesión interactivo, si la instalación lo permite (PENDIENTE) |
| Expiración del token | Propuesta: 90 días |

### 2.4 Riesgo residual

Aunque el rol sea de lectura, el token **conserva** la lista de permisos del usuario. Si el rol se amplía por error, el token hereda la ampliación. Por eso se propone revisión trimestral del rol.

---

## 3. Credencial administrativa

### 3.1 Alcance

La credencial administrativa **no** se usa en el sondeo. Se usa solo para:

- administrar políticas en la capa del BFF;
- consultar la configuración de la integración;
- operaciones que requieran una persona identificada.

**Regla:** las operaciones administrativas del BFF no requieren ninguna credencial de Zammad, porque el catálogo vive en el BFF. Si una operación necesitara datos de Zammad, usará la credencial de sondeo, nunca la administrativa.

### 3.2 Recomendación

**No crear una credencial administrativa de Zammad para el BFF.** Si se necesitara en el futuro, debe ser una decisión separada, con su propio análisis.

---

## 4. Almacenamiento de credenciales

| Credencial | Dónde se guarda | Quién la lee |
|---|---|---|
| Token de sondeo | Gestor de secretos del entorno o variable de entorno del proceso | Solo el servicio de sondeo |
| Clave HMAC de webhook (si se usa en el futuro) | Gestor de secretos | Solo el receptor |
| Credenciales de base de datos del BFF | Gestor de secretos | Servicio y migraciones |

**Prohibido:**

- Guardar tokens en el repositorio, en `docs/`, en archivos de configuración versionados o en logs.
- Pasar tokens por parámetros de URL.
- Registrar cabeceras `Authorization` en logs.

**Verificado en Zammad:** `Webhook` marca `bearer_token`, `signature_token` y `basic_auth_password` como sensibles (`app/models/webhook.rb` 14). Ese patrón debe replicarse en el BFF.

---

## 5. Rotación

| Credencial | Frecuencia | Procedimiento |
|---|---|---|
| Token de sondeo | 90 días, o ante sospecha | Crear nuevo token; activar en el BFF; revocar el anterior; registrar la fecha |
| Clave HMAC | 180 días | Ventana de doble clave durante la transición |
| Credenciales de base de datos | 180 días | Rotación del gestor de secretos |

**Regla de rotación sin corte:** el BFF acepta el token nuevo antes de revocar el anterior, con un periodo de solapamiento de 24 horas.

---

## 6. Registro de accesos

### 6.1 En el BFF (propuesta)

Cada llamada a Zammad registra:

- fecha y hora UTC;
- método y ruta;
- código de respuesta;
- tiempo de respuesta;
- identificador del ciclo de sondeo;
- **sin** cuerpo de respuesta ni cabeceras de autenticación.

### 6.2 En Zammad (verificado parcialmente)

**VERIFICADO (código):** existe `http_logs` (`app/controllers/http_logs_controller.rb`), orientado a llamadas salientes registradas por la instalación.

**PENDIENTE:** confirmar si las llamadas **entrantes** a la API quedan registradas en Zammad y con qué identificación. No se afirma que existan.

**Verificado:** `audit_logs` registra cambios sobre modelos, no lecturas. Las lecturas del sondeo **no** quedan en `audit_logs`.

**Consecuencia:** el registro de accesos de sondeo debe estar en el BFF.

---

## 7. Permisos mínimos

| Componente | Permiso |
|---|---|
| Servicio de sondeo | Token de lectura; sin escritura en Zammad |
| Motor SLA | Sin acceso directo a Zammad; consume eventos persistidos |
| API de COSE | Solo lectura sobre datos del BFF |
| Administrador del catálogo | Escritura solo en la capa del BFF, con autenticación propia |
| Operaciones de soporte | Acceso de lectura a logs; escritura solo con aprobación |

**Principio:** cada componente solo puede hacer lo que su función requiere.

---

## 8. Protección del BFF

| Control | Propuesta |
|---|---|
| Transporte | TLS en toda llamada, entrante y saliente |
| Verificación TLS hacia Zammad | Obligatoria; sin desactivar la validación del certificado |
| Autenticación de COSE | Token o mTLS, según el despliegue |
| Autenticación administrativa | Identidad individual con MFA si la plataforma lo permite |
| Entrada | Validación de esquema en cada evento recibido |
| Límites de tasa | Propios del BFF hacia COSE; el sondeo hacia Zammad tiene su propia cadencia |
| SSRF | Las URL de Zammad son fijas en configuración; no se aceptan URL de entrada |
| Cabeceras de seguridad | Estándar en la API de COSE |
| Dependencias | Revisión periódica; sin instalación en esta etapa |
| Errores | Respuestas genéricas al exterior; detalle solo en logs internos |

**Verificado en Zammad:** `lib/user_agent.rb` valida la seguridad de destino (`validate_safety`) y las peticiones salientes de webhook usan `verify_ssl` configurable (`app/jobs/trigger_webhook_job.rb` 74-90). El BFF debe mantener verificación TLS estricta.

---

## 9. Datos personales

| Dato | Tratamiento |
|---|---|
| Cuerpo de correo y de WhatsApp | No se almacena en el BFF; solo identificadores y marcas de tiempo |
| Nombre y correo del cliente | No se almacena salvo necesidad de COSE; minimizar |
| Teléfono WhatsApp | Almacenar cifrado o solo hash, según decisión de privacidad (pendiente) |
| Payloads de eventos | Solo campos del contrato; sin cuerpos completos |
| Retención | Según `MODELO_DATOS_DEFINITIVO_SLA_5G4_3.md` §6 |

---

## 10. Riesgos de seguridad

| Riesgo | Nivel | Mitigación |
|---|---|---|
| Token de sondeo con permisos de escritura por error de rol | Alto | Revisión trimestral; prueba de rechazo de escritura en aislado |
| Fuga del token por logs | Alto | Prohibición explícita; redacción de cabeceras |
| Token de sondeo reutilizado por otro servicio | Medio | Usuario dedicado; registro en BFF |
| Suplantación de webhook | Medio (si se usa en el futuro) | HMAC y ventana de rotación |
| Datos personales en el BFF | Medio | Minimización y retención |
| Compromiso de la base del BFF | Alto | Cifrado en reposo; acceso restringido |

---

## 11. Pendientes

| # | Pendiente | Responsable |
|---:|---|---|
| 1 | Confirmar que un rol de solo lectura impide escrituras en la API | Administrador de Zammad (prueba en aislado) |
| 2 | Confirmar si la API registra llamadas entrantes | Administrador de Zammad |
| 3 | Designar gestor de secretos | Infraestructura |
| 4 | Decidir cifrado o hash del teléfono | Privacidad / dirección |
| 5 | Designar responsable administrativo (DP-04) | Dirección |

---

## 12. Confirmación

No se crearon usuarios, roles, tokens, credenciales ni claves. No se modificó Zammad.
