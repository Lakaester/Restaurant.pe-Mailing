# ACTA DE ENTREGA Y CIERRE DEL HITO DE ANÁLISIS Y DISEÑO
## EPIC-SLA-01 — Implementación del motor SLA para C.O.S.E. sobre Zammad

**Proyecto:** MAILING / Zammad — C.O.S.E.  
**Organización:** Restaurant.pe  
**Hito:** Análisis, diseño funcional, diseño técnico y planificación de implementación  
**Estado del hito:** Entregable documental para revisión y aceptación  
**Fecha:** Pendiente de registro formal  
**Responsable de aceptación:** Pendiente de designación formal

---

## 1. Objetivo del acta

Dejar constancia de la entrega del trabajo de análisis, definición funcional, evaluación técnica y planificación del proyecto EPIC-SLA-01, orientado a implementar un motor propio de acuerdos de nivel de servicio (SLA) para la atención por correo electrónico gestionada mediante Zammad e integrada posteriormente con C.O.S.E.

Esta acta delimita expresamente el alcance entregado y diferencia los resultados documentales de las actividades de implementación, pruebas y puesta en producción que todavía requieren autorización y ejecución.

## 2. Alcance del hito entregado

El hito comprende:

- Análisis del funcionamiento actual de Zammad y su relación con C.O.S.E.
- Definición del alcance funcional del servicio de correo electrónico.
- Análisis de datos históricos y criterios estadísticos para establecer los compromisos SLA.
- Definición de reglas de negocio y criterios de medición.
- Evaluación de las capacidades y limitaciones técnicas de Zammad.
- Diseño de la arquitectura propuesta para el motor SLA y su integración mediante BFF.
- Identificación de riesgos, bloqueantes, dependencias y controles de seguridad.
- Elaboración del plan de implementación, historias de usuario y criterios de aceptación.
- Preparación del paquete documental para solicitar autorización de la Fase 0.

**Fuera del alcance de este cierre:** implementación del motor SLA, modificaciones funcionales en Zammad, cambios en el BFF o frontend de C.O.S.E., ejecución integral de pruebas, integración con el buzón definitivo y despliegue productivo.

## 3. Definiciones funcionales consolidadas

### 3.1. Alcance del servicio

Zammad se utilizará exclusivamente para gestionar la atención por correo electrónico.

Los canales WhatsApp, WHATMETA, WHATICKET y otros canales de mensajería quedan fuera del alcance del motor SLA definido en este hito.

La atención por correo electrónico utilizará una bandeja única. La clasificación de categoría y subcategoría será realizada manualmente por el asesor.

### 3.2. Primera respuesta

- Compromiso: menor a 24 horas.
- Se considera primera respuesta el primer artículo público de agente, de tipo `email`, con `delivery_status=success` y `created_at >= ticket.created_at`.
- La aceptación exitosa del servidor SMTP no equivale a confirmar la entrega del mensaje en el buzón del destinatario.

### 3.3. Resolución

- Los compromisos se diferencian por categoría y subcategoría.
- El criterio estadístico principal seleccionado es el percentil 75 (P75).
- Los valores se redondean al primer escalón operativo igual o superior al P75.
- El calendario de medición es 24/7, sin pausas por noches, fines de semana, feriados o espera de terceros.
- El cierre se considera en el primer estado `closed`.
- `pending close` no detiene el SLA.
- Las reaperturas generan un nuevo ciclo de atención; el ciclo 1 constituye la métrica oficial definida.

### 3.4. Clasificación y asignación del compromiso

- Antes de clasificar, el ticket permanece en estado visual `pending_classification`.
- El compromiso SLA se asigna al momento de la clasificación.
- Una vez asignado, el compromiso queda congelado.
- Las reclasificaciones posteriores deben quedar registradas sin modificar retroactivamente el compromiso original.
- La clasificación y su validación corresponden al BFF como fuente de verdad; Zammad podrá conservar un espejo opcional con control de divergencias.

## 4. Resultado del análisis de la matriz SLA

La matriz inicial de correo electrónico contiene 30 combinaciones de categoría y subcategoría:

- 27 combinaciones cuentan con evidencia suficiente para establecer un compromiso SLA.
- 3 combinaciones quedan sin compromiso por falta de evidencia estadística suficiente.
- La matriz cubre 2.087 tickets de una base de 2.109 tickets homologados.

Las tres combinaciones sin evidencia suficiente son:

- FE / Error FE por duplicidad.
- INTEGRACIONES / Solicitud de integracion sistemas contables.
- INTEGRACIONES / Error integracion.

Se identificaron además 35 subcategorías fuera de la matriz:

- 28 corresponden a servicios y tienen un fallback provisional de 36 horas.
- 7 corresponden a casos no considerados servicios y, por decisión confirmada DEC-05, quedan excluidos del motor SLA, sin compromiso SLA y sin fallback de 36 horas.

La cobertura de 2.087 sobre 2.109 representa cobertura interna de las combinaciones homologadas. No debe interpretarse como cobertura global de todos los tickets de correo electrónico.

## 5. Arquitectura técnica propuesta

El diseño establece los siguientes principios:

1. El motor SLA será propio y residirá en el BFF.
2. No se utilizarán las políticas SLA nativas de Zammad como fuente de verdad.
3. El BFF será responsable de validar la clasificación, asignar compromisos, calcular vencimientos y mantener la trazabilidad.
4. Zammad será el sistema de gestión de conversaciones y artículos de correo.
5. C.O.S.E. será la interfaz de operación y consulta de los tickets.
6. La comunicación entre C.O.S.E. y Zammad se realizará mediante una capa de integración controlada.
7. La sincronización y medición deberán contemplar paginación, solapamiento de consultas, confirmación de envío, cierres y reaperturas.
8. La integración con el buzón definitivo se realizará únicamente durante una transición expresamente autorizada.

La arquitectura busca mantener separadas la conversación, gestionada por Zammad, y la operación, gestionada por C.O.S.E. y el BFF.

## 6. Seguridad y controles identificados

Durante el análisis se identificaron riesgos que deberán resolverse antes de avanzar a una implementación segura:

- Credenciales OAuth del canal de correo almacenadas en opciones de canal.
- Tokens API almacenados sin hash.
- Backups que pueden contener secretos en texto plano.
- Necesidad de una identidad técnica con permisos mínimos.
- Necesidad de separar los entornos de prueba y las credenciales de cada entorno.
- Necesidad de un control de salida SMTP para pruebas que puedan generar correos.
- Necesidad de verificar permisos mediante pruebas negativas y evidencias observables.
- Necesidad de establecer una ventana exclusiva de pruebas para evitar interferencias con sesiones concurrentes.

Estos puntos no se consideran resueltos por la elaboración del diseño. Su tratamiento forma parte de las condiciones previas a la ejecución técnica.

## 7. Estado de la Fase 0

El paquete de autorización de Fase 0, versión 1.3, contempla 17 pruebas lógicas.

Estado documentado:

| Estado | Cantidad |
|---|---:|
| `passed` | 3 |
| `pending` | 7 |
| `blocked` | 3 |
| `deferred` | 4 |
| **Total** | **17** |

Adicionalmente, existe evidencia de lectura de apertura de F0-01. Esta evidencia no representa el cierre completo de dicha prueba.

Las tres pruebas bloqueadas son:

- F0-03: bloqueada hasta disponer de una instancia aislada y desechable, con base de datos independiente y credencial propia creada en esa instancia.
- F0-06: requiere una barrera técnica de salida SMTP en el entorno piloto.
- F0-15: requiere una ventana exclusiva y evidencia suficiente de ausencia de actividad concurrente.

**Aclaración de conteos:** la evidencia de apertura de F0-01 y su estado `pending` corresponden a dos vistas del mismo control, no a dos pruebas diferentes. Por ello, los conteos de evidencia y estados no deben sumarse como si fueran categorías independientes.

**Observación de la fuente:** el paquete v1.3 marca F0-03 y F0-15 como `blocked` en la tabla de §2, mientras que su nota indica `Pendiente`. Esta acta adopta el estado `blocked` de la tabla y mantiene la observación sin modificar el paquete.

Los documentos históricos 5G.4.5 registran cuatro pruebas con evidencia de ejecución y trece pendientes. El paquete v1.3 refina la interpretación de esos resultados, diferenciando las tres pruebas `passed` de la evidencia parcial de apertura de F0-01. Para el estado operativo consolidado de Fase 0 se utiliza el paquete v1.3, manteniendo la trazabilidad con los documentos históricos.

**Conclusión:** la Fase 0 no está concluida ni autorizada para ejecución integral. Los resultados parciales no habilitan por sí solos el inicio de la implementación.

## 8. Documentación entregada

El trabajo se encuentra organizado en `docs/atenciones-zammad/`. El inventario anterior tenía 63 documentos; con esta acta, la carpeta contiene 64 documentos.

Entre los documentos principales se encuentran:

- `EPIC_IMPLEMENTACION_SLA_COSE.md`: alcance general, etapas, historias de usuario, reglas de negocio y criterios de aceptación.
- `TABLERO_EJECUCION_ETAPA_1_SLA.md`: seguimiento de la etapa de preparación.
- `ANALISIS_BLOQUEANTES_ETAPA_1_1_SLA.md`: análisis de bloqueantes y decisiones pendientes.
- `PAQUETE_AUTORIZACION_FASE_0_SLA.md`: inventario de pruebas, condiciones, bloqueantes y autorizaciones.
- `CRITERIOS_ACEPTACION_FASE_0_SLA_EMAIL_5G4_5.md`: criterios de aceptación y evidencia histórica.
- `RESUMEN_EJECUTIVO_5G4_5.md`: resumen de resultados del análisis de datos.

El inventario y las versiones deben conservarse como referencia documental para la siguiente etapa.

## 9. Estado técnico del entorno al cierre

El entorno local de Zammad se encuentra instalado y funcional para pruebas de desarrollo con un correo piloto.

Se han realizado pruebas satisfactorias de recepción, respuesta y seguimiento en el piloto funcional local, según el historial de trabajo documentado. Estas pruebas no constituyen evidencia de ejecución de las pruebas F0.

Sin embargo:

- El buzón definitivo de Soporte Especializado no ha sido transferido a Zammad.
- No se ha autorizado la transición desde Zendesk.
- No se ha implementado el motor SLA.
- No se ha integrado el motor con C.O.S.E.
- No se ha autorizado una modificación de la infraestructura productiva.
- No se ha conectado el entorno local a la base de datos empresarial de Restaurant.pe.

El cierre documental no debe interpretarse como autorización para realizar estas acciones.

## 10. Riesgos y pendientes para la siguiente etapa

Antes de iniciar la ejecución técnica se requiere:

1. Resolver las condiciones de seguridad y gestión de secretos.
2. Preparar y verificar una instancia aislada para las pruebas que lo requieren.
3. Definir y verificar las credenciales técnicas de cada entorno.
4. Establecer una ventana exclusiva de pruebas.
5. Implementar la barrera técnica de salida SMTP para las pruebas de correo.
6. Definir los mecanismos de respaldo y rollback.
7. Completar las condiciones pendientes de Fase 0.
8. Obtener autorización expresa para ejecutar las pruebas.
9. Completar la validación técnica antes de iniciar cambios en el frontend de C.O.S.E.

Las decisiones funcionales confirmadas durante el análisis deberán mantenerse como referencia y no modificarse sin una revisión formal de impacto.

## 11. Declaración de cierre del hito

Se deja constancia de que el trabajo de análisis, diseño funcional, diseño técnico y planificación de EPIC-SLA-01 cuenta con una base documental consolidada para su revisión y aceptación.

El resultado entregado permite disponer de:

- Un alcance funcional delimitado.
- Reglas de negocio documentadas.
- Criterios estadísticos para la asignación de compromisos.
- Una arquitectura técnica propuesta.
- Un inventario de riesgos y bloqueantes.
- Un plan de implementación por etapas.
- Historias de usuario y criterios de aceptación.
- Un paquete de autorización para la Fase 0.

Por tanto, se propone dar por concluido el **hito de análisis y diseño**, sujeto a la revisión y aceptación formal de los responsables correspondientes.

Este cierre no declara finalizada la implementación del motor SLA, la integración con C.O.S.E., las pruebas funcionales integrales ni la puesta en producción. Estas actividades permanecen pendientes de ejecución y autorización.

## 12. Aceptación

| Rol | Responsable | Estado |
|---|---|---|
| Responsable del proyecto | Pendiente de designación formal | Pendiente |
| Responsable funcional | Pendiente de designación formal | Pendiente |
| Responsable técnico | Pendiente de designación formal | Pendiente |
| Aprobación de entrega | Pendiente | Pendiente |

**Resultado propuesto:** Entrega documental del hito de análisis y diseño de EPIC-SLA-01, con implementación y Fase 0 pendientes.
