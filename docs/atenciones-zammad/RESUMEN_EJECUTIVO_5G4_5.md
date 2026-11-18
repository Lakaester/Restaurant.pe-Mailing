# RESUMEN EJECUTIVO — CIERRE FUNCIONAL DEL MOTOR SLA EMAIL — 5G.4.5

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.4.5 — Cierre funcional y validación final
**Fecha:** 16/11/2026
**Modo:** PLAN, solo lectura.
**Resultado:** matriz validada, volumen fuera de catálogo medido, decisiones cerradas y especificación definitiva lista. **Cero cambios técnicos.**

---

## 1. Matriz validada

Se reconstruyó la matriz oficial contra la base COSE, fila por fila.

| Verificación | Resultado |
|---|---|
| Filas de la matriz | **30** |
| Filas que coinciden exactamente con la medición | **30 / 30** |
| Suma de N | **2.109** (igual al publicado) |
| Con SLA | **27** · 2.087 tickets |
| Sin evidencia suficiente | **3** · 22 tickets |
| P75 y escalón coherentes | **27 / 27** |
| Valores recalculados | **Ninguno** |

Las tres combinaciones sin SLA siguen siendo:

| Categoría | Subcategoría | n |
|---|---|---:|
| FACTURACION ELECTRONICA | Error FE por duplicidad | 9 |
| INTEGRACIONES | Solicitud de integracion sistemas contables | 9 |
| INTEGRACIONES | Error integracion | 4 |

**No hubo ninguna inconsistencia demostrable.** No se modificó ningún valor.

**Cobertura:**

| Cobertura | Valor |
|---|---:|
| Interna de la matriz (2.087 / 2.109) | **98,96 %** |
| Sobre el universo de servicio (2.109 / 3.125) | **67,49 %** |
| Fuera de la matriz (1.016 / 3.125) | **32,51 %** |

---

## 2. Volumen Email fuera de catálogo

**Medido directamente. DP-E-08 cerrada.**

| Concepto | Tickets |
|---|---:|
| Email en la ventana, todos los estados | 4.834 |
| Cerrados/resueltos con resolución > 0 | 4.713 |
| Con categoría de servicio | **3.125** |
| Con combinación en la matriz oficial | **2.109** |
| **Fuera de la matriz oficial** | **1.016 (32,51 %)** |

### Distribución por categoría

| Categoría | Tickets | % |
|---|---:|---:|
| GESTION | 404 | 39,76 % |
| FACTURACION ELECTRONICA | 284 | 27,95 % |
| ADMINISTRATIVO | 188 | 18,50 % |
| SOFTWARE | 131 | 12,89 % |
| INTEGRACIONES | 9 | 0,89 % |

### Concentración

Cinco rótulos explican el 75,5 % del volumen sin política:

| Rótulo | Tickets |
|---|---:|
| consultas generales | 283 |
| consultas fe | 159 |
| comunicacion de baja | 134 |
| seguimiento de cdt certificado | 97 |
| mejoras personalizadas | 94 |

### Reconciliación

`3.125 + 12.466 = 15.591` · `2.109 + 8.641 = 10.750` · `1.016 + 3.825 = 4.841` ✓

Los tres totales documentados de ambos canales cierran exactamente. El 32,51 % de Email es la porción correcta del 31,1 % histórico.

**Consecuencia que debe asumirse:** el respaldo de 36 h gobernaría **1 de cada 3 tickets clasificados**. No es un caso marginal.

---

## 3. Decisiones

### 3.1 Cerradas

| ID | Decisión | Resolución |
|---|---|---|
| DP-E-01 | Matriz oficial | **Validada 30/30** |
| DP-E-02 | Respaldo 36 h solo para fuera de catálogo | Cerrada |
| DP-E-03 | Cadencia 5 min + banda 2 min | Cerrada |
| DP-E-04 | Primera respuesta | **Estrictamente `< 24 h`** |
| DP-E-05 | `merged` | No cierra; se excluye con divergencia |
| DP-E-06 | `fail` definitivo | Solo con `delivery_retry > 3` |
| DP-E-07 | 3 combinaciones sin evidencia | Sin SLA; excluidas; revisión a 90 días |
| DP-E-08 | Medir fuera de catálogo | **1.016 (32,51 %)** |
| DP-E-09 | Nivel de reporte | Global + categoría + subcategoría + política |
| DP-E-10 | Columna `channel` | Se mantiene con `CHECK ('email')` |
| DP-E-11 | Clasificación tardía | `started_at = created_at`; indicador separado |
| DP-E-12 | Cuerpos de correo | No se almacenan |
| REA-02 a REA-06 | Ciclos en reapertura | Alternativa A: ciclo nuevo por reapertura |
| DP-02 | Alternativa A | Cerrada |
| DP-07 | Persistencia | Cerrada en diseño; falta aprobación de infraestructura |
| DP-08 / DP-10 | Retención y motivo obligatorio | Cerradas |

### 3.2 Abierta

| ID | Decisión | Tipo | Impacto |
|---|---|---|---|
| **DP-04** | Responsable administrativo del catálogo | Organizativa | Alto: decide si el 32,51 % deja de depender del respaldo |

**Es la única decisión funcional que queda abierta.** No se puede cerrar con análisis: requiere que la organización designe a una persona y un proceso de actualización del catálogo.

---

## 4. Especificación definitiva

### 4.1 Reglas

| Regla | Definición |
|---|---|
| Calendario | 24/7, sin pausas |
| Inicio | `created_at` |
| Primera respuesta | Primer artículo público de agente, tipo `email`, con `delivery_status = success`, medido por `delivery_status_date` |
| Borde de primera respuesta | `< 86.400 s` (estricto) |
| Resolución | Primer estado de tipo `closed`; borde `≤` |
| Reapertura | Abre ciclo N; solo el ciclo 1 es oficial |
| `pending close` | No pausa ni cierra |
| `merged` | No cierra; se excluye |
| Eliminados | Se excluyen; los datos se conservan |
| Congelamiento | Al clasificar; nada posterior altera el snapshot |
| Reclasificación | Se registra; no cambia el compromiso |
| Meta | **≥ 80 %** |

### 4.2 Arquitectura

| Componente | Definición |
|---|---|
| Fuente | API REST de Zammad, solo lectura |
| Detección de envío | Sondeo por `updated_at` (los webhooks no ven artículos) |
| Cadencia | 5 min; 2 min para vencimientos < 4 h |
| Reconciliación | Incremental 15 min; diaria; semanal de integridad |
| Tablas | **9**, con 3 columnas de WhatsApp eliminadas |
| Eventos | 15 tipos; 2 de WhatsApp eliminados |
| Seguridad | Usuario técnico con acceso `read`; escritura bloqueada por Pundit |
| Datos personales | No se almacena ningún cuerpo ni dirección |
| Alertas | 75 %, 90 % y vencimiento |

### 4.3 Hallazgos que cambian el diseño

1. **Clasificación:** en 10 de 30 filas la categoría oficial difiere de la categoría COSE. El motor **debe** clasificar con la matriz, no con `v_unificado_norm.categoria`. Si no, los reportes por categoría no cuadrarán.
2. **Confirmación de envío:** el `after_commit :ticket_touch` del artículo garantiza que `delivery_status` eleva `ticket.updated_at`. La detección por sondeo tiene base en código, no solo inferencia.
3. **Solo lectura demostrable:** `groups_users.access = 'read'` + políticas de Pundit permiten probar que la integración **no puede** escribir. No es una convención: es una restricción verificable.
4. **Reapertura automática:** un fallo definitivo de envío reabre el ticket y crea una nota interna. El motor debe tratarlo como reapertura real.
5. **`merged` no cierra:** sin regla explícita, esos tickets quedarían abiertos para siempre.

---

## 5. Riesgos restantes

| ID | Riesgo | Nivel | Estado |
|---|---|---|---|
| R-01 | `success` se lee como "entregado" | Alto | Mitigado con nota obligatoria |
| R-05 | Categoría COSE ≠ categoría oficial (10 filas) | Alto | Mitigado con regla de clasificación |
| R-06 | 32,51 % fuera de catálogo con respaldo 36 h | Alto | **Medido**; mitigación real requiere DP-04 |
| R-11 | Rebote asíncrono no reflejado | Medio | Límite del canal; documentado |
| R-03 | Reaperturas por fallo de correo | Medio | `reopen_hint` y desagregación |
| R-04 | `pending close` vence sin acción | Medio | Alertas 75/90 % |
| R-08 | Clasificación tardía | Medio | Indicador separado |
| R-10 | Paginación por desplazamiento | Medio | Orden estable + solape |
| R-02 | Fallo transitorio tratado como definitivo | Medio | Solo tras 3 reintentos |
| R-07 | 3 combinaciones sin SLA | Medio | Excluidas con motivo |
| R-09 | La confirmación no eleva `updated_at` | Bajo | Garantizado por código; F0-06 lo confirma |

**Riesgo principal del proyecto:** el respaldo de 36 h sobre un tercio del volumen. Mientras el catálogo no se actualice, la métrica de resolución será, en buena parte, la métrica del respaldo.

---

## 6. Fase 0

**17 pruebas, 4 ya ejecutadas** (las de solo lectura: línea base, matriz, fuera de catálogo, mapeo de categorías). **13 pendientes** de autorización.

Las tres pruebas críticas:

| Prueba | Qué demuestra |
|---|---|
| F0-03 | 11 intentos de escritura rechazados con 403 |
| F0-06 | La confirmación de envío eleva `ticket.updated_at` |
| F0-07 | `close_at` es el primer cierre y no se reescribe |

**Ninguna fase posterior se autoriza si falla una prueba bloqueante.**

---

## 7. Documentos de esta etapa

| # | Documento | Contenido |
|---:|---|---|
| 1 | `VALIDACION_MATRIZ_Y_COBERTURA_EMAIL_5G4_5.md` | Matriz 30/30, cobertura, 1.016 fuera de catálogo |
| 2 | `REGLAS_DEFINITIVAS_PRIMERA_RESPUESTA_EMAIL_5G4_5.md` | Regla `< 24 h`, candidatos, fallidos, casos límite |
| 3 | `REGLAS_DEFINITIVAS_CICLOS_EMAIL_5G4_5.md` | Ciclos, reaperturas, `merged`, eliminados, tardía |
| 4 | `ESPECIFICACION_FINAL_MOTOR_SLA_EMAIL_5G4_5.md` | Fuentes, eventos, 9 tablas, índices, cálculo, sondeo, alertas |
| 5 | `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md` | 17 pruebas con evidencia exigida |
| 6 | `RESUMEN_EJECUTIVO_5G4_5.md` | Este documento |

**Ningún documento anterior fue sobrescrito.** La carpeta pasa de 53 a 59 archivos.

---

## 8. Próximos pasos

| Orden | Acción | Responsable |
|---:|---|---|
| 1 | Aprobar los seis documentos de 5G.4.5 | Negocio |
| 2 | **Cerrar DP-04:** designar dueño y proceso del catálogo | Dirección |
| 3 | Autorizar la fase 0 y crear el usuario técnico de solo lectura | TI |
| 4 | Ejecutar F0-01 a F0-16 | TI + negocio |
| 5 | Revisar el catálogo para incorporar los 5 rótulos de mayor volumen | Dueño del catálogo |

**Recomendación:** no iniciar la fase 1 sin haber cerrado DP-04. Construir el motor sobre un catálogo que deja un tercio del volumen en un respaldo genérico produce una métrica que mide el respaldo, no la operación.

---

## 9. Confirmación de ausencia de modificaciones técnicas

| Restricción | Cumplimiento |
|---|---|
| No modificar código | **Cumplido** |
| No modificar base de datos | **Cumplido** (solo `SELECT`) |
| No modificar configuración de Zammad | **Cumplido** |
| No modificar calendarios | **Cumplido** (siguen 2) |
| No crear ni modificar SLA nativos | **Cumplido** (siguen 0) |
| No modificar triggers | **Cumplido** (siguen 3, 0 activos) |
| No modificar webhooks | **Cumplido** (siguen 0) |
| No modificar usuarios ni permisos | **Cumplido** (siguen 6) |
| No modificar buzones | **Cumplido** |
| No crear credenciales | **Cumplido** |
| No iniciar workers ni servicios | **Cumplido** (worker detenido) |
| No modificar Zendesk | **Cumplido** |
| No modificar COSE | **Cumplido** (solo lectura) |
| No sobrescribir documentos anteriores | **Cumplido** (53 previos intactos) |

Las únicas escrituras fueron los seis documentos nuevos de esta etapa.

---

## 10. Conclusión

El diseño del motor SLA Email queda **cerrado funcionalmente**:

- la matriz está validada sin recálculo;
- el volumen fuera de catálogo está medido;
- las reglas de primera respuesta y de ciclos son inequívocas;
- la especificación cubre fuentes, eventos, tablas, índices, cálculo, sondeo, alertas, auditoría, reconciliación, reportes y aceptación;
- queda **una** decisión abierta, organizativa.

Lo que falta no es diseño: es autorización.
