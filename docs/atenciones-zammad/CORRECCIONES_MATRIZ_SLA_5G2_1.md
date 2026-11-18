# CORRECCIONES A LA MATRIZ SLA 5G.2.1

**Proyecto:** MAILING — Zammad 7.2.3 / C.O.S.E.
**Etapa:** 5G.3
**Fecha:** 16/11/2026
**Modo:** corrección documental. **No se sobrescribió la matriz original.**

---

## 1. Motivo

El resumen de `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` indica:

- WhatsApp: 37 combinaciones con SLA.
- Correo: 28 combinaciones con SLA.

El conteo directo de filas de la matriz da un resultado distinto. Esta corrección documenta el conteo real sin modificar el documento original.

---

## 2. Conteo real de filas

| Canal | Filas | Sin SLA | Con SLA |
|---|---:|---:|---:|
| WhatsApp | **40** | **2** | **38** |
| Correo | **30** | **3** | **27** |
| **Total** | **70** | **5** | **65** |

### 2.1 WhatsApp

- 40 filas.
- 2 sin SLA:
  - `DEVOLUCIÓN / Solicitud de devolución` (n=8).
  - `FACTURACIÓN / Activación NV` (n=9).
- 38 con SLA.

### 2.2 Correo

- 30 filas.
- 3 sin SLA:
  - `FACTURACIÓN / Error FE por duplicidad` (n=9).
  - `INTEGRACIONES / Integración sistemas contables` (n=9).
  - `INTEGRACIONES / Error integración` (n=4).
- 27 con SLA.

### 2.3 Total

- 70 filas.
- 5 sin SLA.
- 65 con SLA.

---

## 3. Qué se mantiene

- El total de **65 combinaciones con SLA** es correcto.
- El total de **5 combinaciones sin SLA** es correcto.
- La ventana 01/04/2026–31/10/2026 es correcta.
- La metodología P75 + escalera es correcta.
- Los valores por fila no se modifican.
- La matriz original no se sobrescribe.

---

## 4. Qué se corrige

Solo la distribución por canal en el resumen:

| Dato | Documento original | Corrección |
|---|---|---|
| WhatsApp con SLA | 37 | **38** |
| Correo con SLA | 28 | **27** |
| WhatsApp sin SLA | 2 | 2 |
| Correo sin SLA | 3 | 3 |
| Total con SLA | 65 | 65 |
| Total sin SLA | 5 | 5 |

---

## 5. Impacto

- No cambia ningún valor de SLA.
- No cambia la cobertura total.
- No cambia el cumplimiento histórico agregado.
- Cambia la lectura por canal: WhatsApp tiene una combinación más y correo una menos.

---

## 6. Recomendación

1. Mantener la matriz original sin cambios.
2. Usar esta corrección como anexo oficial.
3. En la próxima versión de la matriz, corregir el resumen en el documento principal.
4. No recalcular los valores.

---

## 7. Confirmación

No se modificó `MATRIZ_FINAL_PROPUESTA_SLA_RESOLUCION.md` ni ningún otro documento previo. Solo se creó este anexo.
