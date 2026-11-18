# ANÁLISIS DE BLOQUEANTES — ETAPA 1.1 — EPIC-SLA-01

**Proyecto:** MAILING — C.O.S.E. sobre Zammad 7.2.3
**Épica:** EPIC-SLA-01
**Etapa:** 1.1 — Resolución de bloqueantes técnicos y funcionales
**Documentos base:** `EPIC_IMPLEMENTACION_SLA_COSE.md`, `TABLERO_EJECUCION_ETAPA_1_SLA.md`, `MATRIZ_OFICIAL_SLA_EMAIL_5G4_4.md`, `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md`
**Fecha:** 16/11/2026
**Modo:** PLAN — **solo lectura** para sistemas; actualización documental en esta versión.
**Naturaleza:** análisis técnico y propuesta. **No implementa, no ejecuta pruebas y no modifica ningún sistema.**
**Snapshot:** 2026-11-16 21:13 UTC (16:13 hora local de Perú).
**Estado:** análisis cerrado; **decisiones funcionales confirmadas**; **AP-01, AP-02 y AP-03 condicionales**.

> **Regla de lectura.** Este documento resuelve técnicamente DT-01, DT-02 y DEP-04, y prepara las condiciones de Fase 0. No crea reglas nuevas ni cambia valores de la matriz. Las decisiones DT-01, DT-02 y DP-04 fueron confirmadas el 16/11/2026. AP-01, AP-02 y AP-03 permanecen en `conditional_pending_final_validation`.

---

## 0. Resumen ejecutivo

| Bloqueante | Hallazgo principal | Recomendación | ¿Requiere aprobación? |
|---|---|---|---|
| **DT-01** | `categoria_subcategoria` guarda **solo el slug de la hoja**, no la categoría padre. Hay **3 slugs duplicados** entre categorías y el mapa slug→etiqueta es global. | **B: el BFF es la fuente de la clasificación**; Zammad queda como registro secundario. | **Confirmada** (16/11/2026) |
| **DT-02** | Catálogo de **65 subcategorías**; matriz de **30 filas**; **27 con SLA**, **3 sin evidencia**, **35 fuera** de la matriz. De las 35, **28** son de servicio y **7** no son de servicio. | **C: selector de 65 con marca de política** y tratamiento explícito para las 7. | **Confirmada** (16/11/2026) |
| **DEP-04** | Credenciales OAuth y tokens de API en **texto plano** en base de datos; no hay cifrado en reposo. | Usuario `ticket.agent` + `groups_users.access='read'`, token acotado, cliente solo `GET`, gestor de secretos. | **Sí** (autorizar creación) |
| **Entorno** | Worker activo, canal Gmail activo, scheduler de correo cada 30 s; el sistema **no está congelado**. | Ventana acordada con worker en estado conocido; F0-15 exige ventana exclusiva; F0-06 exige barrera técnica del piloto. | **Sí** (ventana) |
| **AP-01 / AP-02** | Sin aprobación formal del cierre 5G.4.5 ni del alcance Email. | Ratificación por acta. | **`conditional_pending_final_validation`** |
| **DP-04** | Sin dueño ni proceso del catálogo. | Designar rol y proceso. | **Confirmada**: Soporte |

**Conclusión:** los tres bloqueantes técnicos tienen solución **sin modificar Zammad** y las decisiones DT-01, DT-02 y DP-04 están confirmadas. Queda pendiente la validación final de AP-01/AP-02/AP-03, el diseño de secretos, la ventana y la credencial.

---

## 1. Método y alcance

| Aspecto | Detalle |
|---|---|
| Consultas a base de datos | `psql` con `SELECT` exclusivamente |
| Consultas al sistema | `ps`, `ss`, `redis-cli`, lectura de archivos |
| Código inspeccionado | Modelos, políticas, validadores, controladores, índice de búsqueda, esquema |
| Servicios | **No se inició ni se detuvo ninguno** |
| Escrituras | **Cero** |
| Pruebas | **Ninguna ejecutada** |
| Secretos | No se reproducen valores; solo se describe dónde están y cómo se protegen |
| Documentos previos | Leídos, no modificados |

---

## 2. DT-01 — Clasificación manual: comportamiento real y alternativa

### 2.1 Pregunta

¿Puede el motor tomar la clasificación manual directamente de `categoria_subcategoria`, o necesita una fuente propia en el BFF para no asignar nunca una política incorrecta?

### 2.2 Comportamiento comprobado

| Aspecto | Hallazgo | Evidencia |
|---|---|---|
| Tipo de dato | `tree_select` de una sola selección (`multiple: false`) | `object_manager_attributes` id 61; `data_option` |
| Almacenamiento | Columna `varchar(255)`, nullable, sin valor por defecto, **sin índice** | `information_schema.columns`; `pg_indexes` |
| Valor guardado | El `value` del nodo seleccionado (slug), no la etiqueta | Árbol del atributo; `historical_options` |
| Categoría padre | **No se almacena**. Solo se guarda el nodo elegido | `data_options_hash` (incluye padres y hojas) |
| Nodo padre seleccionable | **Sí**: los padres tienen `value` propio y son opciones válidas | `data_options_hash`; `historical_options` incluye `FACTURACIÓN ELECTRÓNICA: FACTURACIÓN ELECTRÓNICA` |
| Clasificación incompleta | Posible: se puede guardar solo la categoría, sin subcategoría | Consecuencia del punto anterior |
| Vacíos | Existen **ambos casos**: `NULL` (ticket 1) y cadena vacía `''` (ticket 7) | Consulta a `tickets` |
| Slugs duplicados | **3**: `cambio_de_razón_social`, `caída_del_servidor`, `redes_y_conexiones` | 65 entradas, **62 slugs únicos** |
| Mapa slug→etiqueta | **Global**, no por categoría. Un slug duplicado no identifica al padre | `historical_options` |
| Validación de opciones | Solo se valida pertenencia al catálogo durante ejecución de IA; en escritura normal **no** | `lib/validations/.../option.rb:8`; `attribute_validator.rb:28` |
| Consecuencia de lo anterior | La API puede guardar un valor **fuera del catálogo** (texto arbitrario ≤255) | `option.rb` retorna salvo `ai_agent_execution` |
| Escritura por API | `PUT /api/v1/tickets/{id}` acepta el campo si es columna del modelo | `tickets_controller.rb:242-290`; `can_cleanup_param.rb:59-61` |
| Lectura por API | `GET /api/v1/tickets/{id}` devuelve el campo en el nivel superior | `tickets_controller.rb:45-68`; `can_associations.rb:130` |
| Búsqueda | El índice incluye todas las columnas; el slug se indexa como texto | `lib/search_index_backend.rb:951` |
| Filtros y orden | `tree_select` soporta orden y filtro por igualdad; `multi_tree_select` usa «contains one» | `can_selector/advanced_sorting/tree_select_field_sort.rb:6`; `treeselect.ts` |
| Reportes nativos | No agregan atributos personalizados; además los reportes están deshabilitados | `Report.enabled? = false` (documentado) |
| Reportes del BFF | Usan su propia base; no dependen del campo de Zammad | Arquitectura 5G.4.4 |

### 2.3 El problema de los tres slugs duplicados

| Slug | Categorías donde aparece | ¿Está en la matriz? | Consecuencia |
|---|---|---|---|
| `cambio_de_razón_social` | FACTURACIÓN ELECTRÓNICA y ADMINISTRATIVO | Sí, bajo **FACTURACIÓN ELECTRÓNICA** (3 d) | Si el asesor elige ADMINISTRATIVO, el campo guarda el mismo slug y el motor podría aplicar **3 d** en lugar del respaldo 36 h |
| `caída_del_servidor` | OPERATIVO y SERVIDOR | No | Ambas van a respaldo; el SLA no cambia, pero la categoría del reporte queda ambigua |
| `redes_y_conexiones` | OPERATIVO y SERVIDOR | No | Igual que el anterior |

**Lectura:** el primer caso es el peligroso: **mismo slug, distinta política**. El motor no puede resolverlo sin un dato adicional. Inferir por orden de aparición sería exactamente lo que la épica prohíbe.

### 2.4 ¿Se puede guardar una clave compuesta inequívoca?

| Opción | Cómo | ¿Modifica Zammad? | Veredicto |
|---|---|---|---|
| 1. Cambiar los `value` de las hojas a slugs compuestos (`fe__cambio_de_razon_social`) | Editar la definición del atributo y migrar valores | **Sí** | Técnicamente viable; prohibido en esta etapa |
| 2. Agregar un segundo atributo para la categoría | Nuevo atributo | **Sí** | Viable; prohibido ahora |
| 3. Cambiar a `multi_tree_select` y guardar `[categoría, subcategoría]` | Cambio de tipo de atributo | **Sí** | Viable pero cambia la UI y el dato; no recomendado |
| 4. Guardar el par en el BFF | El frontend envía `(categoría, subcategoría)` y el BFF lo persiste | **No** | **Recomendado** |
| 5. Escribir por API un valor compuesto en el campo actual | `PUT` con `"FE|cambio_de_razon_social"` | **No** (pero es un valor fuera de catálogo) | La API lo acepta, pero la UI no lo muestra, los filtros no lo reconocen y `historical_options` no lo traduce. **No recomendado** |

**Conclusión:** con el atributo actual **no existe** una clave compuesta inequívoca que sea válida, visible y filtrable. La única vía sin modificar Zammad es el BFF.

### 2.5 Comparación de alternativas

| Criterio | A. Zammad como fuente | B. BFF como fuente | C. Híbrida |
|---|---|---|---|
| Identifica categoría + subcategoría sin ambigüedad | **No** (3 slugs duplicados) | **Sí** (par explícito) | **Sí**, si el BFF corrige |
| Requiere modificar Zammad | No | No | No |
| Auditabilidad | Media: el historial guarda el slug | Alta: par, actor, fecha y motivo | Alta |
| Compatibilidad con la UI y filtros de Zammad | Alta | Media: el campo de Zammad queda como espejo opcional | Alta |
| Riesgo de asignar política incorrecta | **Alto** | **Bajo** | Medio |
| Complejidad de implementación | Baja | Media | Alta |
| Dependencia de que el asesor clasifique en Zammad | Alta | Media: clasifica en C.O.S.E. | Alta |

### 2.6 Decisión confirmada

**Alternativa B confirmada: el BFF es la fuente de verdad de la clasificación.**

Diseño propuesto:

1. El asesor clasifica en la ficha de ticket de C.O.S.E. (etapa 4).
2. El frontend envía **siempre el par** `(categoría oficial, subcategoría oficial)`.
3. El BFF valida el par contra su catálogo versionado antes de guardarlo.
4. El BFF registra `classified_at`, actor y motivo.
5. El campo `categoria_subcategoria` de Zammad queda como **registro secundario opcional**; si se usa, el motor lo compara con el par del BFF y registra divergencia cuando no coincide.
6. El motor **nunca** infiere la categoría desde el slug.

**Por qué B y no A:** A no puede garantizar el requisito «nunca asignar una política incorrecta» sin modificar Zammad. B lo garantiza por construcción: el par es explícito y validado.

**Por qué B y no C:** C resuelve el mismo problema con más piezas. Solo se justificaría si el negocio exige que la clasificación se haga dentro de Zammad; en ese caso, el BFF seguiría necesitando el par para los 3 slugs duplicados.

### 2.7 Qué haría falta para que A fuera aceptable

Si el negocio decide que Zammad sea la fuente, se necesitan **todas** estas condiciones:

1. Rechazar los 3 slugs duplicados y exigir confirmación manual de la categoría.
2. Tratar `NULL`, `''` y valores de categoría sin subcategoría como `pending_classification`.
3. Validar el valor contra el catálogo en el BFF (no confiar en la validación de Zammad).
4. Definir una regla explícita y auditada para el slug `cambio_de_razón_social`.
5. Aceptar que la regla del punto 4 es una **inferencia** y que, por tanto, contradice el principio de clasificación manual inequívoca.

**Conclusión:** A es aceptable solo si se modifica el catálogo de Zammad o si se acepta una inferencia. Ninguna de las dos cosas está autorizada.

### 2.8 Decisiones confirmadas para DT-01

| # | Decisión | Opciones | Decisión confirmada |
|---:|---|---|---|
| 1 | Fuente de la clasificación | A / B / C | **B** |
| 2 | Rol del campo de Zammad | Fuente / espejo opcional / ignorado | **Espejo opcional con verificación de divergencia** |
| 3 | Tratamiento de los 3 slugs duplicados | Rechazar / regla explícita | **Rechazar en el BFF** |
| 4 | Clasificación incompleta | `pending_classification` | **Sí** |

**Confirmadas el 16/11/2026.** No se vuelven a solicitar.

---

## 3. DT-02 — Catálogo, conteos y tratamiento inequívoco

### 3.1 Aclaración de conteos

| Concepto | Cantidad | Explicación |
|---|---:|---|
| Subcategorías del catálogo | **65** | Entradas hoja del árbol y de `CategoryData.ts` |
| Slugs únicos | **62** | 65 entradas − 3 slugs repetidos |
| Pares categoría-subcategoría | **65** | Cada entrada es un par único |
| Filas de la matriz | **30** | Pares con evidencia estadística |
| Con SLA | **27** | n ≥ 10 y P75 calculado |
| Sin evidencia | **3** | n < 10 |
| Fuera de la matriz | **35** | 65 − 30 |
| Fuera de la matriz, de servicio | **28** | Candidatas a respaldo 36 h |
| Fuera de la matriz, no servicio | **7** | Requieren decisión (QyD / exclusión) |

**Verificación:** `30 + 35 = 65` ✓ · `27 + 3 = 30` ✓ · `28 + 7 = 35` ✓

**Por qué 65 no es 30:** el catálogo es la lista de lo que el asesor puede elegir; la matriz es la lista de lo que tiene evidencia. El catálogo es más grande que la matriz por diseño.

### 3.2 Las 27 combinaciones con SLA

| # | Categoría oficial | Subcategoría | N | Meta |
|---:|---|---|---:|---|
| 1 | ADMINISTRATIVO | Nueva licencia o sucursal | 35 | **24 h** |
| 2 | ADMINISTRATIVO | Solicitud de migración | 27 | **3 d** |
| 3 | CAPACITACION | Solicitud agenda capacitación | 115 | **3 d** |
| 4 | CAPACITACION | Capacitación adm Reportes | 21 | **36 h** |
| 5 | DEVOLUCION | Solicitud de devolución | 37 | **3 d** |
| 6 | FACTURACION ELECTRONICA | Ajustes FE | 341 | **24 h** |
| 7 | FACTURACION ELECTRONICA | Cambio de razón social | 170 | **3 d** |
| 8 | FACTURACION ELECTRONICA | Activacion FE | 94 | **2 d** |
| 9 | FACTURACION ELECTRONICA | Validación de comprobantes FE | 67 | **36 h** |
| 10 | FACTURACION ELECTRONICA | Requisitos FE | 60 | **5 d** |
| 11 | FACTURACION ELECTRONICA | Error FE del facturador | 38 | **24 h** |
| 12 | FACTURACION ELECTRONICA | Error FE de cálculo | 36 | **3 d** |
| 13 | FACTURACION ELECTRONICA | Emisión de invoice | 28 | **36 h** |
| 14 | FACTURACION ELECTRONICA | Error FE envio manual | 19 | **2 d** |
| 16 | GESTION | Renovación certificado normal | 177 | **24 h** |
| 17 | GESTION | Venta de CDT certificado | 81 | **36 h** |
| 18 | GESTION | Envio de pago | 45 | **24 h** |
| 19 | GESTION | Seguimiento proactivo | 33 | **24 h** |
| 20 | INTEGRACIONES | Consulta consumo de apis | 83 | **2 d** |
| 21 | INTEGRACIONES | Solicitud de integracion rappi | 25 | **36 h** |
| 22 | INTEGRACIONES | Solicitud de integracion Pedidos ya | 14 | **4 d** |
| 25 | LOGISTICA | Tarea o capacitación logistica | 319 | **2 d** |
| 26 | LOGISTICA | Error logistica | 20 | **4 d** |
| 27 | OPERATIVO | Temas operativos | 119 | **2 d** |
| 28 | SOFTWARE | Error punto de venta | 37 | **36 h** |
| 29 | SOFTWARE | Seguimiento de errores | 34 | **24 h** |
| 30 | SOFTWARE | Error web | 12 | **3 d** |

**Distribución:** 24 h: 7 · 36 h: 6 · 2 d: 5 · 3 d: 6 · 4 d: 2 · 5 d: 1.

### 3.3 Las 3 combinaciones sin evidencia

| # | Categoría oficial | Subcategoría | n | Tratamiento |
|---:|---|---|---:|---|
| 15 | FACTURACION ELECTRONICA | Error FE por duplicidad | 9 | **Sin SLA** — `no_policy` / `insufficient_evidence` |
| 23 | INTEGRACIONES | Solicitud de integracion sistemas contables | 9 | **Sin SLA** — `no_policy` / `insufficient_evidence` |
| 24 | INTEGRACIONES | Error integracion | 4 | **Sin SLA** — `no_policy` / `insufficient_evidence` |

**Regla:** no reciben plazo y **no** reciben el respaldo de 36 h. Quedan fuera del denominador y se revisan con datos nuevos.

### 3.4 Las 35 combinaciones fuera de la matriz

#### 3.4.1 De servicio — respaldo provisional de 36 h (28)

| Categoría | Subcategoría |
|---|---|
| FACTURACIÓN ELECTRÓNICA | Activacion NV |
| FACTURACIÓN ELECTRÓNICA | Cambio impuesto FE |
| FACTURACIÓN ELECTRÓNICA | Consecutivos topes folios |
| FACTURACIÓN ELECTRÓNICA | FE solicitud xml pdf |
| LOGÍSTICA | Capacitación logistica avanzado |
| LOGÍSTICA | Capacitación logistica insumos recetas |
| LOGÍSTICA | Temas operativos punto de venta |
| INTEGRACIONES | Solicitud de integracion uber |
| INTEGRACIONES | Integraciones y apis |
| SOFTWARE | Error backend |
| SOFTWARE | Mejora personalizada |
| SOFTWARE | Error add on asistencias |
| GESTIÓN | Seguimiento de cdt |
| GESTIÓN | Pagos prorrogas descuentos |
| ADMINISTRATIVO | Baja sucursal |
| ADMINISTRATIVO | Cambio de razón social |
| ADMINISTRATIVO | Temas administrativos |
| ADMINISTRATIVO | Activación de Addons |
| OPERATIVO | Cajas |
| OPERATIVO | Redes y conexiones |
| OPERATIVO | Caída del servidor |
| CAPACITACIÓN | Capacitación logistica |
| CAPACITACIÓN | Capacitación integraciones |
| CAPACITACIÓN | Capacitación adm Productos |
| CAPACITACIÓN | Capacitación operativa |
| CAPACITACIÓN | Capacitación delivery pro |
| SERVIDOR | Caída del servidor |
| SERVIDOR | Redes y conexiones |

**Tratamiento:** `99-FALLBACK`, 2.160 min, `provisional = true`. Se reportan separados.

#### 3.4.2 No servicio — decisión requerida (7)

| Categoría | Subcategoría | Por qué no es servicio |
|---|---|---|
| SIN HOMOLOGAR | Sin dato | No es una atención real |
| SIN HOMOLOGAR | Duplicado o spam | No es una atención real |
| SIN HOMOLOGAR | No contestó | No es una atención real |
| RECLAMO | Reclamo | Proceso de Quejas y Devoluciones |
| QUEJA | Servicio | Proceso de Quejas y Devoluciones |
| QUEJA | Producto | Proceso de Quejas y Devoluciones |
| QUEJA | Otro | Proceso de Quejas y Devoluciones |

**Tratamiento:** **no se asume**. Opciones: (a) excluir del SLA y del denominador; (b) derivar al proceso de QyD; (c) aplicar respaldo 36 h. La decisión corresponde al negocio y al dueño del catálogo. Aplicarles el respaldo sin decisión inflaría la métrica con tickets que no son atenciones.

### 3.5 Tratamiento inequívoco: árbol de decisión

El motor aplica este orden, sin excepciones:

```
1. ¿El ticket es de un canal distinto de Email?
      → non_email (excluido, con divergencia)

2. ¿El ticket fue creado antes de activation_at?
      → historical (excluido de todo denominador)

3. ¿Carece de categoría, de subcategoría o tiene un valor inválido?
      → pending_classification (sin plazo, sin fallback)
        · valor inválido = no está en el catálogo oficial
        · incluye NULL, '' y categoría sin subcategoría

4. ¿El par (categoría, subcategoría) está en las 27 con SLA?
      → SLA específico de la matriz (compromiso congelado)

5. ¿El par está en las 3 sin evidencia?
      → no_policy / insufficient_evidence (sin plazo, sin fallback)

6. ¿El par está en las 28 de servicio fuera de matriz?
      → 99-FALLBACK, 2.160 min, provisional = true

7. ¿El par está en las 7 no servicio?
      → decisión requerida (excluir / QyD / fallback)
        · hasta que se decida, el motor NO asigna plazo

8. ¿El ticket está merged o eliminado?
      → excluded con exclusion_reason y divergencia
```

**Regla de oro:** el motor **nunca** aplica el fallback por defecto ante un valor desconocido. Un valor desconocido es `pending_classification` o `invalid_classification`, no una licencia para inventar un plazo.

### 3.6 Diferencias históricas entre COSE y el catálogo oficial

Se mantienen las **10 filas** documentadas en el maestro (§6.7): 1, 2, 3, 5, 13, 16, 17, 24, 26 y 29. La matriz y `CategoryData.ts` coinciden entre sí; la divergencia es con la homologación histórica de COSE.

**Regla:** la clave de política se genera desde la categoría **oficial**. La homologación COSE sirve para leer el histórico, no para clasificar.

### 3.7 Decisiones confirmadas para DT-02

| # | Decisión | Opciones | Decisión confirmada |
|---:|---|---|---|
| 1 | Catálogo del selector | 65 / 30 / 65 con marca | **65 con marca de política** |
| 2 | Las 7 no servicio | Excluir / QyD / fallback | **Excluir del motor SLA; sin fallback** |
| 3 | Las 3 sin evidencia | Sin SLA | **Confirmado: sin SLA y sin fallback** |
| 4 | Visibilidad del respaldo | Mostrar «provisional» | **Sí, siempre** |

**Confirmadas el 16/11/2026.** No se vuelven a solicitar.

---

## 4. DEP-04 — Seguridad de la credencial de integración

### 4.1 Almacenamiento actual de credenciales

| Elemento | Dónde se guarda | Protección actual | Riesgo |
|---|---|---|---|
| Credenciales OAuth del canal Gmail | `channels.options` (texto YAML) | Ninguna cifrado en reposo; solo permiso de administrador por API | **Alto** |
| Tokens de API | `tokens.token` (varchar 100, índice único) | **Texto plano**, sin hash | **Alto** |
| Contraseña de base de datos | `config/database.yml` | Archivo `0600`; excluido de Git y del tar de archivos del backup | Medio |
| Secretos de Rails | No hay `secrets.local.yml` en la instalación | — | — |
| Cifrado en reposo | No existe módulo de cifrado para `channels` ni `tokens` | — | **Alto** |

**Evidencia:**
- `db/schema.rb`: `channels.options` es `text`; `tokens.token` es `string(100)` sin transformación.
- `app/models/token.rb:206-212`: `self.token = SecureRandom.urlsafe_base64(48)` y se guarda tal cual.
- `config/database.yml`: permisos `-rw-------`, no rastreado por Git (`.gitignore` líneas 14 y 156).
- No se encontró ningún módulo `Encryption` aplicado a estos modelos.

**Nota:** no se reproducen valores. La verificación se hizo sobre el esquema y la estructura, no sobre el contenido.

### 4.2 Protecciones que Zammad ya ofrece

| Control | Comportamiento | Evidencia |
|---|---|---|
| Acceso a canales por API | Solo administradores con `admin.channel_<proveedor>` | `channel_policy.rb` |
| Filtro de parámetros en logs | Redacta `passw`, `secret`, `token`, `_key`, `crypt`, `salt`, `certificate`, `otp`, cuerpos y adjuntos | `config/initializers/filter_parameter_logging.rb:8-20` |
| Sanitización de `HttpLog` | Enmascara `Authorization`, Bearer, Basic, cookies, tokens y `secret` en cuerpos y query strings | `app/models/http_log.rb:55-62,125-148` |
| Permisos de token | El token solo puede **reducir** los permisos del usuario, nunca ampliarlos | `app/models/token/permissions.rb:13-17` |
| Backups | El dump se crea con `chmod 600`; el tar de archivos excluye `config/database.yml` | `contrib/backup/functions:164,212,244-246` |
| Contraseña de BD | Archivo `0600`, fuera de Git | `config/database.yml`; `.gitignore` |

**Lo que no está protegido:** el contenido de `channels.options` y `tokens.token` dentro de la base y dentro del dump. Un acceso de lectura a la base o a un backup expone credenciales vivas.

### 4.3 Riesgos de exposición

| Vector | Qué expone | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| Lectura de la base (credencial, SQL injection, réplica) | Tokens OAuth y tokens de API | Media | Alto | Cifrado en reposo o gestor de secretos; rotación |
| Fuga de un backup | Todo lo anterior | Media | Alto | Cifrar backups; restringir acceso; rotar ante sospecha |
| Logs de aplicación | Potencial, mitigado por filtros | Baja | Medio | Mantener filtros; no loguear headers; revisar `HttpLog` |
| Token de API filtrado | Acceso como el usuario técnico | Media | Alto | Expiración 90 días; rotación; monitoreo de `last_used_at` |
| Administrador con acceso a canales | Credenciales OAuth completas | Media | Alto | Mínimo privilegio; auditoría de accesos |
| Refresh token de larga vida | Acceso persistente a Gmail | Media | Alto | Rotación y revocación; alcance mínimo |

### 4.4 Diseño de seguridad propuesto

#### 4.4.1 Credencial de lectura

| Elemento | Definición |
|---|---|
| Usuario | Técnico, dedicado, activo, sin rol `Admin` |
| Permiso global | `ticket.agent` (necesario para leer tickets de un grupo) |
| Acceso al grupo | `groups_users.access = 'read'` en `Soporte Especializado` |
| Otros grupos | Sin acceso |
| Contraseña | Aleatoria, en gestor de secretos, sin login interactivo |
| Token | `action = 'api'`, `persistent = true`, `preferences.permission = ['ticket.agent']` |
| Expiración | 90 días, con solapamiento de 24 h para rotar |
| Almacenamiento | Gestor de secretos o archivo de entorno `0600`; nunca en repositorio, documento o log |

#### 4.4.2 Cliente HTTP del BFF

| Control | Regla |
|---|---|
| Método | Allowlist: **solo `GET`** |
| URL base | Fija, sin entrada externa; sin redirecciones a otros hosts |
| Timeouts | Conexión y lectura acotados |
| Reintentos | Backoff exponencial; solo en errores de red o 5xx |
| Logs | Sin headers de autorización; sin cuerpos |
| Errores | Mensaje truncado; sin volcar la respuesta completa |
| Superficie | Solo los endpoints necesarios: tickets, artículos, historial |

#### 4.4.3 Secretos y respaldos

1. Los secretos viven fuera del repositorio y fuera de los documentos.
2. El BFF no recibe credenciales de la base de Zammad: solo el token de API.
3. Los backups de Zammad se cifran y se restringen; si uno se expone, se rotan OAuth y tokens.
4. La rotación de tokens es trimestral; la de OAuth, según la política de Google.
5. Se monitorea `last_used_at` y se alerta ante uso anómalo.

#### 4.4.4 Superficie real de permisos con `access = 'read'`

| Operación | Política | Resultado esperado |
|---|---|---|
| `GET /tickets` | `TicketPolicy#show?` → `access?('read')` | **200** |
| `GET /tickets/{id}` | Igual | **200** |
| `GET /ticket_articles/by_ticket/{id}` | `ArticlePolicy#show?` → `ticket_policy.show?` | **200** |
| `PUT/PATCH /tickets/{id}` | `update?` → `change_access?` → `agent_update_access?` (`change`) | **403** |
| `POST /tickets` | `create?` → `access?('create')` | **403** |
| `DELETE /tickets/{id}` | `destroy?` → admin | **403** |
| `POST /ticket_articles` | `create?` → `follow_up?` → `update?` | **403** |
| `PUT /ticket_articles/{id}` | `update?` → `agent_update_access?` (`change`) | **403** |
| `DELETE /ticket_articles/{id}` | Solo notas propias; el usuario técnico no crea notas | **403** |
| `GET/PUT /settings` | `SettingPolicy` → permiso requerido (admin) | **403** |
| `GET/POST /calendars` | Endpoint administrativo | **403** (esperado; verificar en F0-04) |
| `GET/POST /slas` | `SlaPolicy` → `admin.sla` | **403** |
| `POST /triggers`, `POST /webhooks` | Endpoint administrativo | **403** (esperado; verificar en F0-03) |
| `POST /users` | `UserPolicy` sin `create?` propio; esperado `admin.user` | **403** (esperado; verificar en F0-03) |
| `DELETE /users/{id}` | `destroy?` → `admin.user` | **403** |
| `PUT /users/{id}` | `update?`: admin, o **agente sobre un cliente** | **200 si el objetivo es un cliente**; **403 si es agente o admin** |

**Hallazgo crítico:** `UserPolicy#update?` (`app/policies/user_policy.rb:29-39`) permite a un agente modificar **usuarios cliente**. Por tanto, la prueba negativa F0-03 caso 7 **no puede esperar 403 contra un cliente**: debe apuntar a un usuario agente/admin, o reformularse. Esto no afecta la lectura de tickets, pero sí la definición de la prueba.

**Consecuencia:** la credencial de solo lectura es de solo lectura **para tickets, artículos y configuración**, pero conserva la capacidad nativa de un agente de editar clientes. El riesgo se controla con el cliente `GET`-only, el alcance del token, la expiración y el monitoreo; no se puede eliminar sin cambiar el rol de Zammad.

### 4.5 Prueba de aceptación que no puede escribir accidentalmente

**Diseño en cuatro capas:**

| Capa | Control | Qué garantiza |
|---|---|---|
| 1. Permiso | `groups_users.access = 'read'` | `change` no está concedido en el grupo |
| 2. Token | `permission = ['ticket.agent']`, sin `admin` | No puede invocar endpoints administrativos |
| 3. Cliente | Allowlist `GET` | El motor no puede emitir una escritura aunque quisiera |
| 4. Verificación | 11 negativas + contadores + canario | Detecta cualquier escritura real |

**Procedimiento propuesto (no ejecutado):**

1. Registrar contadores: `tickets`, `articles`, `histories`, `audit_logs`, `users`, `triggers`, `webhooks`, `slas`, `settings.updated_at`.
2. Identificar un ticket canario y un artículo canario con valores conocidos.
3. Ejecutar los 11 intentos de F0-03 **en instancia aislada**; si no existe, bloquear.
4. Verificar que **ninguna** devuelve `2xx`.
5. Volver a medir los contadores y comparar.
6. Verificar que el ticket y el artículo canario no cambiaron.
7. Verificar que `GET /settings`, `GET /calendars` y `GET /slas` devuelven 403.
8. Verificar que el token no tiene `admin` y que el usuario no tiene rol `Admin`.

**Criterio de aborto inmediato:** cualquier `2xx` en una llamada de escritura, cualquier cambio de contador no declarado o cualquier cambio en el canario.

**Ajuste obligatorio de F0-03:** el caso 7 se documenta como **7a** (cliente desechable → 200 legítimo de Zammad) y **7b** (agente/admin → 403); no se usan usuarios reales. El BFF debe bloquear el endpoint de usuarios. El diseño detallado está en `PAQUETE_AUTORIZACION_FASE_0_SLA.md` §6.6.

**Evidencia:** `F0-02_credential_pilot.json`, `F0-02_credential_isolated.json`, `F0-03_negative_writes.json`, `F0-04_admin_endpoints.json`, `F0-15_no_writes.json`.

### 4.6 Decisiones requeridas para DEP-04

| # | Decisión | Opciones | Recomendación |
|---:|---|---|---|
| 1 | ¿Se autoriza crear el usuario técnico y el token? | Sí / No | **Sí, acotado a Fase 0** |
| 2 | Gestor de secretos | Variables de entorno `0600` / Vault / otro | **Gestor dedicado o archivo `0600` fuera del repo** |
| 3 | Expiración del token | 30 / 90 / 180 días | **90 días con rotación** |
| 4 | ¿Se cifran los backups? | Sí / No | **Sí** |
| 5 | ¿Se acepta la excepción de `UserPolicy`? | Sí / No | **Sí, con monitoreo y cliente `GET`-only** |

**Estado:** las decisiones 1 a 5 siguen pendientes de autorización. El gestor de secretos, el cifrado de backups y la ventana son precondiciones de Fase 0.

---

## 5. Entorno controlado

### 5.1 Servicios activos (snapshot 21:13 UTC)

| Servicio | Puerto | Estado | Observación |
|---|---:|---|---|
| Zammad web (puma) | 3000 | Activo | Iniciado ~20:50 UTC |
| Zammad websocket | 6042 | Activo | Iniciado ~20:50 UTC |
| Zammad worker | — | **Activo** | `script/background-worker.rb` |
| Vite dev | 3036 | Activo | Servidor de assets de desarrollo |
| PostgreSQL | 5432 | Activo | 16.15 local |
| Redis | 6379 | Activo | 7.0.15, `dbsize = 0` |

### 5.2 Worker y concurrencia

| Elemento | Estado |
|---|---|
| Schedulers | **30 de 30 activos** |
| Scheduler de correo | «Check channels.», periodo **30 s**, activo |
| Cola diferida | 1 job, 0 fallidos |
| Efecto | Con el worker activo, Zammad consulta el canal Gmail cada 30 s y procesa notificaciones |
| Actividad concurrente | Otra sesión de operación levantó los procesos y generó 2 historias `notification` a las 20:51 UTC |

**Implicación para Fase 0:** el worker **escribe** historias y auditoría. Cualquier prueba que mida «sin escrituras» (F0-15) falla si el worker está activo durante la ventana, aunque el motor no escriba nada.

### 5.3 Dependencias del canal Gmail

| Elemento | Estado |
|---|---|
| Canal | `Google::Account` ID 4, activo |
| Cuenta | `vcastagnino@restaurant.pe` (piloto) |
| Entrada | IMAP XOAUTH2, `INBOX`, `keep_on_server = true` |
| Salida | SMTP `smtp.gmail.com:465`, XOAUTH2 |
| Token OAuth | `expires_in = 3599 s`; refresh token presente |
| Grupo | `Soporte Especializado` (ID 3) |
| Dependencia | Sin worker no hay recepción ni envío; el correo queda en el servidor por `keep_on_server` |

### 5.4 Riesgos de detener o reiniciar servicios

| Acción | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| Detener el worker | No se recibe correo nuevo; notificaciones y jobs se acumulan | Medio | Ventana corta; `keep_on_server` evita pérdida |
| Detener el worker | El token OAuth puede caducar sin refresco | Bajo | Se refresca al reiniciar; verificar |
| Reiniciar el worker | Se procesan jobs pendientes; pueden salir notificaciones tardías | Medio | Inspeccionar la cola sin alterarla; no `FLUSHDB`/`FLUSHALL`; procedimiento separado |
| Reiniciar web/websocket | Cortes de sesión; recarga de assets | Bajo | Ventana sin usuarios |
| Reiniciar Vite | Assets temporales no disponibles | Bajo | No afecta datos |
| Reiniciar PostgreSQL/Redis | Indisponibilidad total | Alto | No hacerlo en la ventana de pruebas |

### 5.5 Condiciones para acordar la ventana

1. **Coordinar con la sesión que opera la instancia.** No puede haber dos operadores a la vez.
2. **Congelar** código, configuración y catálogo durante la ventana.
3. **Tomar F0-01 inmediatamente antes** de la primera prueba y al cierre.
4. **Definir el estado del worker por prueba:** ventana exclusiva para F0-15; activo para F0-06; no se detiene ni reinicia en esta tarea.
5. **Usar solo tickets de prueba** identificados y declarados.
6. **Definir rollback** para cierres, reaperturas y fusiones.
7. **Registrar hora de inicio y fin** y los contadores de cada prueba.
8. **Declarar la ventana por escrito** (AP-03) antes de ejecutar.

### 5.6 Necesidades de entorno por prueba

| Prueba | Worker | Correo | Base BFF | Ticket de prueba |
|---|---|---|---|---|
| F0-02 | Indiferente | No | No | No |
| F0-03 | Indiferente | No | No | Sí, desechable; instancia aislada |
| F0-04 | Indiferente | No | No | No |
| F0-05 | Indiferente | No | No | Ticket desechable |
| F0-06 | **Activo** | **Sí** | No | Sí |
| F0-07 | Indiferente | No | No | Sí |
| F0-08 | Indiferente | No | No | Sí |
| F0-09 | Indiferente | No | No | Sí (dos) |
| F0-12 | Indiferente | No | **Sí** | No |
| F0-13 | Indiferente | No | **Sí** | No |
| F0-14 | Indiferente | No | **Sí** | No |
| F0-15 | **Ventana exclusiva** | No | No | No |
| F0-16 | Indiferente | No | **Sí** | No |

**Reglas de ambiente:** F0-06 requiere **barrera técnica del piloto**; sin ella, `blocked`. F0-15 requiere **ventana exclusiva** y evidencia §9.7.1; sin ella, `inconclusive`. F0-12 a F0-16 se ejecutan **en secuencia por defecto**.

---

## 6. Matriz de aprobaciones

Ninguna aprobación se asume. AP-01, AP-02 y AP-03 están en `conditional_pending_final_validation`; DP-04 está confirmada.

| ID | Qué se aprueba | Alcance | Evidencia de aprobación | Bloquea | Rol que aprueba | Estado |
|---|---|---|---|---|---|---|
| **AP-01** | Cierre funcional 5G.4.5 | Los seis documentos de 5G.4.5 como base contractual | Validación final expresa | Inicio de etapa 2 | Responsable de negocio + Dirección | **`conditional_pending_final_validation`** |
| **AP-02** | Alcance exclusivamente Email | Retiro de WhatsApp/WHATMETA/WHATICKET del SLA | Validación final expresa | Comunicación y aceptación | Responsable de negocio + Dirección | **`conditional_pending_final_validation`** |
| **AP-03** | Autorización de Fase 0 | Pruebas, usuario técnico, token, buzón y ventana | Validación final expresa | Ejecución de las 13 pruebas | Responsable de negocio + TI + Administrador de Zammad | **`conditional_pending_final_validation`** |
| **DP-04** | Dueño y proceso del catálogo | Rol responsable y proceso de alta, cambio, revisión y retiro | Registro de decisión: **Soporte** | — | Dirección + Responsable de negocio | **`Aprobada`** |

**Nota:** AP-01 y AP-02 son aprobaciones de negocio; AP-03 es una autorización operativa. Las tres siguen condicionales. DP-04 está confirmada con Soporte como responsable funcional y operativo.

---

## 7. Decisiones que requieren aprobación humana

| # | Decisión | Recomendación técnica | Quién decide | Estado |
|---:|---|---|---|---|
| 1 | Fuente de clasificación (DT-01) | **B: BFF** | Dueño de diseño + negocio | **`Aprobada`** |
| 2 | Rol del campo de Zammad | Espejo opcional con verificación | Dueño de diseño | **`Aprobada`** |
| 3 | Catálogo del selector (DT-02) | **65 con marca de política** | Negocio + DP-04 | **`Aprobada`** |
| 4 | Tratamiento de las 7 no servicio | Excluir del motor; sin fallback | Negocio + DP-04 | **`Aprobada`** |
| 5 | Dueño y proceso del catálogo (DP-04) | Rol + proceso | Dirección | **`Aprobada`** (Soporte) |
| 6 | Aprobación 5G.4.5 (AP-01) | Aprobar | Negocio + Dirección | `conditional_pending_final_validation` |
| 7 | Ratificación Email (AP-02) | Ratificar | Negocio + Dirección | `conditional_pending_final_validation` |
| 8 | Autorización Fase 0 (AP-03) | Autorizar acotado | Negocio + TI + Admin Zammad | `conditional_pending_final_validation` |
| 9 | Gestor de secretos y cifrado de backups | Aprobar | TI | `Pendiente` |
| 10 | Ventana de pruebas | Acordar | Operaciones + negocio | `Pendiente` |

---

## 8. Condiciones para iniciar Fase 0

| # | Condición | Estado actual |
|---:|---|---|
| 1 | AP-01 validada definitivamente | `conditional_pending_final_validation` |
| 2 | AP-02 ratificada definitivamente | `conditional_pending_final_validation` |
| 3 | DP-04 confirmada (Soporte) | **`Aprobada`** |
| 4 | DT-01 confirmada (BFF) | **`Aprobada`** |
| 5 | DT-02 confirmada (65 con marca + 7 excluidas) | **`Aprobada`** |
| 6 | AP-03 validada definitivamente | `conditional_pending_final_validation` |
| 7 | Credenciales piloto (F0-02-P) y aislada (F0-02-I) creadas | `Pendiente` |
| 8 | Buzón y ventana definidos | `Pendiente` |
| 9 | Base de pruebas del BFF disponible | `Pendiente` |
| 10 | Línea base F0-01 tomada en la ventana | `Pendiente` |
| 11 | Sin sesiones concurrentes | **No cumplido** (hay otra sesión operando) |
| 12 | Reversión documentada; probada: **no** | `Pendiente` |
| 13 | Diseño de seguridad aceptado | `Pendiente` |

**Conclusión:** Fase 0 **no puede iniciar** en el estado actual. Las decisiones funcionales están confirmadas; faltan las validaciones finales de AP-01/02/03, la credencial, el gestor de secretos, la ventana, la base del BFF y la ausencia de sesiones concurrentes.

---

## 9. Confirmación de solo lectura

Este análisis se hizo con consultas `SELECT`, lectura de código y lectura de archivos.

- No se modificó código.
- No se modificó la base de datos.
- No se modificó la configuración.
- No se modificaron atributos ni el catálogo.
- No se modificaron permisos, usuarios ni credenciales.
- No se modificaron buzones.
- No se iniciaron ni detuvieron servicios ni workers.
- No se enviaron correos.
- No se ejecutaron pruebas con escrituras.
- No se tocó Zendesk ni COSE.
- No se modificó ningún documento fuente de 5G; solo se actualizaron los documentos de seguimiento de EPIC-SLA-01.

Las escrituras de esta sesión son exclusivamente documentales: este análisis, el documento maestro y el tablero de Etapa 1.

**Nota de entorno:** al final de la sesión el shell de WSL presentó timeouts transitorios por carga de la sesión concurrente. Toda la evidencia se capturó antes; no se ejecutó ninguna acción correctiva.

---

## 10. Control de versiones

| Versión | Fecha | Cambio | Estado |
|---|---|---|---|
| 1.0 | 16/11/2026 | Análisis de DT-01, DT-02, DEP-04, entorno y aprobaciones | Vigente |
| 1.1 | 16/11/2026 | Consolidación de decisiones confirmadas (DT-01, DT-02, DP-04, 7 no servicio) y AP-01/02/03 condicionales | Vigente |

**Fin del análisis de bloqueantes de la etapa 1.1.**

