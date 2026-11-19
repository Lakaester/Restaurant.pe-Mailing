# Relación con Zammad oficial (upstream)

## Origen

| Dato | Valor |
|---|---|
| Proyecto | [zammad/zammad](https://github.com/zammad/zammad) |
| Versión base | **7.2.3** |
| Tag oficial | `7.2.3` → commit `d3f316a4002e123dfb0a7b71712d23434c073178` |
| Licencia | GNU AGPL-3.0 |
| Remoto local | `upstream` → `https://github.com/zammad/zammad.git` (solo lectura, sin tags automáticos) |
| Referencia local del tag | `refs/upstream-tags/7.2.3` |

El historial de este repositorio **no** desciende del historial de Zammad: el
commit `8278e264` ("Base Zammad 7.2.3 sin cambios") es una importación del
archivo ZIP del tag. Por eso las comparaciones se hacen por árbol, no por
ancestro común.

## Verificación (19/11/2026)

Comparación de árboles Git contra el tag oficial descargado del upstream:

| Commit | Diferencias con `7.2.3` | Motivo |
|---|---|---|
| `8278e264` Base | 217 archivos | 209 permisos de ejecución perdidos en Windows, 4 enlaces simbólicos convertidos en archivos, 4 docs propios |
| `80e0f313` Permisos | — | Restaura bits de ejecución |
| `f8bbeada` Enlaces | **5 archivos**, todos propios | `.gitignore` (sección `MAILING`), `addons/README.md`, `docs/README.md`, `docs/decisiones.md`, `docs/verificacion-fase-1.md` |

Conclusión: tras las dos correcciones, `main` es Zammad 7.2.3 oficial más
documentación propia. Todo cambio funcional está en `cose/personalizaciones`.

Para repetir la verificación:

```bash
git fetch --depth 1 upstream refs/tags/7.2.3:refs/upstream-tags/7.2.3
git diff --stat refs/upstream-tags/7.2.3 main
git diff --name-status refs/upstream-tags/7.2.3 cose/personalizaciones -- app public
```

## Inventario de personalizaciones

### Archivos nuevos (no colisionan con el núcleo)

- `app/frontend/apps/desktop/components/layout/cose/CoseHeader.vue`
- `app/frontend/apps/desktop/pages/cose-atenciones/**` (vista, composable,
  catálogo, servicios y pruebas)
- `app/frontend/apps/desktop/pages/cose-sla/**`
- `app/frontend/apps/{desktop,mobile}/styles/custom/99-cose-theme.css`
- `app/assets/stylesheets/custom/99-cose-theme.css`
- `public/cose/logo-icono.png`, `public/cose/logo-principal.png`
- `public/assets/fonts/montserrat-latin.woff2`, `montserrat-latin-ext.woff2`
  (Montserrat, SIL Open Font License 1.1)

### Extensiones del núcleo mediante addon weave (sin parches)

Desde el 19/11/2026 **no hay archivos del núcleo modificados**: `git diff
refs/upstream-tags/7.2.3 -- app public` solo muestra archivos añadidos.

Los dos antiguos parches del layout se aplican en tiempo de compilación con la
capa oficial de extensión de Zammad (`app/frontend/build/addonWeave`), desde el
manifiesto
`app/frontend/apps/desktop/components/layout/cose/cose-layout.weave.mjs`:

| Núcleo (intacto en disco) | Extensión aplicada al compilar |
|---|---|
| `components/layout/LayoutPage.vue` | Envuelve la rejilla en un contenedor en columna con `<CoseHeader />`; ajusta las clases de la rejilla y de `#main-content`; fija la navegación principal desplegada desde 768 px |
| `components/layout/LayoutSidebar/LeftSidebar/LeftSidebarHeader.vue` | Sustituye el icono `logo` de Zammad por `/cose/logo-icono.png` |

Validación: la plantilla resultante es equivalente nodo a nodo a la de los
antiguos parches (única diferencia: `data-test-id="cose-layout"` añadido) y el
servidor Vite de desarrollo sirve los módulos ya extendidos. Pruebas en
`components/layout/cose/__tests__/cose-layout.weave.spec.ts`.

Diferencias de comportamiento frente a los antiguos parches:

- Se conserva el comportamiento de Zammad que pliega la navegación principal
  cuando se abre la barra lateral de un ticket en pantallas pequeñas (el parche
  lo eliminaba; la extensión no puede quitar código del núcleo y es un
  comportamiento razonable).

Pruebas del núcleo afectadas a propósito:

- `LeftSidebarHeader.spec.ts › shows dummy logo when user has no agent
  permission` espera el icono de Zammad y falla con la marca C.O.S.E. (también
  fallaba con el parche anterior). Es el cambio de marca buscado.

En una actualización de Zammad, si cambian los anclajes (`root`, `#main-content`,
`CommonIcon name="logo"`) la compilación falla indicando este manifiesto.

### Cambios de comportamiento a tener en cuenta

- La ruta `CoseAtenciones` declara `alias: '/'`: la pantalla de inicio del
  escritorio pasa a ser Atenciones en lugar del Dashboard de Zammad.
- La vista de Atenciones usa la API REST `/api/v1` con la sesión del agente y el
  token CSRF de la página; no usa tokens de servicio.

## Procedimiento de actualización a una nueva versión

1. `git fetch --depth 1 upstream refs/tags/<X.Y.Z>:refs/upstream-tags/<X.Y.Z>`
2. Crear rama `upgrade/<X.Y.Z>` desde `main`.
3. Sustituir el árbol por el del tag nuevo conservando los archivos propios
   (`.gitignore` sección MAILING, `docs/`, `addons/README.md`, `.github/README.md`).
4. Verificar con `git diff --stat refs/upstream-tags/<X.Y.Z>` que solo difieren
   los archivos propios. Fusionar en `main`.
5. Fusionar en `cose/personalizaciones`; ejecutar el build/pruebas para
   comprobar que los anclajes de `cose-layout.weave.mjs` siguen existiendo.
6. Ejecutar migraciones, pruebas de C.O.S.E. y prueba manual de Atenciones.
7. Revisar `BREAKING_CHANGES.md` y los avisos de seguridad de Zammad.

Solo se actualiza desde tags oficiales (nunca `develop` ni `stable` sin etiqueta).
