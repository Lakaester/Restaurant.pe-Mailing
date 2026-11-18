# PAQUETE DE APROBACIÓN PREVIO A MIGRACIÓN — EPIC-SLA-01

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Épica:** EPIC-SLA-01 — Motor SLA para correo electrónico
**Repositorio:** `C:\Users\acast\OneDrive\Escritorio\restaurant-bi-fase1\restaurant-bi`
**Rama:** `remediation/audit` · **HEAD:** `27b973a`
**Fecha:** 17/11/2026
**Naturaleza:** **paquete de aprobación. No es una aprobación.** Reúne lo que debe firmarse antes de crear la base de prueba, aplicar el DDL y cargar políticas.
**Estado del esquema:** versión candidata revisada. **No ejecutado. No aplicado.**

---

## 1. Cómo usar este paquete

Tres responsables deben pronunciarse. Cada uno firma una parte distinta y ninguna firma sustituye a otra.

| Rol | Qué firma | Sección |
|---|---|---|
| **Responsable funcional** (negocio / Soporte) | Decisión de ciclos (OBS-28) y ratificación del régimen de respaldo (OBS-30) | §5 y §9 |
| **Responsable técnico** (BFF) | Cuatro confirmaciones de especificación (OBS-31), clasificación vigente (OBS-33), registro de migraciones y frontera Prisma | §4, §6, §7 y §8 |
| **DBA** | Creación de la base y los roles (BLK-05), revisión del archivo y procedimiento M1–M8 | §10, §11 y §12 |
| **Soporte / dueño del catálogo (DP-04)** | Las 28 filas de respaldo, una por una | §9 y `MATRIZ_RATIFICACION_FALLBACK_SLA.md` |

**Secuencia recomendada:**

1. El responsable técnico resuelve OBS-31, OBS-33 y el registro de migraciones (D-03 a D-08). Son las que pueden cambiar el DDL; resolverlas **antes** de aplicar evita un `ALTER TABLE`.
2. El responsable funcional firma ciclos (D-01) y respaldo (D-02). **No** condicionan la aplicación, sí la carga y la implementación.
3. El DBA crea la base y los roles (D-09), revisa el archivo final y aprueba M1–M8 (D-10).
4. Solo entonces se aplica `001`, se ejecuta `001_verificacion_diseno_sla.sql` y se carga la matriz.

---

## 2. Separación de estados

### 2.1 Resumen de decisiones

| ID | Decisión | Tipo | Estado | Responsable | ¿Bloquea la aplicación? |
|---|---|---|---|---|---|
| **D-01** | Ciclos 2..N: alternativa A (ciclo con plazo propio) | Funcional | **Recomendada**, documentada; falta ratificación | Responsable funcional | No. Bloquea reaperturas y alertas por ciclo |
| **D-02** | Ratificar las 28 subcategorías con respaldo de 36 h | Funcional | **Preparada**, sin firma | Soporte + DP-04 | No. Bloquea la carga de políticas |
| **D-03** | `policy_class` | Técnica | **Propuesta en el DDL**; sin confirmar | Responsable técnico | Sí, en la práctica: un rechazo obliga a `ALTER TABLE` |
| **D-04** | Sexto estado `excluded_non_service` | Técnica / funcional | **Propuesta en el DDL**; sin confirmar | Responsable técnico con visto funcional | Sí, en la práctica |
| **D-05** | `threshold_pct = 100` (vencimiento) | Técnica | **Propuesta en el DDL**; sin confirmar | Responsable técnico | Sí, en la práctica |
| **D-06** | Tipo de divergencia `catalog_mirror_mismatch` | Técnica | **Propuesta en el DDL**; sin confirmar | Responsable técnico | Sí, en la práctica |
| **D-07** | Clasificación vigente (OBS-33) | Técnica | **Recomendación: tabla independiente** | Responsable técnico | No. Bloquea la interfaz de clasificación |
| **D-08** | Registro de migraciones | Técnica / DBA | **Recomendación: tabla propia** | Responsable técnico + DBA | **Sí: cambia el archivo 001 antes de aplicarlo** |
| **D-09** | Base `restaurant_bi_test` y dos roles | Infraestructura | **Solicitud redactada** | DBA | **Sí** (BLK-05) |
| **D-10** | Procedimiento M1–M8 | Proceso | **Diseñado, no aprobado** | Responsable técnico | **Sí** (BLK-06) |
| **D-11** | Designar dueño y proceso del catálogo | Organizativa | **Abierta** (DP-04) | Dirección | No |
| **D-12** | Conjunto final de canales de alerta (`internal`, `email`) | Técnica | **Propuesta en el DDL**; sin confirmar | Responsable técnico | No |
| **D-13** | Etiqueta de la Épica 1 en `AGENTS.md` | Documental | **Propuesta**, no ejecutada | Responsable del proyecto | No |
| **D-14** | Rotular el módulo `domain/sla/` legado | Documental | **Decisión tomada**; el cambio de archivos no está autorizado | Responsable técnico | No |

### 2.2 Qué está confirmado, qué está recomendado y qué está pendiente

| Categoría | Elementos |
|---|---|
| **Confirmado con evidencia** | Las 7 exclusiones DEC-05 (16/11/2026) · matriz oficial de 30 filas reproducida 30/30 (F0-10) · 1.016 tickets fuera de catálogo, 32,51 % (F0-11) · mapeo de categoría oficial (F0-11b) · línea base (F0-01) · repositorio, rama y HEAD · EPIC-SLA-01 registrada en `AGENTS.md` · catálogo exportado con hash idéntico y 5 pruebas en verde · frontera Prisma documentada · la discrepancia `source`/`webhook` de OBS-31 es falsa |
| **Recomendado, sin aprobar** | Alternativa A para ciclos (D-01) · las 4 confirmaciones de OBS-31 (D-03 a D-06) · tabla propia de clasificación vigente (D-07) · tabla propia de registro de migraciones (D-08) · conjunto de canales de alerta (D-12) |
| **Pendiente sin propuesta posible** | Base y roles (D-09) · aprobación de M1–M8 (D-10) · dueño del catálogo (D-11) · AP-01/AP-02/AP-03 · ventana de pruebas (BLK-09) · 13 pruebas de fase 0 |

**Regla de lectura:** un elemento «recomendado» **no** es una regla. El DDL contiene propuestas técnicas; este paquete no las convierte en decisiones aprobadas.

---

## 3. Decisiones que pueden considerarse cerradas

Se cierran con evidencia verificable, no con una firma nueva.

| # | Decisión | Evidencia | Qué queda |
|---:|---|---|---|
| 1 | **OBS-18 — identidad del backend** | `git rev-parse` sobre `restaurant-bi`; rama `remediation/audit`; HEAD `27b973a`; remoto `Lakaester/CentrodeAtenci-n` | Nada. Cerrada el 17/11/2026 |
| 2 | **OBS-21 — gobierno de la épica** | EPIC-SLA-01 registrada en `AGENTS.md` (sección «EPICA ACTIVA»), con alcance, fuera de alcance y reglas propias | Nada. Cerrada el 17/11/2026 |
| 3 | **OBS-05 — catálogo versionado** | Snapshot con SHA-256 `55cec0de…d9e97e` idéntico al origen; JSON `d0fb5aae…a91196`; metadatos; 5 pruebas en verde | El versionado en Git requiere commit, que no está autorizado |
| 4 | **OBS-29 — frontera Prisma** | `backend/prisma/schema.prisma` solo contiene `GenerateAnchor`; migraciones en SQL manual; reglas escritas en §8 | Su cumplimiento se verifica en la implementación |
| 5 | **OBS-31 #4 — `source` con `webhook`** | 5G.4.5 línea 108 ya define `poll \| reconcile \| manual`; línea 49 prohíbe webhooks | **Descartada como discrepancia.** No falta ninguna confirmación |
| 6 | **Matriz oficial de 30 filas** | Reproducida 30/30; suma 2.109; 27 con SLA (2.087); 3 sin evidencia (22); sin recálculo (F0-10) | AP-01 sigue condicional |
| 7 | **Volumen fuera de catálogo** | 1.016 de 3.125 (32,51 %), con reconciliación 3.125+12.466=15.591 (F0-11) | Nada. DP-E-08 cerrada |
| 8 | **Reclasificación sin tocar el compromiso** | Reglas de ciclos §8 y `sla_audit` con `old_value`/`new_value`; el DDL lo exige en `reclassify` | Depende de D-07 para ser consultable |
| 9 | **`merged` no cierra** | BR-34/BR-37; `exclusion_reason = 'merged'`; `closed_at` como instante de exclusión | Nada |
| 10 | **`pending close` no cierra ni pausa** | BR-33; reglas de ciclos §10 | Nada |

**No se cierra en esta lista:** REA-02..REA-06 (aunque 5G.4.5 las declara cerradas, falta la firma que sustituye al registro obsoleto de 5G.4.4), ni OBS-30 (faltan 28 firmas), ni OBS-31 #1/#2/#3/#5.

---

## 4. Fichas de aprobación — OBS-31

Las cuatro comparten la misma forma: el DDL ya contiene una propuesta técnica que la especificación 5G.4.5 no contempla. Ninguna cambia la estructura de 9 tablas; todas son columnas, valores o restricciones.

### 4.1 Ficha D-03 — `policy_class`

| Campo | Contenido |
|---|---|
| **Qué se decide** | Si `sla_policy_version` y `sla_commitment` llevan una columna `policy_class` con cuatro valores: `matrix`, `insufficient_evidence`, `fallback`, `excluded_non_service` |
| **Fuente EPIC** | BR-41 (3 combinaciones sin SLA, `assignment_status = 'no_policy'`, motivo `insufficient_evidence`) · BR-42 (esas 3 **no** reciben respaldo) · BR-43 (respaldo 36 h, `provisional`) · BR-65 (7 excluidas: sin SLA, sin respaldo, fuera de todo denominador) |
| **Fuente 5G.4.5** | `sla_policy_version` (§4.1, líneas 129-151) **no** tiene `policy_class`: distingue por `status` (`pending`) y por `resolution_minutes IS NULL`. `sla_commitment` (§4.2, líneas 159-190) tampoco la tiene: su `assignment_status` lista **5** valores (línea 165) |
| **Problema que resuelve** | Sin la clase, «sin evidencia» (3) y «no servicio» (7) se distinguen solo por combinaciones de `status` y nulos. BR-41 y BR-65 les dan tratamientos **opuestos**: las 3 quedan fuera por falta de datos y pueden entrar a la matriz futura; las 7 quedan fuera por decisión y no deben recibir respaldo nunca. Un esquema que no las separa obliga a inferirlo en código y hace frágil la carga |
| **Propuesta en el DDL** | `policy_class text`, con `CHECK (policy_class IN ('matrix','insufficient_evidence','fallback','excluded_non_service'))`; obligatoria en `sla_policy_version`; copiada como snapshot en `sla_commitment` |
| **Restricciones derivadas** | `matrix` exige `resolution_minutes`, `sample_size >= 10`, `p75_minutes` y `confidence` · `insufficient_evidence` exige `resolution_minutes IS NULL`, `status = 'pending'` y `sample_size < 10` · `excluded_non_service` exige `resolution_minutes IS NULL`, `status = 'inactive'` y primera respuesta nula · `fallback` exige 2.160 min, `category = '*'`, `subcategory = '*'` |
| **Impacto si se aprueba** | Ninguno sobre tablas, `FK` o índices. Cuatro `CHECK` adicionales ya presentes. La carga de 38 políticas se vuelve verificable por clase |
| **Impacto si se rechaza** | Hay que eliminar la columna de las dos tablas, quitar los `CHECK` que la referencian, ajustar los estados `no_policy`/`excluded_non_service` y el script de verificación. Los reportes por clase de política dejan de ser posibles; el denominador de la métrica pasa a depender de código |
| **Recomendación** | **Mantener.** Es la única forma de que BR-41/BR-42 y BR-65 sean representables sin ambigüedad |
| **Responsable** | Responsable técnico, con conformidad funcional sobre la semántica de las clases |
| **Aprobación** | ☐ Aprobado ☐ Rechazado ☐ Aprobado con condiciones: ______ |

### 4.2 Ficha D-04 — estado `excluded_non_service`

| Campo | Contenido |
|---|---|
| **Qué se decide** | Si `sla_commitment.assignment_status` admite un sexto valor: `excluded_non_service` |
| **Fuente EPIC** | DEC-05 (decisión confirmada el 16/11/2026) y BR-65: las 7 subcategorías no servicio (SIN HOMOLOGAR: Sin dato, Duplicado o spam, No contestó; RECLAMO: Reclamo; QUEJA: Servicio, Producto, Otro) quedan **excluidas del motor**: sin SLA, sin respaldo y **fuera de todo denominador** |
| **Fuente 5G.4.5** | §4.2 línea 165 lista **5** estados: `assigned`, `no_policy`, `pending_classification`, `historical`, `non_email` |
| **Problema que resuelve** | Ninguno de los 5 estados describe «ticket de correo, correctamente clasificado, excluido por decisión funcional». Meterlo en `no_policy` exige una política de insuficiencia que no existe y lo haría contar como «sin datos»; meterlo en `non_email` mentiría sobre el canal. Ambos errores contaminan denominadores |
| **Propuesta en el DDL** | Sexto valor, con `CHECK` propio: sin política, sin versión, sin clase, sin duraciones y con primera respuesta nula (`not_applicable`) |
| **Impacto si se aprueba** | Ninguno estructural. Un valor más en un `CHECK` existente |
| **Impacto si se rechaza** | DEC-05 no es representable sin falsear canal o clase. Habría que excluir esos tickets antes de crear el compromiso, y entonces no quedaría rastro de que fueron evaluados y excluidos |
| **Recomendación** | **Mantener.** Es la representación directa de una decisión ya confirmada |
| **Responsable** | Responsable técnico, con visto bueno funcional (la decisión de excluir ya es de negocio) |
| **Aprobación** | ☐ Aprobado ☐ Rechazado ☐ Aprobado con condiciones: ______ |

### 4.3 Ficha D-05 — `threshold_pct = 100`

| Campo | Contenido |
|---|---|
| **Qué se decide** | Si `sla_alert.threshold_pct` admite `100` además de `75` y `90` |
| **Fuente EPIC** | BR-54: «Las alertas se emiten al 75 %, al 90 % **y al vencimiento**, una por compromiso, ciclo, métrica y umbral» |
| **Fuente 5G.4.5** | §4.6 línea 273: `CHECK (threshold_pct IN (75, 90))`. **Pero** §8 (líneas 445-455) publica una tabla de alertas con **tres** columnas: 75 %, 90 % y **Vencimiento**, con instantes concretos (24 h, 36 h, 48 h…). La especificación se contradice a sí misma |
| **Problema que resuelve** | Sin un valor para «vencimiento», la alerta de BR-54 no se puede registrar sin inventar una convención fuera del esquema. La columna es `NOT NULL` y tiene un `UNIQUE` por umbral: usar `NULL` rompería ambos |
| **Propuesta en el DDL** | `CHECK (threshold_pct IN (75, 90, 100))`, con `100` documentado como vencimiento |
| **Impacto si se aprueba** | Ninguno estructural. Un valor más en un `CHECK` existente. Coincide con §8 y con BR-54 |
| **Impacto si se rechaza** | Se pierde la alerta de vencimiento o se codifica como 90 %, lo que mezcla «aviso de riesgo» con «vencido» y hace imposible distinguirlos en el tablero. Habría que corregir BR-54 o §8 |
| **Recomendación** | **Mantener**, y dejar constancia de que resuelve una contradicción interna de 5G.4.5 a favor de §8 y BR-54 |
| **Responsable** | Responsable técnico |
| **Aprobación** | ☐ Aprobado ☐ Rechazado ☐ Aprobado con condiciones: ______ |

### 4.4 Ficha D-06 — `catalog_mirror_mismatch`

| Campo | Contenido |
|---|---|
| **Qué se decide** | Si `sla_divergence.kind` admite el tipo `catalog_mirror_mismatch` |
| **Fuente EPIC** | BR-66: la clasificación manual se registra en el BFF como par (categoría oficial, subcategoría oficial); el campo `categoria_subcategoria` de Zammad es un **espejo opcional**; si difiere, **se registra divergencia** y prevalece el BFF |
| **Fuente 5G.4.5** | §4.8 línea 306 lista **9** tipos: `missing_close`, `missing_reopen`, `policy_mismatch`, `orphan_ticket`, `delivery_unresolved`, `late_classification`, `merged_ticket`, `non_email_ticket`, `delivery_date_missing`. Ninguno describe «el espejo de Zammad no coincide con el BFF» |
| **Problema que resuelve** | BR-66 exige registrar el hecho. Sin un tipo propio habría que usar `policy_mismatch` (que significa «la política aplicada no coincide con la vigente») u `orphan_ticket` (que significa «el ticket no existe en la fuente»). Ambos falsean el diagnóstico: la divergencia de espejo es un problema **de datos de clasificación**, no de política ni de existencia |
| **Propuesta en el DDL** | Tipo adicional en `CHECK (kind IN (...))`, sin cambios de columnas |
| **Impacto si se aprueba** | Ninguno estructural |
| **Impacto si se rechaza** | BR-66 queda sin representación específica; las divergencias de espejo se mezclan con otras y el tablero de integridad pierde la señal que DP-04 necesita para decidir si el catálogo se actualiza |
| **Recomendación** | **Mantener** |
| **Responsable** | Responsable técnico |
| **Aprobación** | ☐ Aprobado ☐ Rechazado ☐ Aprobado con condiciones: ______ |

### 4.5 Ficha complementaria D-12 — canales de alerta

| Campo | Contenido |
|---|---|
| **Qué se decide** | Confirmar que los canales de `sla_alert` son `internal` y `email` |
| **Fuente EPIC** | BR-54 (alertas del motor, no de Zammad) y §7.4 (sin webhooks) |
| **Fuente 5G.4.5** | No fija el conjunto; prohíbe webhooks (línea 49) y explica por qué (los updates de artículo se descartan) |
| **Problema** | El DDL anterior admitía `webhook`, en contradicción directa con la prohibición. Se eliminó. El conjunto final no está aprobado explícitamente |
| **Propuesta** | `CHECK (channel IN ('internal','email'))` |
| **Impacto si se rechaza** | Habría que decidir otro canal (por ejemplo, solo `internal`) y ajustar el `CHECK` y el notificador |
| **Recomendación** | **Mantener** dos canales: nota interna en el BFF y correo al responsable |
| **Responsable** | Responsable técnico |
| **Aprobación** | ☐ Aprobado ☐ Rechazado ☐ Aprobado con condiciones: ______ |

---

## 5. OBS-28 — Ciclos 2..N

**Documento completo:** `DECISION_CICLOS_REAPERTURA_OBS_28.md`.

| Aspecto | Resumen |
|---|---|
| **Qué se decide** | Si cada reapertura abre un ciclo con plazo propio (A) o un ciclo sin plazo (B) |
| **Hecho verificado** | A está descrita con fórmula en BR-38, declarada «Alternativa A aprobada» en `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 y listada como cerrada en `RESUMEN_EJECUTIVO_5G4_5.md` §3.1. `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` sigue diciendo PENDIENTE: es un registro anterior que nunca se actualizó |
| **Aclaración necesaria** | «B: no se asigna compromiso nuevo» describe también a A. El compromiso es único por ticket y no cambia en ninguna alternativa. La diferencia real es **plazo sí / plazo no** |
| **Representabilidad** | A cabe sin cambios. B no: heredar el vencimiento del ciclo 1 viola `sla_cycle_due_order_ck` si la reapertura ocurre después de vencer; dejarlo nulo viola `sla_cycle_open_needs_due_ck` |
| **Riesgo de B** | Si se relajara la restricción, un ciclo cerrado sin plazo podría registrarse como `met` o `missed`: en SQL, comparar con `NULL` devuelve `NULL` y un `CHECK` que evalúa a `NULL` no falla. El resultado quedaría sin referencia temporal |
| **Efecto en alertas** | A permite 75/90/vencimiento por ciclo. B no: `sla_alert.due_at` es `NOT NULL` y los umbrales se calculan sobre el vencimiento |
| **Recomendación** | **A** |
| **Efecto sobre el DDL** | Ninguno |
| **Responsable** | Responsable funcional |
| **Firma** | ☐ A ☐ B — Nombre / fecha: ____________ |

**Consecuencia de no firmar:** OBS-28 sigue abierta. No impide aplicar el DDL ni cargar políticas; impide implementar reaperturas y alertas por ciclo.

---

## 6. OBS-33 — Clasificación vigente

### 6.1 El problema

El compromiso guarda `category` y `subcategory` como **snapshot inmutable** al clasificar. La reclasificación se registra en `sla_audit` con `old_value` y `new_value`, y el compromiso no se toca. Correcto según BR-44 y las reglas de ciclos §8.

Lo que falta: **la clasificación actual no está almacenada en ningún sitio consultable.** Para mostrar «categoría actual del ticket» hay que leer el último registro de auditoría y extraer JSONB, o recalcular desde Zammad.

Consecuencias concretas:

| Necesidad | Con el esquema actual |
|---|---|
| Consultar la categoría actual de un ticket | Recorrido de `sla_audit` por entidad, ordenado, con extracción de JSONB. No indexable por categoría |
| Listar tickets por categoría actual | Imposible sin función o vista sobre JSONB |
| Auditar reclasificaciones | Sí: `sla_audit` (acción `reclassify`, con motivo) |
| Mantener inmutable el compromiso | Sí, por diseño |
| Mostrar la clasificación en el frontend | Requiere la consulta anterior en cada fila de la bandeja |
| Detectar divergencia con el espejo de Zammad | Requiere comparar el espejo con una clasificación que hay que derivar |

### 6.2 Alternativas

| Criterio | **A. Columnas en `sla_commitment`** | **B. Tabla `sla_classification`** | **C. Derivar de eventos o auditoría** |
|---|---|---|---|
| Consulta de la clasificación actual | Directa, misma fila | Directa, índice único parcial `WHERE is_current` | Recorrido de JSONB por ticket |
| Indexable por categoría | Sí | Sí | No sin índice de expresión |
| Historial de reclasificaciones | Solo en `sla_audit` | En la propia tabla | En eventos y auditoría |
| Inmutabilidad del compromiso | **Se debilita**: mete estado mutable junto al snapshot congelado | **Se preserva**: el compromiso no cambia | Se preserva |
| Frontend | Trivial | Un `JOIN` indexado | Costoso por fila |
| Divergencia con el espejo | Comparación directa | Comparación directa | Derivación previa |
| Retención | Permanente | Permanente | **Limitada**: `sla_event` se retiene 2 años y el compromiso es permanente. Un ticket antiguo perdería la clasificación derivable |
| Coste de esquema | +2 columnas y un riesgo de dos pares que diverjan | +1 tabla, +1 `FK`, +2 índices, +3 `CHECK` | 0 |

**Sobre C:** los tipos de evento `ticket.classified` y `ticket.reclassified` ya existen, así que la derivación es posible **hoy**. El problema no es la posibilidad, es la retención: la clasificación vigente de un ticket de hace tres años no se podría reconstruir. Para un dato que el frontend consulta en cada carga, depender de la retención de eventos es frágil.

**Sobre A:** el compromiso ya tiene columnas mutables (`last_seen_state`, `last_seen_updated_at`, `reclassified_count`), así que A no rompe una pureza que no existe. El problema es otro: `category`/`subcategory` congeladas y `current_category`/`current_subcategory` vivas en la misma fila invitan a leer la pareja equivocada, y ninguna restricción puede impedirlo.

### 6.3 Recomendación

**Recomendación: B — tabla independiente `sla_classification`.**

Satisface los cinco requisitos del encargo: consulta rápida (índice único parcial), auditoría de reclasificaciones (historial completo en la tabla, además de `sla_audit`), compromiso intacto (no se toca la tabla del snapshot), frontend (un `JOIN`), y divergencia con Zammad (comparación directa con el espejo).

**Borrador de DDL, NO aplicado:**

```sql
CREATE TABLE sla_classification (
    id             uuid        NOT NULL DEFAULT gen_random_uuid(),
    ticket_id      integer     NOT NULL,
    commitment_id  uuid        NOT NULL,
    category       text        NOT NULL,
    subcategory    text        NOT NULL,
    policy_key     text,
    origin         text        NOT NULL,
    classified_by  text        NOT NULL,
    classified_at  timestamptz NOT NULL,
    reason         text,
    is_current     boolean     NOT NULL DEFAULT true,
    created_at     timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT sla_classification_pk PRIMARY KEY (id),
    CONSTRAINT sla_classification_commitment_fk
        FOREIGN KEY (commitment_id) REFERENCES sla_commitment (id)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT sla_classification_origin_ck
        CHECK (origin IN ('manual', 'reconcile')),
    CONSTRAINT sla_classification_shape_ck
        CHECK (category <> '' AND subcategory <> ''),
    CONSTRAINT sla_classification_history_ck
        CHECK (is_current OR reason IS NOT NULL)
);

-- Una sola fila vigente por compromiso; el historial queda completo.
CREATE UNIQUE INDEX sla_classification_current_uq
    ON sla_classification (commitment_id)
    WHERE is_current;

CREATE INDEX sla_classification_lookup_idx
    ON sla_classification (category, subcategory);
```

**Reglas de escritura, que deben quedar en el código, no en la base:** una sola transacción marca la fila anterior `is_current = false` con `reason`, inserta la nueva y escribe `sla_audit`. El índice único impide dos vigentes; no impide cero. La regla «siempre exactamente una» se verifica en la reconciliación, no con un `CHECK`.

**Por qué no se aplica ahora:** el encargo lo prohíbe expresamente. Cambiar el modelo de 9 tablas exige actualizar cinco artefactos a la vez (diseño, `001`, rollback, verificación y conteos) y una nueva revisión del DBA.

### 6.4 Ficha D-07

| Campo | Valor |
|---|---|
| **Decisión** | Adoptar la opción B para la clasificación vigente |
| **Efecto si se aprueba** | El modelo pasa de 9 a 10 tablas; se añaden 1 `FK`, 3 `CHECK` y 2 índices con nombre |
| **Efecto si se rechaza** | Se implementa C (derivación desde eventos y auditoría), con la limitación de retención y el coste de consulta documentados |
| **Alternativa intermedia** | A: dos columnas en `sla_commitment`; menor coste, mayor riesgo de lectura errónea |
| **Responsable** | Responsable técnico |
| **Bloquea la aplicación del DDL** | **No.** Bloquea la interfaz de clasificación |
| **Firma** | ☐ B ☐ A ☐ C — Nombre / fecha: ____________ |

---

## 7. Registro de migraciones

### 7.1 Estado real del repositorio

| Hecho verificado | Resultado |
|---|---|
| Archivos SQL de migración | **24** en `backend/prisma/migrations/` (planos, sin carpetas con marca de tiempo) y **11** en `backend/sql/migrations/` (más 2 `.json` de línea base) |
| ¿Formato de Prisma Migrate? | **No.** No hay `migration_lock.toml` ni carpetas con `migration.sql`; Prisma no reconoce este historial |
| ¿Hay tabla de control? | **No.** Ninguna tabla `_prisma_migrations`, `schema_migrations` ni equivalente |
| ¿Hay herramienta de migración? | **No.** No hay script `migrate` en `package.json`; solo `prisma:generate` y `prisma:pull` |
| Cómo se aplican hoy | `psql` manual sobre `DATABASE_URL`; el registro de qué se aplicó es **documental** |
| Riesgo actual | No se puede saber, consultando la base, qué migración está aplicada. Ya existe hoy, no lo crea el módulo SLA |

### 7.2 Alternativas

| Opción | Ventaja | Coste | ¿Duplica algo? |
|---|---|---|---|
| **`sla_schema_migration` (tabla propia)** | Estado consultable; guarda de doble aplicación dentro del propio SQL; hash por archivo; sobrevive a reinicios; no depende de herramientas | +1 tabla, +4 `CHECK` | **No**: hoy no existe ninguna tabla de control. No duplica Prisma, que no gestiona este esquema |
| **Registro externo** (documento firmado con hash, fecha, usuario, base) | Sin cambios de esquema | No es consultable; no impide aplicar dos veces; depende de disciplina | Duplica el paso M8 del procedimiento, que ya exige esa evidencia |
| **Mecanismo existente del repositorio** | Nada nuevo | **No existe mecanismo**: solo archivos sueltos. Adoptarlo es no tener control | — |

### 7.3 Recomendación

**Recomendación: tabla propia `sla_schema_migration`, alcance mínimo.**

Motivos:

1. **No duplica nada.** Prisma no gestiona estas tablas y el repositorio no tiene registro. La alternativa «usar lo existente» no existe.
2. **Resuelve un riesgo real, no teórico.** El procedimiento M8 exige registrar hash y base; sin tabla, ese registro es un documento que puede perderse o contradecir la realidad.
3. **Habilita una guarda dentro del propio archivo.** El `001` puede empezar creando el registro si no existe, abortar si la versión `001` ya está inscrita y anotarse al final, todo en la misma transacción `-1` del paso M6. Eso convierte «no aplicar dos veces» en una garantía de la base, no en una instrucción.
4. **Coste acotado.** Una tabla sin `FK`, con cuatro `CHECK` y una PK.

**Borrador de DDL, NO aplicado:**

```sql
CREATE TABLE IF NOT EXISTS sla_schema_migration (
    version          text        NOT NULL,
    description      text        NOT NULL,
    checksum_sha256  text        NOT NULL,
    database_name    text        NOT NULL,
    applied_by       text        NOT NULL,
    applied_at       timestamptz NOT NULL DEFAULT now(),
    rollback_file    text,
    notes            text,

    CONSTRAINT sla_schema_migration_pk PRIMARY KEY (version),
    CONSTRAINT sla_schema_migration_version_ck
        CHECK (version ~ '^[0-9]{3}$'),
    CONSTRAINT sla_schema_migration_checksum_ck
        CHECK (checksum_sha256 ~ '^[0-9a-f]{64}$'),
    CONSTRAINT sla_schema_migration_db_ck
        CHECK (database_name = 'restaurant_bi_test'),
    CONSTRAINT sla_schema_migration_actor_ck
        CHECK (applied_by <> '')
);
```

**Consecuencia que debe asumirse:** si se aprueba, el modelo pasa a 10 tablas (11 si además se aprueba D-07) y **el archivo `001` cambia antes de aplicarse**. Los conteos que hoy verifican el diseño también cambian:

| Elemento | Hoy | Con D-08 | Con D-07 + D-08 |
|---|---:|---:|---:|
| Tablas | 9 | 10 | 11 |
| `CHECK` con nombre | 100 | 104 | 107 |
| Claves foráneas | 4 | 4 | 5 |
| Índices con nombre | 24 | 24 | 26 |

Además, `sla_audit.entity_type` debería admitir `classification` y `migration` si se auditan esos cambios: es una modificación de un `CHECK` existente, no uno nuevo.

**Consecuencia del rollback:** si el registro vive en el mismo esquema, el `down` lo elimina y con él la evidencia de aplicación. Por eso el paso M8 debe seguir produciendo evidencia **externa** (hash y salida de verificación). La tabla mejora el control, no sustituye la evidencia.

### 7.4 Ficha D-08

| Campo | Valor |
|---|---|
| **Decisión** | Añadir `sla_schema_migration` como décima tabla y guarda de doble aplicación en `001` |
| **Efecto si se aprueba** | Cambia `001`, el rollback (un `DROP` más), el script de verificación (un bloque más) y los conteos |
| **Efecto si se rechaza** | Se mantiene el registro documental del paso M8 y se acepta el riesgo de doble aplicación |
| **Responsable** | Responsable técnico, con conformidad del DBA |
| **Bloquea la aplicación** | **Sí**, porque modifica el archivo que se va a aplicar |
| **Firma** | ☐ Aprobado ☐ Rechazado — Nombre / fecha: ____________ |

---

## 8. Coexistencia con Prisma 5

### 8.1 El modelo

Prisma **no posee** el esquema SLA. `backend/prisma/schema.prisma` contiene solo el modelo ancla `GenerateAnchor`, que existe para que `prisma generate` no falle y no representa ninguna tabla. Las 9 tablas del motor se crean y evolucionan por SQL manual.

El acceso del motor será SQL tipado sobre el cliente Prisma existente (`$queryRaw`, `$executeRaw`), no el cliente generado por modelo.

### 8.2 Por qué no se modela en Prisma

| Motivo | Detalle |
|---|---|
| `CHECK` | Prisma 5 no los expresa en `schema.prisma` |
| Índices únicos parciales | No se expresan; el diseño usa 3, y son la garantía de «un ciclo abierto» y «una divergencia abierta» |
| `timestamptz` y `jsonb` con precisión | Se pueden mapear, pero el `CHECK` y el índice parcial seguirían fuera del modelo |
| Historial | `prisma migrate` no puede reproducir este SQL; crearía un historial paralelo |

### 8.3 Controles propuestos

| # | Control | Cómo se verifica | Estado |
|---:|---|---|---|
| 1 | `schema.prisma` no contiene modelos `sla_*` | Búsqueda textual; propuesta de prueba automatizada | Propuesto, no implementado |
| 2 | Prohibido `prisma db pull` | Instrucción + revisión de `schema.prisma` tras cada uso | Vigente como norma; **no** hay guarda técnica |
| 3 | Prohibido `prisma db push` | Ídem | Vigente como norma |
| 4 | Prohibido `prisma migrate`, `migrate dev`, `migrate deploy` | Ídem. Además, el directorio no tiene formato de Prisma Migrate | Vigente como norma |
| 5 | Prohibido `prisma db execute` con SQL del módulo | Evita aplicar el DDL sin pasar por M1–M8 | Vigente como norma |
| 6 | Comandos permitidos | `prisma generate`, `prisma format`, `prisma validate` | — |
| 7 | Acceso por repositorio único | Un módulo con SQL etiquetado; sin concatenación de cadenas | Pendiente de implementación |
| 8 | El script `prisma:pull` existe en `package.json` | Es un riesgo vivo: está a un comando de distancia | **Documentado**; retirarlo exige autorización |

**Comprobación mínima antes de cualquier comando Prisma:**

1. Confirmar el destino de `DATABASE_URL` mostrando solo host y base, nunca la contraseña.
2. Confirmar que `git diff backend/prisma/schema.prisma` está vacío antes y después.
3. Si el comando es `pull`, `push` o `migrate`: **detenerse**. No es un comando de este módulo.

### 8.4 Por qué `db pull` es peligroso aquí

`db pull` **sobrescribe** `schema.prisma` con lo que introspecciona de la base. Sobre una base que contenga las tablas SLA, el resultado añadiría modelos para ellas y para las tablas históricas del BI, y perdería el comentario que explica que `GenerateAnchor` es un ancla. No es un riesgo de las tablas SLA: es un riesgo del archivo ancla y del historial del repositorio.

---

## 9. Matriz de ratificación — 28 respaldos

**Documento completo:** `MATRIZ_RATIFICACION_FALLBACK_SLA.md`.

| Concepto | Valor |
|---|---|
| Subcategorías con respaldo | **28** |
| Categorías afectadas | **9** |
| Política propuesta | `99-FALLBACK` · 2.160 min (36 h) · `provisional = true` |
| Fundamento por fila | Fuera de las 30 filas de la matriz; no figura entre las 7 exclusiones DEC-05 |
| Respuestas admitidas | RATIFICO / EXCLUIR (requiere enmendar DEC-05) / PROMOVER (requiere n ≥ 10 y P75) |
| Distribución | FACTURACIÓN ELECTRÓNICA 4 · LOGÍSTICA 3 · INTEGRACIONES 2 · SOFTWARE 3 · GESTIÓN 2 · ADMINISTRATIVO 4 · OPERATIVO 3 · CAPACITACIÓN 5 · SERVIDOR 2 |
| Concentración del respaldo | GESTIÓN (404), FACTURACIÓN ELECTRÓNICA (284), ADMINISTRATIVO (188) y SOFTWARE (131) explican el 99,1 % del volumen fuera de la matriz |
| Estado | **Pendiente de firma de Soporte** |
| Efecto sobre el DDL | Ninguno |
| Efecto sobre la migración | Ninguno: la carga es posterior |

**Tres advertencias para el firmante:**

1. `cambio_de_razón_social` existe en dos categorías con políticas distintas (72 h de matriz en FACTURACIÓN, 36 h de respaldo en ADMINISTRATIVO). La clave por par es lo que evita la ambigüedad.
2. `redes_y_conexiones` y `caída_del_servidor` existen duplicadas en OPERATIVO y SERVIDOR; ambas son respaldo, así que la duplicación no crea conflicto hoy.
3. Los cinco rótulos de mayor volumen fuera de catálogo (`consultas generales`, `consultas fe`, `comunicacion de baja`, `seguimiento de cdt certificado`, `mejoras personalizadas`) **no** están en estas 28 filas porque no son subcategorías del catálogo. Su alta es DP-04.

---

## 10. Requisitos del DBA (BLK-05)

**Solicitud completa:** `PLAN_DESBLOQUEO_IMPLEMENTACION_SLA.md` §4.2.

| Requisito | Detalle |
|---|---|
| Base | `restaurant_bi_test`, nueva e independiente. No `pgvector_db` ni base de negocio |
| Rol de migración | `cope_test_migration`: login, `CREATE` sobre `public` de la base de prueba, sin `SUPERUSER`, `CREATEDB` ni `CREATEROLE` |
| Rol de ejecución | `cope_test_runtime`: login, `SELECT/INSERT/UPDATE/DELETE` sobre las tablas del motor; **sin** `UPDATE` ni `DELETE` sobre `sla_audit`; sin DDL |
| Credenciales | Definidas por el DBA, entregadas por canal seguro. No se reutilizan las de producción |
| Datos | Solo sintéticos. No restaurar respaldos de producción |
| Red | Accesible solo desde la estación autorizada, si el servidor lo permite |
| Respaldos | Incluir la base en la política de respaldo con retención definida |

**Verificación que debe entregar el DBA (solo lectura):**

```sql
SELECT current_database(), current_user, inet_server_addr(), inet_server_port();
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole
  FROM pg_roles
 WHERE rolname IN ('cope_test_migration', 'cope_test_runtime');
SELECT datname FROM pg_database
 WHERE datname IN ('restaurant_bi_test', 'pgvector_db');
```

**Criterio de aceptación:** las tres consultas devuelven lo esperado; ambos roles tienen los tres atributos en `false`; la base de prueba y la de producción son distintas.

**Por qué no lo puede hacer el equipo:** el rol de producción `pgvector_user` no tiene `CREATEDB` ni `CREATEROLE`, y elevarlo está prohibido. Crear la base desde el equipo exigiría justamente el privilegio que se niega.

---

## 11. Estado de M1–M8

| Paso | Qué exige | Estado | Evidencia |
|---|---|---|---|
| **M1** Identificar destino | Mostrar host y base de `DATABASE_URL` sin contraseña | Diseñado, no ejecutado | `PLAN` §5.2 |
| **M2** Bloquear producción | Comparar contra lista negra (`<IP_BD_PRODUCCION>`, `pgvector_db`) | Diseñado, no ejecutado | Ídem |
| **M3** Verificar rol | `current_user = 'cope_test_migration'` | Diseñado, no ejecutado | Ídem |
| **M4** Revisar el SQL | Sin `DROP` ajeno, sin `TRUNCATE`, sin otra base | **Aplicado a mano** sobre `001`: 0 `CASCADE`, 0 sentencias de datos, 9 `DROP` en el rollback | `REVISION_DECISIONES_PENDIENTES_SLA.md` §6 |
| **M5** Respaldo previo | R1/R2 | Diseñado, no ejecutado | `PLAN` §4.3 |
| **M6** Aplicación | `psql -v ON_ERROR_STOP=1 -1 -f` | Diseñado, no ejecutado | `PLAN` §5.2 |
| **M7** Verificación | `001_verificacion_diseno_sla.sql` | **Preparado**, no ejecutado | `sql/001_verificacion_diseno_sla.sql` |
| **M8** Evidencia | Fecha, usuario, base, hash, resultado | Diseñado; se propone formalizarlo con D-08 | `PLAN` §5.2 |

**Estado global:** procedimiento **diseñado y no probado**. BLK-06 sigue abierto. Ningún paso se ha ejecutado contra ninguna base.

---

## 12. Condiciones de aplicación del DDL

| # | Condición | Responsable | ¿Bloqueante? | Evidencia de cumplimiento |
|---:|---|---|---|---|
| C1 | Base `restaurant_bi_test` y dos roles creados y verificados (D-09) | DBA | **Sí** | Las tres consultas de §10 |
| C2 | Procedimiento M1–M8 aprobado (D-10) | Responsable técnico | **Sí** | Firma sobre `PLAN` §5.2 |
| C3 | Decisión sobre el registro de migraciones (D-08) | Responsable técnico + DBA | **Sí** (cambia `001`) | Ficha D-08 |
| C4 | Cuatro confirmaciones de OBS-31 (D-03 a D-06) | Responsable técnico | **Recomendada antes de aplicar** | Fichas §4 |
| C5 | Revisión final del archivo `001` por el DBA, con hash | DBA | **Sí** | Hash registrado en M8 |
| C6 | Ventana de pruebas declarada (BLK-09) para aplicar y probar el `down` | Operador de la sesión concurrente | **Sí** para la prueba; no para redactar | Declaración de ventana |

**No son condiciones de aplicación:** D-01 (ciclos), D-02 (ratificación de respaldo), D-07 (clasificación vigente) y D-11 (dueño del catálogo). La primera afecta a la implementación de reaperturas, la segunda a la carga de políticas, la tercera a la interfaz y la cuarta al régimen del respaldo. Confundirlas retrasaría la migración sin motivo.

**Si C3 se aprueba, el orden interno del archivo `001` cambia:** crear el registro si no existe, comprobar que `001` no está inscrita, ejecutar el DDL, inscribir la versión. Todo dentro de la transacción del paso M6, para que no pueda quedar a medias.

---

## 13. Criterios de rollback

| Elemento | Definición |
|---|---|
| **Archivo** | `sql/001_rollback_diseno_sla.sql` — 9 `DROP TABLE IF EXISTS` en orden inverso al de creación |
| **Guarda** | Aborta si la base no es `restaurant_bi_test` o si el rol no es `cope_test_migration` |
| **Sin `CASCADE`** | Si aparece una dependencia inesperada, debe fallar en lugar de arrastrar objetos ajenos |
| **Qué elimina** | Solo las tablas `sla_*` creadas por `001` |
| **Qué no toca** | Zammad, `public.v_unificado_norm`, tablas históricas del BI, roles, la base, extensiones |
| **Cuándo ejecutarlo** | (a) M7 falla y no se corrige hacia delante; (b) los conteos aplicados no coinciden con el diseño; (c) hay que reaplicar `001` corregido |
| **Cuándo no ejecutarlo** | Por comodidad, sin respaldo, sobre otra base, o con datos que se quieran conservar |
| **Antes** | Respaldo R1/R2 del paso M5 |
| **Después** | Verificar que las 9 tablas no existen y que no quedaron índices ni restricciones |
| **Si se aprueba D-08** | El `down` debe incluir `DROP TABLE IF EXISTS sla_schema_migration`. Eso borra la evidencia de aplicación: el paso M8 debe conservarla fuera de la base |
| **Si se aprueba D-07** | El `down` debe incluir `sla_classification` en la posición inversa correcta (antes de `sla_commitment`) |
| **Reversibilidad de datos** | En esta etapa no hay datos: el rollback es estructural. Una vez cargadas las políticas, el `down` destruye la carga y exige volver a ejecutar la carga |

---

## 14. Hoja de firmas

| Decisión | Responsable | Nombre | Fecha | Firma | Resultado |
|---|---|---|---|---|---|
| D-01 Ciclos 2..N | Responsable funcional | | | | ☐ A ☐ B |
| D-02 28 respaldos | Soporte + DP-04 | | | | ☐ Ratificado ☐ Con exclusiones |
| D-03 `policy_class` | Responsable técnico | | | | ☐ ☐ ☐ |
| D-04 `excluded_non_service` | Responsable técnico | | | | ☐ ☐ ☐ |
| D-05 `threshold_pct = 100` | Responsable técnico | | | | ☐ ☐ ☐ |
| D-06 `catalog_mirror_mismatch` | Responsable técnico | | | | ☐ ☐ ☐ |
| D-07 Clasificación vigente | Responsable técnico | | | | ☐ B ☐ A ☐ C |
| D-08 Registro de migraciones | Responsable técnico + DBA | | | | ☐ ☐ |
| D-09 Base y roles | DBA | | | | ☐ Cumplido |
| D-10 M1–M8 | Responsable técnico | | | | ☐ Aprobado |
| D-12 Canales de alerta | Responsable técnico | | | | ☐ ☐ ☐ |

**Una firma no implica las demás.** La aprobación técnica del esquema no aprueba la ratificación funcional del respaldo, y la creación de la base no aprueba el procedimiento.

---

## 15. Validación de esta versión

| Verificación | Resultado |
|---|---|
| Tablas en `001` | 9 |
| `CHECK` con nombre en `001` | 100 |
| Claves foráneas | 4 |
| Índices con nombre | 24 (3 únicos parciales) |
| `DROP` en el rollback | 9, en orden inverso exacto |
| Sentencias de escritura en el DDL | 0 |
| `CASCADE` | 0 |
| Triggers | 0 |
| Filas de la matriz de catálogo | 65 → 27 / 3 / 28 / 7 |
| Filas de la matriz de ratificación | 28, en 9 categorías |
| Correspondencia `001` ↔ script de verificación | 100 `CHECK` idénticos, 24 índices referenciados |
| Hash del catálogo | `d0fb5aae…a91196` (sin cambios) |
| Hash del snapshot | `55cec0de…d9e97e` (sin cambios) |
| Errores del verificador estructural | 0 |
| Avisos | 0 |

El detalle del método está en `REVISION_DECISIONES_PENDIENTES_SLA.md` §6 y §10. El script de verificación sigue **sin ejecutarse**: requiere la base de prueba y el esquema aplicado.

---

## 16. Confirmación

- No se conectó a PostgreSQL ni a ninguna base de datos.
- No se ejecutó SQL, migración ni script de verificación.
- No se creó ni modificó ninguna base, rol, tabla, índice, restricción, vista o extensión.
- No se aplicó ningún `ALTER TABLE` ni cambio equivalente.
- No se modificó el DDL, el rollback ni el script de verificación en esta etapa: las propuestas de D-07 y D-08 están **escritas, no aplicadas**.
- No se modificó la matriz de catálogo, sus cantidades ni los hashes verificados.
- No se modificó Zammad, sus tablas, sus workers, sus credenciales ni sus políticas SLA nativas.
- No se alteró `public.v_unificado_norm` ni ninguna tabla histórica del BI.
- No se modificaron los 58 archivos de `docs/captures/`.
- No se iniciaron ni detuvieron servicios.
- No se implementó ningún código del motor.
- No se hizo commit ni push.
- Ninguna prueba no ejecutada se marca como aprobada.
