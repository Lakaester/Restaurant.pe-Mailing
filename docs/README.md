# MAILING — Documentación del proyecto

Documentación propia de Mailing. No forma parte del código de Zammad.

## Contenido

- `docs/decisiones.md` — Decisiones tomadas y su justificación.
- `docs/entorno-local.md` — Cómo se ejecutará Mailing en el equipo de desarrollo.
- `docs/verificacion-fase-1.md` — Resultado de la verificación del código base.

## Origen del código

| Dato | Valor |
|---|---|
| Producto base | Zammad |
| Versión | 7.2.3 |
| Tag oficial | `7.2.3` (commit `d3f316a`) |
| Fuente | https://github.com/zammad/zammad |
| Licencia | AGPL-3.0 |

La copia de `C:\dev\mailing` es idéntica al archivo oficial del tag `7.2.3`.
Ver `docs/verificacion-fase-1.md` para el detalle de la comprobación.

## Reglas del proyecto

1. El núcleo de Zammad no se modifica; las personalizaciones van en `addons/`.
2. Las actualizaciones se hacen desde etiquetas oficiales, nunca desde `develop`
   ni desde `latest`.
3. No se suben secretos ni credenciales al repositorio.
4. Mailing es de uso interno de Restaurant.pe.
