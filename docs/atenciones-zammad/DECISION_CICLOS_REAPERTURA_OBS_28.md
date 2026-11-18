# DECISIÓN FORMAL — CICLOS 2..N EN REAPERTURAS (OBS-28 / REA-02)

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Épica:** EPIC-SLA-01
**Fecha de preparación:** 17/11/2026
**Naturaleza:** **propuesta de decisión. No aprobada.** Este documento no cambia el DDL, no cambia el estado de REA-02 y no autoriza implementación.
**Observación que resuelve:** OBS-28
**Decisiones afectadas:** REA-02, REA-03, REA-04, REA-05, REA-06

---

## 1. Qué se decide

Qué ocurre con el **plazo** de un ticket que se reabre, es decir, con los ciclos 2..N.

La decisión **no** es si el compromiso original cambia. Ese punto ya está resuelto en todas las fuentes: **el compromiso no cambia nunca**. Lo que se decide es si cada ciclo posterior recibe su propio vencimiento calculado sobre la política congelada.

---

## 2. Hechos documentales verificados

### 2.1 Lo que dice el EPIC (contrato de la épica)

| Regla | Texto | Línea |
|---|---|---:|
| BR-36 | Una reapertura es una transición desde `closed` hacia un estado que no es `closed` ni `merged`. Abre un **ciclo nuevo**. | 335 |
| BR-37 | El **ciclo 1** es la métrica oficial de resolución. Los ciclos 2..N son indicador operativo. | 336 |
| BR-38 | Cada ciclo nuevo usa la **misma política congelada**, con `due_at = opened_at + resolution_minutes`. | 337 |
| BR-39 | Una reapertura por fallo definitivo de envío se mide como reapertura real y se anota `reopen_hint = delivery_failure`. | 338 |
| BR-40 | Como máximo existe un ciclo `open` por compromiso. | 339 |

### 2.2 Lo que dicen las reglas de ciclos de 5G.4.5

`REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 (líneas 122-132) fija el efecto de una reapertura:

| Elemento | Efecto declarado |
|---|---|
| Ciclo N | Se cierra con su `closed_at` y su `outcome` |
| Ciclo N+1 | Se abre con `opened_at` = instante de la reapertura |
| `due_at` del ciclo N+1 | `opened_at + resolution_minutes` de la **misma** política congelada |
| **Compromiso** | **No cambia** |
| Política | **No cambia**, aunque la categoría se haya modificado |
| Primera respuesta | **No se recalcula** |
| Métrica oficial | **No cambia**: sigue siendo el ciclo 1 |

Y concluye, de forma literal: «**Alternativa A aprobada:** cada reapertura abre un ciclo nuevo con su propio plazo. Se descarta "congelar todo en el ciclo 1" porque un ticket reabierto y sin cerrar quedaría eternamente abierto y sin indicador.»

La justificación de §1 (línea 36) añade el criterio funcional: «Una reapertura es trabajo adicional, no un segundo compromiso con el mismo plazo. Mezclarlos permitiría "arreglar" un incumplimiento reabriendo y cerrando rápido.»

### 2.3 Lo que dice el resumen ejecutivo de 5G.4.5

`RESUMEN_EJECUTIVO_5G4_5.md` §3.1 (16/11/2026) lista, dentro de **Decisiones cerradas**:

| ID | Decisión | Resolución |
|---|---|---|
| REA-02 a REA-06 | Ciclos en reapertura | **Alternativa A: ciclo nuevo por reapertura** |

### 2.4 La contradicción real

| Fuente | Fecha | Estado de REA-02 |
|---|---|---|
| `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` líneas 61-66 | 5G.4.4 (anterior) | **PENDIENTE (crítica)** |
| `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2 | 16/11/2026 | **«Alternativa A aprobada»** |
| `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 | 16/11/2026 | **Cerrada** |

La contradicción es **cronológica**, no semántica: el documento que la declara pendiente pertenece a la etapa 5G.4.4; los dos documentos que la cierran pertenecen a 5G.4.5, que es la etapa de cierre funcional. Ninguna fuente posterior a 5G.4.5 la reabre.

**Conclusión documental:** REA-02..REA-06 están cerradas por la etapa 5G.4.5. El registro de 5G.4.4 quedó obsoleto y nunca se actualizó.

**Pero:** «cerrada por un documento de etapa» no es una firma del responsable funcional. Por eso esta decisión **no se declara aprobada aquí**. Lo que se pide en §8 es la ratificación que elimina la ambigüedad y actualiza el registro de 5G.4.4.

---

## 3. Las dos alternativas, con precisión técnica

### 3.1 Aclaración previa: «compromiso» no es «plazo»

La formulación habitual de las dos alternativas induce a error:

> «B: se registra el ciclo nuevo, pero no se asigna compromiso nuevo.»

Eso **también ocurre en A**. La tabla de §2.2 dice explícitamente que en A el compromiso **no cambia**. El compromiso es único por ticket (`sla_commitment.ticket_id` es único), se congela al clasificar y ninguna reapertura lo altera.

Por tanto, la alternativa real no es «compromiso nuevo sí/no», sino:

- **A:** ciclo nuevo **con plazo propio**.
- **B:** ciclo nuevo **sin plazo propio**.

Se documentan así para que la aprobación sea sobre una diferencia verificable.

### 3.2 Alternativa A — ciclo nuevo con plazo propio

| Aspecto | Detalle |
|---|---|
| Fila en `sla_cycle` | `cycle_number = N+1`, `opened_at` = instante de la reapertura |
| `due_at` | `opened_at + resolution_minutes` de la política congelada |
| `outcome` | `open` mientras no cierre; `met` o `missed` al cerrar |
| Compromiso | Sin cambios |
| ¿Cabe en el DDL actual? | **Sí, sin cambios.** Cumple `sla_cycle_open_needs_due_ck` y `sla_cycle_due_order_ck` |

### 3.3 Alternativa B — ciclo nuevo sin plazo propio

B admite dos lecturas. Ninguna es gratuita.

| Lectura | Cómo se implementaría | ¿Cabe en el DDL actual? |
|---|---|---|
| **B1. Heredar el vencimiento del ciclo 1** (`due_at` = `due_at` del ciclo 1) | Copiar el plazo original al ciclo nuevo | **No en general.** `sla_cycle_due_order_ck` exige `due_at >= opened_at`. Si la reapertura ocurre después del vencimiento original —el caso normal— el `CHECK` rechaza la fila. Solo funciona si se reabre antes de vencer, y en ese caso el ciclo nace condenado a incumplir |
| **B2. Ciclo sin vencimiento** (`due_at NULL`) | Dejar el plazo vacío | **No.** `sla_cycle_open_needs_due_ck` exige `due_at` cuando `outcome = 'open'` |

**Riesgo silencioso de B2 si se relajara la restricción:** las restricciones de resultado comparan `closed_at` con `due_at`. En SQL, `closed_at <= NULL` y `closed_at > NULL` evalúan a `NULL`, y un `CHECK` que evalúa a `NULL` **no falla**. Un ciclo cerrado sin plazo podría registrarse como `met` o `missed` sin que la base lo impida, y arrastraría un resultado sin referencia. Esto no es una opinión: es cómo se comporta `CHECK` con `NULL`.

**Conclusión:** B exige modificar el DDL en cualquiera de sus dos lecturas, y además abre un agujero de integridad que habría que tapar con restricciones adicionales.

---

## 4. Impacto comparado

| Dimensión | A — ciclo con plazo | B — ciclo sin plazo |
|---|---|---|
| **Métricas** | Ciclos 2..N medibles: `met`/`missed` con referencia temporal. El ciclo 1 sigue siendo el oficial (BR-37) | Sin plazo no hay `met`/`missed` posibles. Solo se puede contar «cuántas veces se reabrió», no «si se resolvió a tiempo» |
| **Alertas** | Se pueden emitir 75 %, 90 % y vencimiento por ciclo: `sla_alert` exige `due_at NOT NULL` y referencia `(commitment_id, cycle_number)` | **Imposible sin cambiar el esquema.** La alerta necesita un vencimiento para calcular sus umbrales; `sla_alert.due_at` es `NOT NULL` |
| **Vencimientos** | Uno por ciclo, derivado de la política congelada. Coherente con BR-38 | Ninguno, o el del ciclo 1 reutilizado (B1), que nace incumplido |
| **Dashboard** | «Ciclo N: vence el …». Permite separar ciclo 1 (oficial) de 2..N (operativo) | Solo «reabierto N veces». No hay semáforo posible por ciclo |
| **Auditoría** | `cycle.opened` y `cycle.closed` con plazo; el `outcome` es verificable contra `due_at` | Los eventos se registran igual, pero el cierre no tiene contra qué compararse. La auditoría conserva el hecho, no el resultado |
| **Compromiso original** | **Sin cambios.** Congelado, único por ticket, `first_response_due_at` y `resolution_due_at` intactos | **Sin cambios.** Idéntico: B no «protege» nada que A no proteja |

**Lectura del cuadro:** B no aporta ninguna ventaja sobre A en el compromiso original; su única diferencia es eliminar el plazo de los ciclos posteriores, y con él la métrica operativa, las alertas y la comparación de cierre.

---

## 5. Recomendación técnica

**Recomendación: A.**

Motivos, en orden de peso:

1. **Es la regla escrita.** BR-38 la define con fórmula exacta y 5G.4.5 la declara aprobada. B no aparece en ninguna fuente como alternativa aprobada.
2. **Es la única representable sin tocar el DDL.** A no requiere ningún cambio; B requiere relajar dos `CHECK` y añadir otros para evitar el agujero del `NULL`.
3. **Sostiene las alertas.** `sla_alert` está diseñada sobre un vencimiento por ciclo; sin plazo, la tabla no puede cumplir BR-54 para ciclos 2..N.
4. **Sostiene el indicador operativo de BR-37.** Sin plazo, «ciclos 2..N como indicador operativo» queda reducido a un contador de reaperturas.
5. **No debilita el compromiso.** En A el compromiso tampoco cambia, así que la objeción que suele justificar B no existe.

**Riesgo residual de A:** un ticket que se reabre muchas veces acumula ciclos y alertas. Mitigación propuesta: el tablero separa ciclo 1 (oficial) de 2..N (operativo), y el indicador operativo se publica desagregado por `reopen_hint` como ya prevé `REGLAS_DEFINITIVAS_CICLOS` §5. **No** se propone limitar las alertas por ciclo: eso sería una regla nueva y no aprobada.

---

## 6. Qué cambia exactamente si se aprueba A

| Elemento | Efecto |
|---|---|
| DDL | **Ninguno.** El diseño actual ya implementa A |
| Rollback | **Ninguno.** No depende de esta decisión |
| Script de verificación | **Ninguno.** Las restricciones verificadas son las mismas |
| Código | Ninguno todavía: el motor no está implementado |
| Documentos | `DECISIONES_PENDIENTES_EMAIL_5G4_4.md` debe actualizar REA-02..REA-06 de **PENDIENTE** a **VIGENTE (A)**, con la fecha y el firmante. Esa actualización requiere autorización: es un documento de decisión, no de seguimiento |
| Observaciones | OBS-28 pasa a **Cerrada** con evidencia de la firma |

## 7. Qué cambia si se aprueba B

| Elemento | Efecto |
|---|---|
| DDL | `sla_cycle_open_needs_due_ck` debe relajarse; `sla_cycle_due_order_ck` debe admitir `due_at` heredado; hay que añadir restricciones para que un ciclo cerrado sin plazo no pueda declararse `met` ni `missed` |
| `sla_alert` | Su `due_at NOT NULL` y sus umbrales quedan sin sentido para ciclos 2..N: habría que decidir si no se emiten alertas o si se emiten contra otro instante |
| Conteos del esquema | Cambian las restricciones verificadas y el script `001_verificacion_diseno_sla.sql` |
| Métrica oficial | Sin cambios (ciclo 1) |
| Documentos | BR-38 y `REGLAS_DEFINITIVAS_CICLOS` §4.2 deben corregirse: hoy declaran A como aprobada |

**Consecuencia de gobernanza:** aprobar B exige enmendar el EPIC y las reglas de ciclos. Aprobar A solo exige actualizar un registro de decisiones que quedó atrás.

---

## 8. Ficha de aprobación

| Campo | Valor |
|---|---|
| **Decisión solicitada** | Ratificar la alternativa A (ciclo nuevo con `due_at = opened_at + resolution_minutes`) y cerrar REA-02..REA-06 |
| **Propuesta** | A |
| **Responsable de aprobar** | Responsable funcional del motor SLA (negocio / Soporte) |
| **Corresponsable técnico** | Responsable técnico del BFF (confirma que A es la única representable sin cambios) |
| **Evidencia adjunta** | §2 de este documento; `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` §4.2; `RESUMEN_EJECUTIVO_5G4_5.md` §3.1 |
| **Efecto sobre el DDL** | Ninguno |
| **Efecto sobre la migración** | Ninguno: no es condición de BLK-05 ni de BLK-06 |
| **Condición que desbloquea** | Implementación de reaperturas y de alertas por ciclo (etapa posterior a la migración) |

| Aprobación | Nombre | Rol | Fecha | Firma |
|---|---|---|---|---|
| Alternativa A | | Responsable funcional | | |
| Conformidad técnica | | Responsable técnico | | |

**Estado:** preparada, **no firmada**. Mientras no haya firma, OBS-28 sigue **abierta** y la implementación de reaperturas sigue bloqueada.

---

## 9. Confirmación

- No se ejecutó SQL ni se conectó a PostgreSQL.
- No se modificó el DDL, el rollback, el script de verificación ni la matriz.
- No se modificó `DECISIONES_PENDIENTES_EMAIL_5G4_4.md`: su actualización se propone, no se ejecuta.
- No se implementó ningún código del motor.
- No se creó ni modificó ninguna base, rol, tabla, índice o restricción.
- No se tocó Zammad, sus tablas, sus workers ni sus credenciales.
- No se hizo commit ni push.
