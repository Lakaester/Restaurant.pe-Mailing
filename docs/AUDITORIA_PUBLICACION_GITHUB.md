# Auditoría previa a la publicación en GitHub

**Fecha:** 19/11/2026
**Alcance:** repositorio `/home/acast/mailing`, ramas `main` y `cose/personalizaciones`, historial completo, mensajes de commit y archivos no versionados.
**Resultado:** **apto para publicar como repositorio privado.**

## 1. Estado de Git

| Elemento | Valor |
|---|---|
| Ramas a publicar | `main` (2 commits), `cose/personalizaciones` (9 commits) |
| Remoto `origin` | `/mnt/c/dev/mailing` (copia en Windows). **Push deshabilitado** en la configuración local para no modificarla |
| Remoto `upstream` | `https://github.com/zammad/zammad.git`. Solo lectura, push deshabilitado. Tag `7.2.3` en `refs/upstream-tags/7.2.3` (no se publica) |
| Archivos versionados | ~14.200 |
| Tamaño del pack | ~67 MiB; archivo más grande 2,5 MB |
| Autores | `Lakaester <vcastagnino@restaurant.pe>` (base), `egamarra <egamarra@restaurant.pe>` (C.O.S.E.), `Victor Castagnino <vcastagnino@restaurant.pe>` (preparación de la publicación) |

## 2. Relación con Zammad 7.2.3

Comparación de árboles contra el tag oficial: tras los commits de corrección,
el núcleo es idéntico a Zammad 7.2.3 salvo archivos propios de documentación y
configuración. Hay dos parches documentados sobre el layout de escritorio.
Detalle en [`UPSTREAM.md`](UPSTREAM.md).

## 3. Secretos y credenciales

Método: búsqueda de patrones (contraseñas, tokens, claves privadas, cadenas de
conexión, URLs con credenciales, claves de AWS/Google/GitHub/Slack/OpenAI) sobre
todo el contenido que difiere del tag oficial en cualquier commit. El contenido
idéntico a Zammad oficial ya es público.

| Resultado | Detalle |
|---|---|
| Credenciales en el historial | **Ninguna.** Las coincidencias son descripciones (p. ej. "token CSRF") |
| `spec/fixtures/files/smime/*.key` | Fixtures públicos de pruebas de Zammad, idénticos al upstream |
| `config/database.yml`, logs, `tmp/`, `node_modules/`, `vendor/bundle/` | Existen en local y están **ignorados** |
| Código C.O.S.E. | Usa la sesión del agente y CSRF. No contiene tokens de servicio |

`gitleaks` no se pudo ejecutar (no se autorizó la descarga de binarios). Se
recomienda pasarlo de forma periódica.

## 4. Datos sensibles y reescritura del historial

| Dato | Dónde estaba | Acción |
|---|---|---|
| IP del servidor de BD de producción | 5 documentos del motor SLA (desde el commit `3bddd041`) | Sustituida por `<IP_BD_PRODUCCION>` **en todo el historial** |
| Correo de un cliente externo real | `VALIDACION_FUNCIONAL_ATENCIONES_COSE.md` | Sustituido por `<correo-cliente-externo>` en todo el historial |
| Dominio de ese cliente | El mismo documento y un test unitario (desde `39b8b449`) | `<dominio-cliente-externo>` en la documentación y `cliente-externo.example` en el test |
| Nombre de la BD y usuario de producción (`pgvector_db`, `pgvector_user`) | Documentos SLA | Se mantienen: hacen falta para la lista negra de migraciones y no son credenciales |
| Correos y nombres del equipo de Restaurant.pe | Varios documentos | Se mantienen: repositorio privado de uso interno |
| Capturas con datos reales | `docs/atenciones-zammad/evidencias/` (sin versionar) | Ignoradas y no se publican. Siguen en disco |
| Copias `.orig` | `docs/atenciones-zammad/revert/` (sin versionar) | Ignoradas y no se publican. Siguen en disco |

**Reescritura:** se usó `git filter-branch --index-filter` sobre
`b71bdf6f..cose/personalizaciones`. Solo cambiaron los blobs que contenían los
datos. Se conservaron los autores, los committers, las fechas y los mensajes.
`main` no se tocó. Correspondencia de commits:

| Original | Redactado | Commit |
|---|---|---|
| `39b8b449` | `e742d230` | feat(cose): cabecera C.O.S.E. y vistas de Atenciones y SLA |
| `3bddd041` | `7ddcad46` | docs(cose): documentación de atenciones y SLA |
| `8d643665` | `f0c15100` | fix(cose): lint en servicios de Atenciones |
| `34305f4e` | `75913882` | docs: preparar el repositorio para su publicación |
| `a82f35d8` | — | commit de redacción; quedó vacío y se eliminó |

**Respaldo local de la versión original. Nunca se publica:**

- `refs/respaldo/pre-redaccion-20261119`. Está fuera de `refs/heads` y `refs/tags`.
- `/home/acast/respaldos/mailing-pre-redaccion-20261119.bundle` (permisos `0600`, verificado).

## 5. Calidad del código C.O.S.E.

| Comprobación | Resultado |
|---|---|
| Vitest `cose-atenciones` | 23/23 |
| `pnpm lint:js:oxlint:cmd` en las rutas C.O.S.E. | Sin errores; se corrigieron 2 hallazgos |
| Type-check completo (`vue-tsc`) | No se ejecutó: tarda más de 7 minutos en este equipo |

## 6. GitHub Actions

Ver [`GITHUB_ACTIONS.md`](GITHUB_ACTIONS.md). Se deshabilitan los 4 workflows
heredados por coste (CI y docker-ci) o por estar dedicados a la publicación
oficial de Zammad (docker-release y packager.io). Queda activo `cose-ci.yml`,
que tiene permisos de solo lectura y no usa secretos.

## 7. Destino

- Organización `RestaurantPE`: existe en GitHub, pero la cuenta `Lakaester` no es
  miembro ni tiene invitaciones. **No se usa.**
- Destino: `Lakaester/Restaurant.pe-Mailing`, **privado**. Publicado el 19/11/2026 (ver sección 8).
- Se publican únicamente las referencias `refs/heads/main` y
  `refs/heads/cose/personalizaciones`, con refspecs explícitos. Nunca se usa `--all`,
  `--mirror` ni `--tags`.

## 8. Resultado de la publicación (19/11/2026)

| Verificación | Resultado |
|---|---|
| Datos sensibles en los 9 commits publicables, en los mensajes y en los autores | 0 |
| Patrones de secretos en el contenido propio | 0 |
| Respaldo `refs/respaldo/*` alcanzable desde las ramas publicadas | No |
| Referencias remotas | Solo `refs/heads/main` y `refs/heads/cose/personalizaciones`; 0 tags |
| Commit y árbol remotos frente a los locales | Idénticos en ambas ramas (`80e0f313` / `6ae6005f`, `329d3d92` / `e4925f8a`) |
| Archivos en `cose/personalizaciones` | 14.195 en el remoto y 14.195 en local |
| Visibilidad | `private`. Rama por defecto `main`. Wiki deshabilitada |
| Ejecuciones de Actions | 0. Actions estuvo apagado durante el push y los 4 heredados quedaron en `disabled_manually` |
| Archivos locales excluidos (evidencias, `.orig`, `database.yml`) | Intactos: 12/12 SHA-256 coinciden |

Incidencia: GitHub devolvía HTTP 408 al procesar el paquete completo (~34 MB,
17.000 objetos). Se subió en 4 tandas mediante commits temporales cuyos árboles
eran subconjuntos exactos de `main` (`i18n`, `app`, `test`+`public`, `spec`),
usando una rama temporal `tmp/subida`. Esa rama se borró después; no aportaba
contenido distinto del de `main`.
