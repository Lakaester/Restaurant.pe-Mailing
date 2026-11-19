# GitHub Actions en Restaurant.pe-Mailing

Auditoría de los workflows heredados de Zammad 7.2.3 y configuración aplicada
en el repositorio privado. Los archivos heredados **no se modifican** (para
mantener el núcleo idéntico al upstream); se controlan desde la configuración
de GitHub con `gh workflow disable|enable`.

## Inventario

| Workflow | Disparadores | Qué hace | Coste | Riesgo de acción no deseada | Decisión |
|---|---|---|---|---|---|
| `ci.yaml` (CI) | Cada PR; **cada viernes 06:00 UTC** (rama por defecto) | Contenedor `zammad-ci` + PostgreSQL + Redis; Brakeman, Rubocop, ESLint, Stylelint, type-check, `assets:precompile`, Vitest completo y RSpec | **Alto**: suite completa de Zammad (decenas de minutos por ejecución, minutos de pago en privado). Además es probable que falle sin relación con nuestro código: markdownlint recorre `**/*.md` (incluida la documentación propia) y la imagen `zammad-ci:latest` sigue a la versión en desarrollo, no a 7.2.3 | Bajo (no publica, no usa secretos) | **Deshabilitado.** Sustituido por `cose-ci.yml`. Rehabilitar puntualmente antes de una actualización de versión si se quiere la suite completa |
| `docker-ci.yaml` | Cada PR | Construye la imagen Docker completa y la prueba con `zammad/zammad-docker-compose` (descarga repositorio externo) | **Alto** (~20 min por PR) | Bajo (no hace push) | **Deshabilitado.** Útil solo cuando se prepare el despliegue con Docker |
| `docker-release.yaml` | Push a `stable`, **push de cualquier tag**, lunes a viernes 06:10 UTC | Construye y **publica** imágenes en Docker Hub, GHCR y Quay | Nulo aquí: los jobs tienen `if: github.repository == 'zammad/zammad'` y se omiten | **Alto si se copiara o renombrara el repo como `zammad/zammad`**: publicaría imágenes con secretos de registro. Hoy genera ejecuciones omitidas diarias (ruido) | **Deshabilitado.** Es exclusivo de la publicación oficial de Zammad |
| `packager.io.yaml` | Push a `stable*`/`develop-*`, lunes a viernes 06:20 UTC, manual | Construye paquetes .deb/.rpm para 10 distribuciones y los publica en packager.io | Nulo aquí (mismo `if`) | Alto en el mismo supuesto (publicación externa con `PACKAGER_PUBLISH_TOKEN`) | **Deshabilitado.** Exclusivo de Zammad oficial |
| `cose-ci.yml` (propio) | PR y push a `cose/**` que toquen rutas C.O.S.E.; manual | `pnpm install`, oxlint y Vitest del código C.O.S.E. | Bajo (~3-5 min) | Ninguno: `contents: read`, sin secretos, `persist-credentials: false` | **Activo** |

Otros archivos heredados sin efecto en GitHub: `.gitlab-ci.yml` y `.gitlab/`
(solo GitLab), `.github/ISSUE_TEMPLATE/config.yml` (enlaces a la comunidad de
Zammad; inocuo).

## Configuración del repositorio

- Actions habilitado (necesario para `cose-ci.yml`).
- Permisos por defecto de `GITHUB_TOKEN`: **solo lectura**; los workflows no
  pueden aprobar PRs.
- El primer push solo incluye las ramas `main` y `cose/personalizaciones`, que
  no coinciden con los filtros `stable*`, `develop-*` ni tags: ningún workflow
  heredado se dispara con la publicación. Los cuatro heredados se deshabilitan
  inmediatamente después del push (antes del primer cron).

```bash
R=Lakaester/Restaurant.pe-Mailing
gh workflow disable CI -R $R
gh workflow disable docker-ci -R $R
gh workflow disable docker-release -R $R
gh workflow disable packager.io -R $R
gh workflow list --all -R $R
```
