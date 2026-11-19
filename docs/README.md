# MAILING — Documentación del proyecto

Documentación propia de Mailing. No forma parte del código de Zammad.

## Contenido

| Documento | Propósito |
|---|---|
| [`decisiones.md`](decisiones.md) | Decisiones tomadas y su justificación |
| [`UPSTREAM.md`](UPSTREAM.md) | Relación con Zammad oficial, parches sobre el núcleo y procedimiento de actualización |
| [`AUDITORIA_PUBLICACION_GITHUB.md`](AUDITORIA_PUBLICACION_GITHUB.md) | Auditoría de seguridad previa a la publicación en GitHub |
| [`GITHUB_ACTIONS.md`](GITHUB_ACTIONS.md) | Auditoría de workflows heredados y CI propia |
| [`verificacion-fase-1.md`](verificacion-fase-1.md) | Verificación byte a byte del código base |
| [`atenciones-zammad/`](atenciones-zammad/) | Diseño, decisiones, matrices y SQL del módulo de Atenciones y del motor SLA de C.O.S.E. |

Puntos de entrada recomendados en `atenciones-zammad/`:

- `ENTREGA_ATENCIONES_COSE_ZAMMAD.md` — qué se entregó en la vista de Atenciones.
- `INFORME_FINAL_EPIC_SLA_01.md` — estado del épico SLA.
- `ARQUITECTURA_FINAL_MOTOR_SLA.md` y `CONTRATOS_API_SLA.md` — diseño vigente del motor SLA.
- `GUIA_OPERACION_SLA.md` y `GUIA_PRUEBAS_SLA.md` — operación y pruebas.
- `sql/` — esquema, verificación y rollback del motor SLA (no aplicado en producción).

Las capturas de evidencia (`atenciones-zammad/evidencias/`) contienen datos
reales y se conservan solo en local.

## Origen del código

| Dato | Valor |
|---|---|
| Producto base | Zammad |
| Versión | 7.2.3 |
| Tag oficial | `7.2.3` (commit `d3f316a`) |
| Fuente | https://github.com/zammad/zammad |
| Licencia | AGPL-3.0 |

La rama `main` es idéntica al tag oficial `7.2.3` salvo los archivos propios de
documentación (ver `UPSTREAM.md`). El detalle de la verificación original está
en `verificacion-fase-1.md`.

## Reglas del proyecto

1. El núcleo de Zammad no se modifica; las personalizaciones van en `addons/`.
2. Las actualizaciones se hacen desde etiquetas oficiales, nunca desde `develop`
   ni desde `latest`.
3. No se suben secretos ni credenciales al repositorio.
4. Mailing es de uso interno de Restaurant.pe.
