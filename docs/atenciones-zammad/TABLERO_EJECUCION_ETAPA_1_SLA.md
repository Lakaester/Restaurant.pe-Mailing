# TABLERO DE EJECUCIÓN — ETAPA 1 — EPIC-SLA-01

**Proyecto:** MAILING — C.O.S.E. sobre Zammad 7.2.3
**Épica:** EPIC-SLA-01
**Etapa:** 1 — Cierre y preparación para implementación
**Documento maestro:** `EPIC_IMPLEMENTACION_SLA_COSE.md`
**Fecha:** 16/11/2026
**Modo:** AGENT — auditoría de solo lectura y planificación.
**Naturaleza:** documento de seguimiento. **No implementa, no configura y no modifica ningún sistema.**
**Autorización de esta sesión:** leer documentación y código, consultar el estado real en solo lectura y crear este único documento.
**Estado de la etapa:** **`En revisión`** — decisiones confirmadas; aprobaciones condicionales; no cerrada.

> **Regla de lectura.** Este tablero no crea reglas nuevas ni cambia valores de la matriz. Consolida el estado comprobado, las decisiones pendientes y el plan de las 13 pruebas F0 que faltan. Cuando hay conflicto, prevalecen `EPIC_IMPLEMENTACION_SLA_COSE.md`, `CORRECCION_ALCANCE_EMAIL_SLA_5G4_4.md` y los seis documentos de 5G.4.5.

---

## 0. Resumen ejecutivo

| Elemento | Valor |
|---|---|
| Etapa | 1 — Cierre y preparación |
| Historias de la etapa | 8 (EP1-01 a EP1-08) |
| Historias completadas | **2** (EP1-01, EP1-03) |
| Pruebas Fase 0 | **3 `passed` + F0-01 apertura**; 7 `pending`, 3 `blocked`, 4 `deferred` |
| Decisiones confirmadas | **DT-01** (BFF como fuente), **DT-02** (65 con marca), **DP-04** (Soporte) y exclusión de las 7 no servicio |
| Aprobaciones condicionales | **AP-01**, **AP-02** y **AP-03** en `conditional_pending_final_validation` |
| Catálogo oficial | **Localizado**: `CategoryData.ts`, 13 categorías / 65 subcategorías |
| Coincidencia catálogo ↔ árbol Zammad | **13/13 categorías, 65/65 subcategorías** |
| Coincidencia matriz ↔ catálogo | **30/30 filas** |
| Subcategorías sin fila en la matriz | **35 de 65** (fuera de catálogo → respaldo 36 h) |
| Escrituras realizadas en esta sesión | **0** |
| Cambios técnicos realizados | **0** |

**Conclusión de la etapa:** la documentación está madura, el catálogo está localizado y verificado, y las decisiones funcionales están confirmadas. La etapa **no puede cerrarse** todavía: falta la validación final de AP-01, AP-02 y AP-03, la credencial de solo lectura, la ventana y 13 pruebas. Nada de eso se resuelve con análisis técnico adicional: requiere autorización y ejecución controlada.

---

## 1. Estado general de la etapa

### 1.1 Ficha de la etapa

| Campo | Definición |
|---|---|
| Objetivo | Dejar el proyecto en condiciones de autorizar la implementación del motor, sin ambigüedades documentales ni decisiones críticas abiertas. |
| Resultado esperado | Documentos aprobados, matriz ratificada, decisiones confirmadas, Fase 0 con 3 `passed` + F0-01 cierre + 6/6 + condicionales y 4 diferidas, línea base congelada. |
| Compuerta de salida | 3 `passed` + F0-01 cierre + 6/6 + 10/11 con 403 + caso 7 documentado + decisiones confirmadas + AP-01/02/03 validadas + sin cambios técnicos no autorizados. |
| Estado actual | `En revisión` |
| Avance de historias | 2 de 8 |
| Avance de pruebas F0 | 4 con evidencia de lectura (3 `passed` + F0-01 apertura) |
| Bloqueante principal | Validación final de AP-01/02/03, credencial de solo lectura y ventana de pruebas. |

### 1.2 Método de esta auditoría

| Aspecto | Detalle |
|---|---|
| Momento del snapshot | 2026-11-16 21:00 UTC (16:00 hora local de Perú) |
| Consultas a base de datos | `psql` con `SELECT` únicamente. Sin DDL, sin DML, sin `FOR UPDATE`. |
| Consultas al sistema | `ps`, `ss`, `systemctl`, `redis-cli info/dbsize/scan`, lectura de archivos. |
| Servicios | **No se inició ni se detuvo ningún servicio.** |
| Rails | No se ejecutó `rails runner` ni ninguna tarea de la aplicación. |
| Secretos | No se reproducen contraseñas, tokens ni credenciales OAuth en este documento. |
| Documentos previos | Leídos, no modificados. |

### 1.3 Estado comprobado frente al estado documentado

La línea base de 5G.4.5 se verificó el 16/11/2026 antes del cierre documental. Este snapshot se tomó después y **difiere en dos puntos**, ambos explicados en §1.4.

| Elemento | Documentado (5G.4.5) | Comprobado ahora | Lectura |
|---|---:|---:|---|
| Políticas SLA nativas (`slas`) | 0 | **0** | Sin cambios |
| Tablas propias del motor (`sla_*`) | 0 | **0** | No existen; el motor no está implementado |
| Calendarios | 2 | **2** | `My Calendar` y `Soporte Especializado` |
| Triggers | 3 | **3** | 0 activos |
| Webhooks | 0 | **0** | Sin cambios |
| Tickets | 2 | **2** | IDs 1 y 7 |
| Artículos | 5 | **5** | Sin cambios |
| Usuarios | 6 | **6** | Sin usuario técnico de solo lectura |
| Grupos | 3 | **3** | `Users`, `some group1`, `Soporte Especializado` |
| Roles | 3 | **3** | `Admin`, `Agent`, `Customer` |
| Knowledge bases | 0 | **0** | Sin cambios |
| Mentions | 0 | **0** | Sin cambios |
| Jobs de escalado | 0 | **0** | Sin cambios |
| Schedulers | 30 | **30** | 30 activos en base |
| `audit_logs` | 29 | **29** | Sin cambios |
| `histories` | 44 | **46** | **+2** (ver §1.4) |
| Worker | Detenido | **Corriendo** | **Cambió** (ver §1.4) |
| `fqdn` | `localhost:3000` | `localhost:3000` | No apto para producción |
| `http_type` | `http` | `http` | No apto para producción |
| `product_name` | C.O.S.E | **C.O.S.E** | Correcto |
| `system_online_service` | — | **false** | Sin servicio en línea |

### 1.4 Diferencias detectadas y su lectura

**Diferencia 1 — El worker está corriendo.**
En el snapshot aparecen `puma` (3000), `websocket-server` (6042) y `background-worker` activos, con unos 10 minutos de antigüedad al momento de la medición. La línea base documentada registraba el worker detenido. El arranque no lo hizo esta auditoría: corresponde a **actividad concurrente de otra sesión de operación sobre la instancia local** (procesos y scripts de arranque en la carpeta temporal de trabajo, con marcas de tiempo de 20:49–20:53 UTC).

**Diferencia 2 — Dos historias nuevas.**
`histories` pasó de 44 a 46. Las dos filas nuevas son de tipo `notification`, sobre el ticket 7, creadas a las 20:51:27 y 20:51:45 UTC, con destino `vcastagnino@restaurant.pe`. Coinciden con el arranque del worker. **No se modificó el ticket**: su `updated_at` sigue en 2026-11-14 15:29:09 UTC y su estado sigue siendo `open`.

**Lectura conjunta:** el sistema está en un estado **operativo y cambiante**, no congelado. Para ejecutar Fase 0 hace falta una ventana acordada con el worker y el buzón en un estado conocido. Mientras el worker esté activo y el canal Gmail esté habilitado, el estado puede cambiar durante las pruebas.

### 1.5 Estado del correo piloto

| Elemento | Estado comprobado |
|---|---|
| Canal de correo activo | `Google::Account`, ID 4, activo |
| Cuenta | `vcastagnino@restaurant.pe` (cuenta piloto, no el buzón definitivo de Soporte Especializado) |
| Entrada | IMAP con XOAUTH2, `keep_on_server: true` |
| Salida | SMTP `smtp.gmail.com:465`, XOAUTH2 |
| Dirección de correo | `C.O.S.E Soporte` → `vcastagnino@restaurant.pe` (canal 4) |
| Canal de ejemplo | `Email::Account` ID 3, **inactivo** (`mx1.example.com`, usuario ficticio) |
| Notificación | `Email::Notification` ID 2 activo por `sendmail`; ID 1 inactivo de ejemplo |
| Credenciales | **Almacenadas en texto plano en `channels.options`** (tokens OAuth y `client_secret`). No se reproducen aquí. Es un hallazgo de seguridad, no una acción. |

**Regla vigente:** el buzón definitivo no se conecta mientras Zendesk lo gestione. El canal activo es el piloto.

### 1.6 Estado de la clasificación en Zammad

| Elemento | Estado comprobado |
|---|---|
| Atributo `dominio` | Existe, activo, tipo `input` (texto libre, máx. 255). Visible en creación y edición de ticket para agentes. |
| Atributo `categoria_subcategoria` | Existe, activo, tipo `tree_select`. Visible en creación y edición de ticket para agentes. |
| Columna en `tickets` | `dominio varchar NULL` y `categoria_subcategoria varchar NULL` |
| Contenido del árbol | **13 categorías y 65 subcategorías** |
| Valor almacenado | El slug de la hoja (por ejemplo `ajustes_fe`), no la etiqueta visible |
| Ticket 7 | `dominio = 'gmail.com'`; `categoria_subcategoria = ''` (**cadena vacía, no NULL**) |
| Ticket 1 | Sin `dominio` y sin clasificación |
| Catálogo oficial en disco | `CategoryData.ts` localizado; **13 categorías / 65 subcategorías** |
| Coincidencia árbol ↔ `CategoryData.ts` | **Idéntica**: mismas 13 categorías, mismas 65 subcategorías, cero diferencias |

### 1.7 Estado de PostgreSQL y Redis

| Elemento | Estado comprobado |
|---|---|
| Motor | PostgreSQL **16.15** local (Ubuntu 24.04) |
| Base | `mailing_development` (entorno de desarrollo, no producción) |
| Tablas en `public` | 131 |
| Tablas del motor SLA | **Ninguna** (`sla_*` no existe) |
| Redis | 7.0.15, activo en 127.0.0.1:6379 |
| Cola Redis | `dbsize = 0` al momento del snapshot |
| Jobs diferidos | 1 registro en `delayed_jobs`, 0 fallidos |

**Aclaración:** PostgreSQL 16.15 es el motor **local de Zammad**. El PostgreSQL 15.4 documentado en etapas anteriores corresponde a la base **remota de COSE** (`v_unificado_norm`). Son dos motores distintos y no deben confundirse.

### 1.8 Grupos, roles y permisos

| Elemento | Estado comprobado |
|---|---|
| Usuarios | 6 (1 inactivo, 2 clientes, 2 agentes-admin, 1 agente) |
| Roles | `Admin`, `Agent`, `Customer` |
| Accesos por grupo | **Todos `full`**; ningún usuario con acceso `read` |
| Usuario técnico de solo lectura | **No existe** |
| Token de API | **No existe**. Solo hay un token de tipo `Signup` del usuario 5, no usado, no persistente y sin caducidad. |
| Implicación | F0-02 no puede ejecutarse: no hay credencial de solo lectura que probar. |

### 1.9 Lo que esta sesión no hizo

No se creó ni modificó ningún usuario, rol, grupo, permiso, token, canal, buzón, calendario, trigger, webhook, SLA, atributo, ticket, artículo, tabla, migración, índice ni configuración. No se envió correo. No se inició ni detuvo ningún servicio. No se instalaron dependencias. No se tocó CSS, Zendesk ni COSE. No se modificó ninguno de los 60 documentos existentes.

---

## 2. Pendientes y decisiones

### 2.1 Tablero de decisiones

| ID | Materia | Estado | Bloquea | Qué falta exactamente |
|---|---|---|---|---|
| **DP-04** | Responsable y proceso del catálogo | **`Aprobada`** | — | **Soporte** (responsable funcional y operativo) |
| **DT-01** | Fuente de la clasificación manual | **`Aprobada`** | — | **BFF** como fuente; Zammad como espejo opcional |
| **DT-02** | Catálogo completo del selector | **`Aprobada`** | — | **65 subcategorías con marca de política** |
| **AP-01** | Aprobación definitiva del cierre 5G.4.5 | **`conditional_pending_final_validation`** | Inicio de etapa 2 | Validación final expresa |
| **AP-02** | Ratificación definitiva del alcance Email-only | **`conditional_pending_final_validation`** | Comunicación y aceptación | Validación final expresa |
| **AP-03** | Autorización para ejecutar Fase 0 | **`conditional_pending_final_validation`** | EP1-05 a EP1-07 | Validación final expresa |
| **AP-04** | Alcance y grupo del piloto | **`Pendiente`** | EP1-08; etapa 5 | Definición del grupo y del buzón de prueba |
| **AP-05** | Formato y periodicidad de reportes | **`Pendiente`** | Etapa 6 | Definición aprobada |
| **DP-07** | Infraestructura de persistencia | `En revisión` | Etapa 2 | Autorización de instancia, respaldo y restauración |
| **DEP-04** | Usuario técnico `read` y token | **`Pendiente`** | F0-02, F0-03, F0-04 | Creación autorizada |
| **DEP-05** | Buzón de prueba y ventana de escritura | **`Pendiente`** | F0-06 a F0-09 | Buzón identificado y ventana aprobada |
| **DEP-06** | Base del BFF para F0-12 a F0-14 | **`Pendiente`** | F0-12, F0-13, F0-14, F0-16 | Instancia de prueba del BFF |

**Actualización 16/11/2026:** DP-04, DT-01 y DT-02 están confirmadas y no se vuelven a solicitar. AP-01, AP-02 y AP-03 quedan en `conditional_pending_final_validation` y no son aprobaciones definitivas. El análisis de §2.2 a §2.4 se conserva como fundamento, no como decisión pendiente.

### 2.2 DP-04 — Responsable y proceso del catálogo (confirmado)

**Qué es:** definir quién gobierna el catálogo oficial de categorías y subcategorías, y con qué proceso se agrega, cambia, revisa o retira una combinación.

**Por qué es crítica:** el 32,51 % del volumen clasificado de Email (1.016 de 3.125 tickets) está fuera de la matriz y depende del respaldo de 36 h. Sin dueño ni proceso, el respaldo se convierte en la métrica principal y la matriz deja de representar la operación.

**Qué se necesita para cerrarla:**

1. Un rol designado (no una persona nombrada en este documento).
2. Un proceso escrito de actualización del catálogo.
3. La regla de cómo se incorporan los cinco rótulos de mayor volumen (`consultas generales`, `consultas fe`, `comunicacion de baja`, `seguimiento de cdt certificado`, `mejoras personalizadas`).
4. La relación entre el catálogo de 65 subcategorías y la matriz de 30 filas.
5. El registro de la decisión.

**Lo que este tablero no hace:** no propone nombres, no asigna el rol y no fija plazos.

**Decisión confirmada (16/11/2026):** **Soporte** es el responsable funcional y operativo del catálogo. La lista anterior queda como checklist del proceso a documentar, no como decisión pendiente.

### 2.3 DT-01 — Fuente de la clasificación manual

**Pregunta:** ¿la clasificación manual se toma del campo `categoria_subcategoria` de Zammad o de un registro propio del BFF?

**Evidencia comprobada en esta sesión:**

| Hecho | Evidencia |
|---|---|
| `categoria_subcategoria` existe y está activo | `object_manager_attributes` id 61, `tree_select` |
| Es visible para el agente | Pantallas `create_middle` y `edit` para `ticket.agent` |
| Tiene columna propia en `tickets` | `varchar NULL`, valor por defecto vacío |
| Contiene el catálogo completo | 13 categorías / 65 subcategorías |
| Almacena el slug de la hoja | El árbol define `value` (slug) y `name` (etiqueta) |
| `dominio` **no** sirve como fuente | Es texto libre de 255 caracteres, sin catálogo |
| Puede quedar vacío | Ticket 7 tiene `''` (longitud 0), no `NULL` |
| Hay slugs duplicados entre categorías | `cambio_de_razón_social` (FACTURACIÓN ELECTRÓNICA y ADMINISTRATIVO), `caída_del_servidor` y `redes_y_conexiones` (OPERATIVO y SERVIDOR) |
| El mapa slug → etiqueta es global | Un slug duplicado no identifica la categoría padre |

**Consecuencia técnica:** el campo **es viable como fuente**, pero por sí solo **no desambigua** la categoría en los tres slugs duplicados. Si el asesor elige `ADMINISTRATIVO > Cambio de razón social`, el valor almacenado es el mismo que `FACTURACIÓN ELECTRÓNICA > Cambio de razón social`. El motor no puede inferir cuál se eligió sin un dato adicional.

**Opciones evaluadas (decisión ya tomada):**

| Opción | Descripción | Ventaja | Riesgo |
|---|---|---|---|
| A | Leer solo `categoria_subcategoria` de Zammad | Una sola fuente; sin duplicación | Ambigüedad en 3 slugs; el motor tendría que inferir o asumir |
| B | Registrar en el BFF el par (categoría, subcategoría) que envía el frontend al clasificar | Elimina la ambigüedad; el par es explícito y auditable | Requiere que el frontend envíe ambos valores y que el BFF los guarde |
| C | Híbrido: leer Zammad y corregir el par con el historial de la pantalla | Tolera datos antiguos | Más complejo; sigue dependiendo de que el origen sea inequívoco |

**Decisión confirmada (DT-01):** alternativa **B**. El BFF registra el par (categoría oficial, subcategoría oficial); `categoria_subcategoria` queda como **espejo opcional** sujeto a verificación de divergencias.

**Condiciones que habría exigido la opción A (descartada):**

1. Tratar `''` y `NULL` como no clasificado.
2. Resolver el slug duplicado con una regla explícita y auditada, nunca por orden de aparición.
3. Normalizar acentos y mayúsculas para comparar con la matriz.
4. Registrar la fecha de clasificación desde el historial.

### 2.4 DT-02 — Catálogo completo del selector

**Pregunta:** ¿el selector de clasificación muestra las 65 subcategorías, solo las 30 de la matriz o las 65 con marca de política?

**Evidencia comprobada en esta sesión:**

| Hecho | Resultado |
|---|---|
| `CategoryData.ts` localizado | `restaurant-bi-fase1/restaurant-bi/frontend/src/components/workspace/CategoryData.ts` |
| Categorías | **13** |
| Subcategorías | **65** |
| Comparación con el árbol de Zammad | **Idéntica**: 0 diferencias de categoría y de subcategoría |
| Comparación con la matriz de 30 filas | **30/30** coinciden en categoría + subcategoría (normalizando acentos) |
| Subcategorías sin fila en la matriz | **35** |
| Slugs duplicados | **3** |

**Distribución del catálogo:**

| Categoría | Subcategorías | En la matriz | Fuera de la matriz |
|---|---:|---:|---:|
| FACTURACIÓN ELECTRÓNICA | 14 | 10 | 4 |
| LOGÍSTICA | 5 | 2 | 3 |
| INTEGRACIONES | 7 | 5 | 2 |
| SOFTWARE | 6 | 3 | 3 |
| GESTIÓN | 6 | 4 | 2 |
| ADMINISTRATIVO | 6 | 2 | 4 |
| OPERATIVO | 4 | 1 | 3 |
| CAPACITACIÓN | 7 | 2 | 5 |
| SERVIDOR | 2 | 0 | 2 |
| SIN HOMOLOGAR | 3 | 0 | 3 |
| RECLAMO | 1 | 0 | 1 |
| QUEJA | 3 | 0 | 3 |
| DEVOLUCIÓN | 1 | 1 | 0 |
| **Total** | **65** | **30** | **35** |

**Opciones evaluadas (decisión ya tomada):**

| Opción | Descripción | Efecto |
|---|---|---|
| A | Selector con las 65 subcategorías | Cobertura total; 35 quedan con respaldo 36 h |
| B | Selector solo con las 30 de la matriz | Elimina el respaldo, pero impide clasificar el 32,51 % del volumen real |
| C | Selector con las 65, marcando cuáles tienen política y cuáles van a respaldo | Transparencia total; requiere que la interfaz muestre la marca |

**Decisión confirmada (DT-02):** alternativa **C**. El selector muestra las 65 subcategorías con marca de política (27 con SLA, 3 sin evidencia, 28 con respaldo).

**Advertencia:** elegir B dejaría sin clasificar a los 1.016 tickets históricos fuera de catálogo y contradiría la regla BR-43 (respaldo solo fuera de catálogo).

#### 2.4.1 Contraste con las tres combinaciones sin evidencia

Las tres combinaciones con muestra insuficiente **están dentro de las 30 filas de la matriz**, pero **no tienen SLA**:

| Categoría oficial | Subcategoría | n | Tratamiento |
|---|---|---:|---|
| FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | `no_policy` / `insufficient_evidence`; sin plazo; sin respaldo 36 h; fuera del denominador |
| INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | Igual |
| INTEGRACIONES | Error integracion | 4 | Igual |

**Consecuencia para DT-02:** un selector que solo distinga «con política» y «fuera de catálogo» es insuficiente. Necesita **tres estados visibles**: con política (27), sin evidencia (3) y fuera de catálogo (35). Si se confunden, el motor asignaría un plazo a una combinación que la matriz declaró sin evidencia.

#### 2.4.2 Contraste con las diferencias de categoría de COSE

La matriz oficial y `CategoryData.ts` coinciden entre sí. La divergencia está entre ambos y la homologación histórica de COSE, en **10 de 30 filas**:

| # | Subcategoría | Categoría oficial (matriz y `CategoryData.ts`) | Categoría en COSE |
|---:|---|---|---|
| 1 | Nueva licencia o sucursal | ADMINISTRATIVO | GESTION |
| 2 | Solicitud de migración | ADMINISTRATIVO | GESTION |
| 3 | Solicitud agenda capacitación | CAPACITACION | GESTION |
| 5 | Solicitud de devolución | DEVOLUCION | GESTION |
| 13 | Emisión de invoice | FACTURACION ELECTRONICA | ADMINISTRATIVO |
| 16 | Renovación certificado normal | GESTION | FACTURACION ELECTRONICA |
| 17 | Venta de CDT certificado | GESTION | FACTURACION ELECTRONICA |
| 24 | Error integracion | INTEGRACIONES | SOFTWARE |
| 26 | Error logistica | LOGISTICA | SOFTWARE |
| 29 | Seguimiento de errores | SOFTWARE | GESTION |

**Consecuencia para DT-02:** el selector y la clave de política deben generarse desde la categoría **oficial**, no desde la homologación de COSE. Si el selector se construyera desde COSE, diez combinaciones quedarían con una categoría distinta a la de su política y los reportes por categoría no cuadrarían con la matriz. La diferencia se documenta como divergencia histórica, no como error del motor.

**Decisión confirmada (DEC-05):** las 7 subcategorías no servicio (SIN HOMOLOGAR: Sin dato, Duplicado o spam, No contestó; RECLAMO: Reclamo; QUEJA: Servicio, Producto, Otro) quedan **excluidas del motor SLA**, sin SLA y sin respaldo de 36 h.

### 2.5 AP-01, AP-02 y AP-03 — Aprobaciones condicionales

| Aprobación | Qué ratifica | Estado |
|---|---|---|
| AP-01 | Los seis documentos de 5G.4.5 como base contractual | `conditional_pending_final_validation` |
| AP-02 | El alcance exclusivamente Email y el retiro de WhatsApp | `conditional_pending_final_validation` |
| AP-03 | La ejecución de Fase 0 | `conditional_pending_final_validation` |

**Regla:** las tres siguen condicionales. No se convierten en aprobaciones definitivas hasta la validación final expresa, y ninguna prueba se ejecuta con una aprobación condicional.

---

## 3. Matriz de las 13 pruebas pendientes

### 3.1 Clasificación por categoría

| Categoría | Definición | Pruebas | Total |
|---|---|---|---:|
| **A** | Ejecutables en solo lectura | F0-05, F0-15 | 2 |
| **B** | Requieren autorización para escritura en entorno local | F0-07, F0-08, F0-09 | 3 |
| **C** | Requieren correo piloto | F0-06 | 1 |
| **D** | Requieren pruebas controladas de permisos o seguridad | F0-02, F0-03, F0-04 | 3 |
| **E** | No deben ejecutarse todavía (dependen de la base del BFF) | F0-12, F0-13, F0-14, F0-16 | 4 |
| | | **Total** | **13** |

**Nota:** F0-06 es de categoría C y también genera escrituras (crear ticket y enviar correo). F0-02 crea un usuario, pero su naturaleza es de seguridad (categoría D). F0-12, F0-13, F0-14 y F0-16 son de naturaleza B o A, pero se clasifican como E porque el objeto que prueban (la base del BFF) **no existe**.

### 3.2 Ficha de cada prueba

#### F0-02 · Credencial de solo lectura

| Campo | Detalle |
|---|---|
| Objetivo | Probar que la credencial de la integración no puede escribir |
| Procedimiento propuesto | 1) Crear un usuario técnico con `groups_users.access = 'read'` en el grupo de soporte del **piloto** y emitir su token (F0-02-P). 2) Repetir en la **instancia aislada** con un usuario y token propios (F0-02-I). 3) Ejecutar `GET /api/v1/tickets` en cada ambiente. 4) Verificar que ninguno tiene permiso `admin`. |
| Entorno requerido | Piloto e instancia aislada, **separados**; autorización de administración |
| Datos necesarios | Usuario y token en cada ambiente; **no se comparten** |
| Lectura o escritura | **Escritura** (crea usuario y token) |
| Riesgo | Medio: crea una identidad nueva; un error de permisos deja un usuario con más acceso del previsto |
| Resultado esperado | Lectura correcta en cada ambiente; `access = 'read'`; sin `admin`; tokens distintos |
| Evidencia | `F0-02_credential_pilot.json` y `F0-02_credential_isolated.json` (sin token) |
| Autorización necesaria | **Sí**: creación en dos ambientes |
| Categoría | **D** |

#### F0-03 · 11 escrituras rechazadas

| Campo | Detalle |
|---|---|
| Objetivo | Demostrar que cada intento de escritura es rechazado con 403/401 |
| Procedimiento propuesto | Con la credencial F0-02-I, **solo en la instancia aislada**, ejecutar las 11 llamadas definidas en F0-03 del documento de criterios: `PATCH` ticket, `POST` artículo, `POST` ticket, `DELETE` ticket, `PUT` ticket, `POST` usuario, `PUT` usuario, `PUT` settings, `POST` trigger, `POST` webhook, `POST` SLA. Registrar código y cuerpo. |
| Entorno requerido | Zammad local; token de F0-02; **instancia aislada**; ventana controlada |
| Datos necesarios | Ticket desechable declarado; payloads mínimos |
| Lectura o escritura | **Intento de escritura**; debe ser rechazado |
| Riesgo | **Alto si falla**: un solo `2xx` escribe de verdad (título, artículo, usuario, trigger, webhook o SLA) |
| Resultado esperado | Casos 1-6 y 8-11: **403**. Caso 7: **200** contra cliente desechable (capacidad legítima) y **403** contra agente/admin. Ningún `2xx` inesperado |
| Evidencia | `F0-03_negative_writes.json` con código y cuerpo de cada respuesta |
| Autorización necesaria | **Sí**: ventana, token e instancia aislada |
| Categoría | **D** |

**Atención especial:** esta es la prueba de mayor riesgo de la fase. Si la credencial está mal configurada, la prueba **crea** lo que intenta prohibir. Debe ejecutarse con contadores antes/después y con un procedimiento de reversión escrito. El caso 7 se ejecuta contra un agente/admin, nunca contra un cliente. Si no hay instancia aislada, la prueba queda **bloqueada**. No se ejecuta en esta sesión.

#### F0-04 · Inmutabilidad de la configuración

| Campo | Detalle |
|---|---|
| Objetivo | Probar que la credencial no puede leer ni alterar configuración administrativa |
| Procedimiento propuesto | `GET /api/v1/settings`, `GET /api/v1/calendars`, `GET /api/v1/slas` con el token técnico; registrar códigos |
| Entorno requerido | Zammad local; token de F0-02 |
| Datos necesarios | Ninguno adicional |
| Lectura o escritura | **Lectura**; se espera 403 por falta de `admin` |
| Riesgo | Bajo |
| Resultado esperado | **403** en los tres |
| Evidencia | `F0-04_admin_endpoints.json` |
| Autorización necesaria | **Sí** (depende de F0-02) |
| Categoría | **D** |

#### F0-05 · Superficie de lectura suficiente

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que la API expone los 11 campos que el motor necesita |
| Procedimiento propuesto | Sobre el ticket 7 y su artículo 3, leer y registrar: `created_at`, `close_at`, `last_close_at`, `state_id`, `sender`, `type`, `internal`, `preferences.delivery_status`, `preferences.delivery_status_date`, `preferences.delivery_retry`, y una entrada de historial con `attribute`, `value_to` y `created_at` |
| Entorno requerido | Zammad local; token de F0-02 |
| Datos necesarios | Ticket desechable declarado con un artículo de `delivery_status = success`; no usar tickets operativos |
| Lectura o escritura | **Solo lectura** |
| Riesgo | Bajo |
| Resultado esperado | **11 de 11** campos presentes |
| Evidencia | `F0-05_api_surface.json` |
| Autorización necesaria | **Sí** (depende de F0-02) |
| Categoría | **A** |

**Evidencia previa disponible:** en esta auditoría se verificó en base de datos que los campos existen y que el artículo 3 tiene `delivery_status = success` y `delivery_status_date` poblado. Falta la comprobación **a través de la API con la credencial técnica**.

#### F0-06 · La confirmación eleva `updated_at`

| Campo | Detalle |
|---|---|
| Objetivo | Probar que la confirmación de envío se propaga al ticket |
| Procedimiento propuesto | 1) Crear un ticket de prueba. 2) Registrar `ticket.updated_at`. 3) Enviar una respuesta pública de agente. 4) Esperar `delivery_status = success`. 5) Volver a leer `ticket.updated_at`. 6) Comparar ambas marcas. |
| Entorno requerido | Zammad local con worker, canal piloto y **barrera técnica del piloto** activos |
| Datos necesarios | Buzón de prueba; destinatario allowlisted; ticket desechable |
| Lectura o escritura | **Escritura** (crea ticket y envía correo) |
| Riesgo | Medio: envía un correo real a un destinatario; si el destinatario no es controlado, hay fuga |
| Resultado esperado | `ticket.updated_at` posterior a `article.delivery_status_date`; diferencia < 5 s entre ambas marcas UTC; `success` = aceptación SMTP, no entrega |
| Evidencia | `F0-06_touch.json` con destinatario verificado y ambas marcas |
| Autorización necesaria | **Sí**: buzón, destinatario, ventana y **barrera técnica del piloto** |
| Categoría | **C** (y B por escritura) |

**Fundamento ya verificado:** el artículo 3 del ticket 7 tiene `delivery_status = success` a las 14:32:10 UTC, con `created_at` 04:57:54 UTC. Esa diferencia de 9 h 34 min confirma que la confirmación es posterior a la creación, pero **no** prueba todavía el `touch` del ticket. Eso es lo que mide F0-06.

#### F0-07 · Inmutabilidad de `close_at`

| Campo | Detalle |
|---|---|
| Objetivo | Confirmar que `close_at` es el primer cierre y no se reescribe |
| Procedimiento propuesto | 1) Cerrar un ticket de prueba; registrar `close_at` y `last_close_at`. 2) Reabrir. 3) Cerrar de nuevo. 4) Comparar ambos valores. |
| Entorno requerido | Zammad local; ticket de prueba |
| Datos necesarios | Ticket de prueba (no un cliente real) |
| Lectura o escritura | **Escritura** (cambios de estado) |
| Riesgo | Medio: altera el estado de un ticket; debe ser de prueba y quedar documentado |
| Resultado esperado | `close_at` **idéntico**; `last_close_at` **distinto** |
| Evidencia | `F0-07_close_at.json` |
| Autorización necesaria | **Sí**: ventana y ticket de prueba |
| Categoría | **B** |

**Atención especial:** esta prueba es la base del ciclo 1. Si `close_at` se reescribiera, la métrica oficial de resolución quedaría invalidada. No se ejecuta en esta sesión.

#### F0-08 · `pending close` no cierra

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el estado de tipo `pending action` no fija `close_at` |
| Procedimiento propuesto | Llevar un ticket de prueba a `pending close`; leer `close_at` y `pending_time` |
| Entorno requerido | Zammad local; ticket de prueba |
| Datos necesarios | Ticket de prueba |
| Lectura o escritura | **Escritura** (cambio de estado) |
| Riesgo | Bajo: reversible |
| Resultado esperado | `close_at` **vacío** |
| Evidencia | `F0-08_pending_close.json` |
| Autorización necesaria | **Sí** |
| Categoría | **B** |

#### F0-09 · `merged` no cierra

| Campo | Detalle |
|---|---|
| Objetivo | Probar que una fusión no fija `close_at` |
| Procedimiento propuesto | Fusionar un ticket de prueba en otro; leer estado y `close_at` |
| Entorno requerido | Zammad local; dos tickets de prueba |
| Datos necesarios | Dos tickets de prueba |
| Lectura o escritura | **Escritura** (fusión) |
| Riesgo | Medio: la fusión es difícil de revertir sin residuos |
| Resultado esperado | Estado `merged`, tipo `merged`, `close_at` **vacío** |
| Evidencia | `F0-09_merged.json` |
| Autorización necesaria | **Sí** |
| Categoría | **B** |

#### F0-12 · Evento duplicado

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el mismo evento 100 veces produce una sola fila |
| Procedimiento propuesto | Insertar 100 veces el mismo evento con la misma clave de idempotencia; contar filas y transiciones |
| Entorno requerido | **Base de pruebas del BFF** (no existe todavía) |
| Datos necesarios | Un evento de ejemplo con `idempotency_key` calculada |
| Lectura o escritura | **Escritura** en la base del BFF |
| Riesgo | Bajo (entorno aislado) |
| Resultado esperado | 1 fila en `sla_event`; 1 transición aplicada |
| Evidencia | `F0-12_duplicates.md` |
| Autorización necesaria | **Sí**: creación de la base del BFF |
| Categoría | **E** |

#### F0-13 · Eventos fuera de orden

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el orden de llegada no altera el resultado |
| Procedimiento propuesto | Aplicar los eventos de un ticket en orden normal y en orden inverso; comparar estado final |
| Entorno requerido | Base de pruebas del BFF |
| Datos necesarios | Secuencia de eventos de un ticket de ejemplo |
| Lectura o escritura | **Escritura** en la base del BFF |
| Riesgo | Bajo |
| Resultado esperado | Mismo `first_response_at`, mismo `outcome`, mismo `closed_at` |
| Evidencia | `F0-13_out_of_order.md` |
| Autorización necesaria | **Sí** |
| Categoría | **E** |

#### F0-14 · Recuperación tras caída

| Campo | Detalle |
|---|---|
| Objetivo | Probar que una caída no pierde ni duplica |
| Procedimiento propuesto | 1) Iniciar un run. 2) Interrumpir el proceso a mitad. 3) Reiniciar. 4) Verificar watermark y eventos. |
| Entorno requerido | Base de pruebas del BFF; proceso controlable |
| Datos necesarios | Watermark inicial y un lote de eventos |
| Lectura o escritura | **Escritura** en la base del BFF |
| Riesgo | Medio: requiere matar un proceso de prueba |
| Resultado esperado | El run queda `failed`; el watermark **no** avanza; al reiniciar se recupera el hueco sin duplicar |
| Evidencia | `F0-14_recovery.md` |
| Autorización necesaria | **Sí** |
| Categoría | **E** |

#### F0-15 · Ninguna escritura durante el sondeo

| Campo | Detalle |
|---|---|
| Objetivo | Probar que un ciclo completo de lectura no modifica nada |
| Procedimiento propuesto | 1) Registrar `max(tickets.updated_at)`, `count(audit_logs)`, `count(histories)`, `count(articles)`. 2) Ejecutar 20 ciclos de sondeo. 3) Volver a medir. |
| Entorno requerido | Zammad local; cliente de lectura; **ventana exclusiva** |
| Datos necesarios | Consultas de conteo |
| Lectura o escritura | **Solo lectura** |
| Riesgo | Bajo, salvo que el sondeo se implemente con escrituras por error |
| Resultado esperado | Los cuatro valores **idénticos** |
| Evidencia | `F0-15_no_writes.json` con contadores nominales, procesos, scheduler, canal y Redis sin payloads (§9.7.1) |
| Autorización necesaria | **Sí** (depende de F0-02-P o de un script autorizado) |
| Categoría | **A** |

**Advertencia de entorno:** F0-15 exige una **ventana exclusiva**, sin F0-06, F0-07, F0-08 ni F0-09 en paralelo, y con worker, scheduler, Gmail y Redis verificados. Si no se garantiza, se marca `inconclusive`.

#### F0-16 · Sin datos personales almacenados

| Campo | Detalle |
|---|---|
| Objetivo | Probar que el motor no guarda cuerpos, direcciones ni adjuntos |
| Procedimiento propuesto | Inspeccionar el esquema y una muestra de `sla_event.payload` y `sla_article_delivery.failure_message` |
| Entorno requerido | Base de pruebas del BFF con datos de ejemplo |
| Datos necesarios | Muestra de eventos y errores |
| Lectura o escritura | **Solo lectura** sobre la base del BFF |
| Riesgo | Bajo |
| Resultado esperado | Sin cuerpo, sin dirección, sin adjunto, sin teléfono; error truncado a 500 caracteres |
| Evidencia | `F0-16_no_pii.md` |
| Autorización necesaria | **Sí** |
| Categoría | **E** |

### 3.3 Pruebas no ejecutadas en esta sesión

**Ninguna de las 13 pruebas fue ejecutada.** Este tablero solo las planifica. Las pruebas que generan escrituras (F0-02, F0-03, F0-06, F0-07, F0-08, F0-09) requieren autorización explícita, ventana y procedimiento de reversión. Las que dependen de la base del BFF (F0-12, F0-13, F0-14, F0-16) no pueden ejecutarse porque esa base no existe.

---

## 4. Riesgos

### 4.1 Riesgos observados en esta etapa

| ID | Riesgo | Prob. | Impacto | Nivel | Mitigación | Estado |
|---|---|---|---|---|---|---|
| RE1-01 | El estado cambia durante Fase 0 por operación concurrente o worker activo | Alta | Medio | **Alto** | Acordar ventana con worker y correo en estado conocido; registrar contadores antes/después | Abierto |
| RE1-02 | Credenciales OAuth y `client_secret` en texto plano en `channels.options` | Alta | Alto | **Alto** | Migrar a gestor de secretos; rotar; no reproducir valores; restringir acceso a la base | Abierto |
| RE1-03 | Clasificación vacía como `''` en lugar de `NULL` | Alta | Medio | Medio | Tratar `''` y `NULL` como no clasificado; `pending_classification` | Abierto |
| RE1-04 | Tres slugs duplicados entre categorías asignan la política equivocada | Media | Alto | **Alto** | Registrar el par categoría+subcategoría en el BFF; no inferir por slug | Abierto |
| RE1-05 | Nombres con acento en Zammad frente a nombres sin acento en la matriz | Media | Medio | Medio | Normalizar acentos y mayúsculas en la clave de política; probarlo en T3-04 | Abierto |
| RE1-06 | 35 subcategorías fuera de la matriz gobernadas por el respaldo de 36 h | Alta | Alto | **Alto** | DP-04; marcar provisionales; reporte separado | Abierto |
| RE1-07 | No existe credencial de solo lectura ni token de API | Alta | Alto | **Alto** | Autorizar y crear usuario `read` + token (DEP-04) | Abierto |
| RE1-08 | No existe base del BFF: 4 pruebas F0 no pueden ejecutarse | Alta | Medio | Medio | Aprobar y provisionar la base de pruebas (DEP-06) | Abierto |
| RE1-09 | `fqdn = localhost:3000` y `http_type = http` | Alta | Medio | Medio | Configurar dominio y HTTPS antes de producción, no en esta etapa | Abierto |
| RE1-10 | La categoría COSE difiere de la oficial en 10 filas | Media | Alto | **Alto** | Clasificar con la matriz; validar las 10 filas en T3-04 | Abierto |
| RE1-11 | Presentar como implementado lo que solo está documentado | Media | Alto | **Alto** | Estados separados; evidencia obligatoria por historia | Abierto |
| RE1-12 | DP-04 no se cierra y el respaldo se vuelve la métrica principal | Alta | Alto | **Alto** | Escalar la decisión; no iniciar etapa 2 sin dueño y proceso | Abierto |
| RE1-13 | Se ejecuta una prueba de escritura sin ventana ni reversión | Media | Alto | **Alto** | Autorización explícita y procedimiento de reversión por prueba | Abierto |

### 4.2 Riesgos heredados que siguen vigentes

| ID maestro | Riesgo | Relevancia en etapa 1 |
|---|---|---|
| R-01 | `success` interpretado como «entregado» | Debe quedar escrito en criterios y reportes antes de implementar |
| R-05 | Categoría COSE ≠ categoría oficial | Bloquea la validación de la etapa 3 |
| R-06 | 32,51 % fuera de catálogo | Justifica DP-04 |
| R-12 | DP-04 sin cerrar | Bloqueante de la compuerta |
| R-13 | Fuente de clasificación no definida | DT-01 |
| R-14 | Frontend antes de validar el motor | Compuerta etapa 3 → 4 |
| R-16 | Confusión piloto / buzón definitivo | El canal activo es el piloto |
| R-18 | Catálogo de 65 no disponible | **Mitigado**: el catálogo fue localizado y verificado |

### 4.3 Riesgo principal de la etapa

**Cerrar la etapa por documentación, no por evidencia.** La etapa 1 tiene un entregable documental extenso y eso puede confundirse con avance. El criterio de cierre es 3 `passed` + F0-01 cierre + 6/6 + condicionales + 4 diferidas, no cantidad de páginas. Este tablero mantiene esa distinción de forma explícita.

---

## 5. Dependencias

| ID | Dependencia | Tipo | Bloquea | Desbloquea | Estado |
|---|---|---|---|---|---|
| DEP-01 | Aprobación formal de 5G.4.5 (AP-01) | Decisión | Inicio de etapa 2 | Línea base contractual | `conditional_pending_final_validation` |
| DEP-02 | DP-04: dueño y proceso del catálogo | Decisión organizativa | — | Gobierno del 32,51 % | `Aprobada` (Soporte) |
| DEP-03 | Autorización de Fase 0 (AP-03) | Decisión | EP1-05 a EP1-07 | Ejecución de pruebas | `conditional_pending_final_validation` |
| DEP-04 | Usuario técnico `read` + token | Implementación | F0-02, F0-03, F0-04, F0-05, F0-15 | Pruebas de seguridad y lectura | `Pendiente` |
| DEP-05 | Buzón de prueba y ventana de escritura | Infraestructura | F0-06 a F0-09 | Pruebas de envío y cierre | `Pendiente` |
| DEP-06 | Base de pruebas del BFF | Infraestructura | F0-12, F0-13, F0-14, F0-16 | Pruebas de idempotencia y PII | `Pendiente` |
| DEP-07 | Fuente de clasificación (DT-01) | Decisión de diseño | EP2-05; etapa 4 | Captura de clasificación | `Aprobada` (BFF) |
| DEP-08 | Catálogo del selector (DT-02) | Decisión de diseño | EP4-02 | Selector completo | `Aprobada` (65 con marca) |
| DEP-10 | Gestor de secretos | Infraestructura | EP2-02; EP2-14 | Manejo seguro de credenciales | `Pendiente` |
| DEP-17 | Grupo y alcance del piloto (AP-04) | Decisión | EP1-08; etapa 5 | Prueba integral | `Pendiente` |

**Lectura:** DEP-01 y DEP-03 son **condicionales** y requieren validación final. DEP-02, DEP-07 y DEP-08 están **confirmadas**. DEP-04, DEP-05 y DEP-06 son **técnicas y acotadas**; se resuelven con autorización. DEP-17 es **organizativa**.

---

## 6. Orden de ejecución

No se asignan fechas, responsables ni estimaciones. El orden expresa **precedencia lógica**, no calendario.

### 6.1 Secuencia recomendada

| Fase | Contenido | Depende de | Paralelizable |
|---|---|---|---|
| **P0** | Cierre documental y verificación del catálogo (esta sesión) | — | Sí, con P1 |
| **P1** | Validación final: AP-01, AP-02, AP-03, AP-04 | P0 | Sí, entre sí |
| **P2** | Autorización de Fase 0, usuario `read`, token, buzón y ventana | P1 | DEP-04 y DEP-05 en paralelo |
| **P3** | Piloto: F0-02-P → F0-04 → F0-05 | P2; credencial piloto; ticket desechable | No: secuencial |
| **P4** | Aislada: F0-02-I → F0-03 | P2; credencial **pendiente de creación** en la instancia; base independiente | No: secuencial |
| **P5** | Cierre: F0-07 → F0-08 → F0-09 | P2 (ventana); tickets desechables | No: secuencial |
| **P6** | Envío: F0-06 | P2 (buzón); allowlist | No: ventana exclusiva de correo |
| **P7** | F0-15 | P6; ventana exclusiva | No: ventana exclusiva |
| **P8** | BFF: F0-12, F0-13, F0-14, F0-16 | DEP-06; harness | **No: secuencial por defecto** |

### 6.2 Camino crítico

```
AP-01 / AP-02  →  AP-03  →  DEP-04  →  F0-02 (P/I)  →  F0-03  →  6/6 + F0-01 cierre + F0-06/F0-15 condicionales  →  4 diferidas
```

**Por qué es crítico:** sin la validación final de las aprobaciones no hay línea base ni autorización; sin credencial no hay prueba de seguridad; y sin F0-03 aprobada no se puede afirmar que la integración es de solo lectura **para tickets, artículos y configuración**.

### 6.3 Qué puede avanzar en paralelo

| Grupo | Tareas | Condición |
|---|---|---|
| A | AP-01, AP-02, AP-04 | Validaciones pendientes; independientes entre sí |
| B | DEP-04 y DEP-05 | Infraestructura y buzón son independientes |
| C | F0-12, F0-13, F0-14 y F0-16 | Solo con aislamiento independiente demostrado; **por defecto secuencial** |

**No se ejecutan en paralelo:** F0-05, F0-07, F0-08, F0-09, F0-06 y F0-15. F0-15 es ventana exclusiva; F0-03 es solo instancia aislada.

### 6.4 Qué no puede adelantarse

- F0-03 no puede ejecutarse antes de F0-02-I ni fuera de la instancia aislada.
- F0-12 a F0-16 no pueden ejecutarse antes del harness/BFF.
- F0-06 no puede ejecutarse sin barrera técnica del piloto.
- F0-15 no puede ejecutarse sin ventana exclusiva y evidencia §9.7.1.
- La etapa 2 no puede iniciarse antes de cerrar la etapa 1.
- La etapa 4 no puede iniciarse antes de cerrar la etapa 3.

---

## 7. Criterios para declarar cerrada la Etapa 1

| # | Condición | Evidencia | Estado actual |
|---:|---|---|---|
| 1 | AP-01: cierre 5G.4.5 aprobado | Validación final | `conditional_pending_final_validation` |
| 2 | AP-02: alcance Email ratificado | Validación final | `conditional_pending_final_validation` |
| 3 | DP-04 confirmada: Soporte | Registro DP-04 | **`Aprobada`** |
| 4 | DT-01 confirmada: BFF como fuente | Registro de decisión | **`Aprobada`** |
| 5 | DT-02 confirmada: 65 con marca | Registro de decisión | **`Aprobada`** |
| 6 | Matriz aprobada sin cambios de valores | Acta AP-01 | `Pendiente` |
| 7 | F0: 3 `passed` + F0-01 cierre + 6/6 + condicionales + 4 diferidas | Evidencia por prueba | **3 `passed` + F0-01 apertura** |
| 8 | 10/11 con 403 + caso 7 documentado | `F0-03_negative_writes.json` | **0/11** |
| 9 | Línea base congelada y `activation_at` definido | Acta EP1-08 | `Pendiente` |
| 10 | Grupo y buzón del piloto definidos | Acta AP-04 | `Pendiente` |
| 11 | Sin cambios técnicos no autorizados | Contadores y Git | **`Validada`** (esta sesión) |
| 12 | Acta de cierre de etapa 1 | Documento | `Pendiente` |

**Regla:** la etapa se declara cerrada solo con las 12 condiciones en `Aprobada` o `Validada`. Una aprobación `conditional_pending_final_validation` **no cierra** la etapa. Una prueba bloqueante fallida impide el cierre; no se compensa con documentación.

---

## 8. Registro de evidencias y resultados

### 8.1 Estado de las 17 pruebas F0

| ID | Prueba | Evidencia | Estado | Resultado |
|---|---|---|---|---|
| F0-01 | Línea base | `F0-01_baseline_open_<UTC>.json` y `F0-01_baseline_close_<UTC>.json` | `pending` | Apertura registrada; cierre pendiente |
| F0-02 | Credencial de solo lectura | `F0-02_credential_pilot.json` y `F0-02_credential_isolated.json` | `pending` | — |
| F0-03 | 11 escrituras rechazadas | `F0-03_negative_writes.json` | `blocked` | Sin instancia aislada |
| F0-04 | Inmutabilidad de configuración | `F0-04_admin_endpoints.json` | `pending` | — |
| F0-05 | Superficie de lectura | `F0-05_api_surface.json` | `pending` | 11 campos en base; falta API |
| F0-06 | `updated_at` en la confirmación | `F0-06_touch.json` | `blocked` | Sin barrera del piloto |
| F0-07 | `close_at` primer cierre | `F0-07_close_at.json` | `pending` | — |
| F0-08 | `pending close` no cierra | `F0-08_pending_close.json` | `pending` | — |
| F0-09 | `merged` no cierra | `F0-09_merged.json` | `pending` | — |
| F0-10 | 30 filas / 2.109 | `F0-10_matrix.json` | `passed` | 30/30 exactas; 2.109 / 2.087 / 22 |
| F0-11 | Fuera de catálogo 1.016 | `F0-11_out_of_catalog.json` | `passed` | 3.125 / 2.109 / 1.016 (32,51 %) |
| F0-11b | Categoría oficial | `F0-11b_category_mapping.md` | `passed` | 10 diferencias documentadas |
| F0-12 | Duplicados | `F0-12_duplicates.md` | `deferred` | Sin harness/BFF |
| F0-13 | Fuera de orden | `F0-13_out_of_order.md` | `deferred` | Sin harness/BFF |
| F0-14 | Recuperación | `F0-14_recovery.md` | `deferred` | Sin harness/BFF |
| F0-15 | Sin escrituras en el sondeo | `F0-15_no_writes.json` | `blocked` | Sin ventana/evidencia |
| F0-16 | Sin datos personales | `F0-16_no_pii.md` | `deferred` | Sin harness/BFF |

### 8.2 Hallazgos de auditoría de esta sesión

No son pruebas F0: son verificaciones de solo lectura que **preparan** las pruebas. No generaron archivos de evidencia nuevos.

| # | Hallazgo | Resultado |
|---:|---|---|
| 1 | Catálogo oficial localizado | `CategoryData.ts`, 13 categorías / 65 subcategorías |
| 2 | Árbol de Zammad | 13 categorías / 65 subcategorías |
| 3 | Árbol ↔ `CategoryData.ts` | Idénticos, 0 diferencias |
| 4 | Matriz ↔ catálogo | 30/30 filas coinciden en categoría + subcategoría |
| 5 | Subcategorías sin fila en la matriz | 35 |
| 6 | Slugs duplicados | 3: `cambio_de_razón_social`, `caída_del_servidor`, `redes_y_conexiones` |
| 7 | Clasificación vacía | Ticket 7 con `''` (longitud 0), no `NULL` |
| 8 | `dominio` | Texto libre, máx. 255; no es catálogo |
| 9 | Artículo 3 del ticket 7 | `delivery_status = success`; `created_at` 04:57:54 UTC; `delivery_status_date` 14:32:10 UTC (9 h 34 min) |
| 10 | `first_response_at` del ticket 7 | 04:57:54 UTC (coincide con la creación del artículo, no con el envío) |
| 11 | Tablas del motor SLA | 0 (`sla_*` no existe) |
| 12 | SLA nativos | 0 filas en `slas` |
| 13 | Usuario `read` y token de API | No existen |
| 14 | Accesos de grupo | Todos `full` |
| 15 | `histories` | 46 (baseline 44; +2 notificaciones) |
| 16 | Worker | Corriendo desde ~20:50 UTC (baseline: detenido) |

### 8.3 Evidencia aún no producida

Ninguna de las 13 pruebas pendientes tiene archivo de evidencia. Los nombres de la tabla §8.1 son los previstos; **no deben crearse vacíos** para simular avance. Cada archivo se produce al ejecutar su prueba.

### 8.4 Nota sobre los resultados ya existentes

Las pruebas F0-01, F0-10, F0-11 y F0-11b se ejecutaron en etapas anteriores y sus resultados están documentados en `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` y en `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md`. Este tablero **no las repite ni las reemplaza**.

---

## 9. Próxima tarea autorizable

### 9.1 Qué está autorizado ahora

Solo lectura documental y de estado. **No hay ninguna tarea técnica autorizada** en este momento: ni crear el usuario, ni el token, ni la base del BFF, ni ejecutar pruebas de escritura.

### 9.2 Próximo paso autorizable

El siguiente paso es **de validación final, no de ejecución**:

1. Obtener la validación final de **AP-01** y **AP-02**.
2. Obtener la validación final de **AP-03**.
3. Definir el grupo y el buzón del piloto (**AP-04**).
4. Acordar el gestor de secretos, el cifrado de backups y la ventana de pruebas.

Las decisiones DP-04, DT-01 y DT-02 ya están confirmadas y no se vuelven a solicitar.

### 9.3 Si se autoriza Fase 0, el orden es

```
F0-02 → F0-04 → F0-03 → F0-05 + F0-15 → F0-07 + F0-08 + F0-09 → F0-06 → (base BFF) F0-12 + F0-13 + F0-14 + F0-16
```

Cada prueba requiere su propia autorización, ventana y procedimiento de reversión. F0-03 no se ejecuta sin F0-02 aprobada.

### 9.4 Qué se necesita decidir en esta conversación

| Pregunta | Estado |
|---|---|
| ¿Se valida definitivamente AP-01 (5G.4.5)? | `conditional_pending_final_validation` |
| ¿Se valida definitivamente AP-02 (Email-only)? | `conditional_pending_final_validation` |
| ¿Se valida definitivamente AP-03 (Fase 0)? | `conditional_pending_final_validation` |
| ¿Se define AP-04 (grupo y buzón)? | `Pendiente` |
| ¿Se aprueba el gestor de secretos y el cifrado de backups? | `Pendiente` |
| ¿Se acuerda la ventana y la ausencia de sesiones concurrentes? | `Pendiente` |

### 9.5 Prohibiciones vigentes

No se autoriza: implementar el motor, crear tablas, ejecutar migraciones, modificar PostgreSQL o Redis, modificar Zammad, crear SLA nativos, tocar triggers o webhooks, crear usuarios o permisos, configurar buzones, enviar correos, iniciar workers, instalar dependencias, modificar CSS, tocar Zendesk o COSE, ni modificar los 60 documentos existentes.

---

## 10. Trazabilidad con el documento maestro

| Historia | Contenido | Estado en esta etapa | Sección de este tablero |
|---|---|---|---|
| EP1-01 | Consolidar requisitos y precedencia | **`Validada`** (entregable existe; aprobación formal en EP1-02) | §0, §1 |
| EP1-02 | Aprobar matriz y reglas | `Pendiente` (AP-01, AP-02) | §2.5, §7 |
| EP1-03 | DP-04: dueño y proceso (Soporte) | **`Completada`** | §2.2 |
| EP1-04 | Aprobar criterios y compuertas | `Pendiente` | §7 |
| EP1-05 | Autorizar Fase 0 y credencial | `Pendiente` | §2.1, §9.2 |
| EP1-06 | F0 de lectura, seguridad y matriz | **`En revisión`** (4 de 8 pruebas del alcance) | §3, §8 |
| EP1-07 | F0 de envío, cierre, resiliencia y PII | `Pendiente` | §3, §8 |
| EP1-08 | Congelar línea base y piloto | `Pendiente` | §1.3, §7 |

### 10.1 Estado de las actividades de esta sesión

| Actividad | Contenido | Estado |
|---|---|---|
| 1 | Verificar estado real | **`Validada`** (solo lectura; snapshot 21:00 UTC) |
| 2 | Decisiones pendientes | **`Aprobada`** (DT-01, DT-02 y DP-04 confirmadas) |
| 3 | Plan de las 13 pruebas | **`Validada`** (plan completo; ninguna ejecutada) |
| 4 | Preparación del catálogo | **`Aprobada`** (catálogo verificado; administración asignada a Soporte) |
| 5 | Dependencias y orden | **`Validada`** |
| 6 | Documento de seguimiento | **`Validada`** (este documento) |

---

## 11. Control de versiones de este tablero

| Versión | Fecha | Cambio | Estado |
|---|---|---|---|
| 1.0 | 16/11/2026 | Creación del tablero de ejecución de la etapa 1 | Vigente |
| 1.1 | 16/11/2026 | Consolidación de DT-01, DT-02, DP-04 y exclusión de las 7 no servicio; AP-01/02/03 condicionales | Vigente |

**Regla:** este tablero se actualiza al ejecutar cada prueba o al cerrar cada decisión. No se reescriben resultados anteriores: se agrega la fila nueva y se conserva la evidencia.

---

## 12. Confirmación

Este documento se actualizó leyendo el documento maestro, el análisis de bloqueantes y el estado real del sistema en modo solo lectura.

- No se modificó código.
- No se crearon tablas ni se ejecutaron migraciones.
- No se modificó PostgreSQL ni Redis.
- No se modificó la configuración de Zammad.
- No se crearon SLA nativos.
- No se modificaron triggers ni webhooks.
- No se crearon usuarios ni permisos.
- No se configuraron buzones.
- No se enviaron correos.
- No se inició ni detuvo ningún worker o servicio.
- No se instalaron dependencias.
- No se modificó CSS.
- No se modificó Zendesk ni COSE.
- No se modificó ningún documento fuente de 5G; solo se actualizaron los documentos de seguimiento de EPIC-SLA-01.

Las escrituras de esta sesión son exclusivamente documentales: este tablero, el documento maestro y el análisis de bloqueantes.

**Fin del tablero de ejecución de la etapa 1.**

