# Auditoría previa a la publicación en GitHub

**Fecha:** 19/11/2026
**Alcance:** repositorio `/home/acast/mailing`, ramas `main` y `cose/personalizaciones`, historial completo y archivos no versionados.
**Resultado:** **apto para publicar como repositorio privado**, con las condiciones de la sección 6.

## 1. Estado de Git

| Elemento | Valor |
|---|---|
| Ramas locales | `main` (2 commits), `cose/personalizaciones` (6 commits + cambios de esta auditoría) |
| Remoto `origin` | `/mnt/c/dev/mailing` (copia en Windows; no se modifica) |
| Remoto `upstream` | `https://github.com/zammad/zammad.git` (añadido para verificación; solo lectura) |
| Archivos versionados | 14.190 |
| Tamaño del pack | ~67 MiB; archivo más grande 2,5 MB (sin archivos > 50 MB) |
| Autores | `Lakaester <vcastagnino@restaurant.pe>` (base), `egamarra <egamarra@restaurant.pe>` (C.O.S.E.) |

## 2. Relación con Zammad 7.2.3

Verificado por comparación de árboles contra el tag oficial: tras los commits de
corrección, el núcleo es idéntico a Zammad 7.2.3 salvo 5 archivos propios de
documentación/configuración. Detalle en [`UPSTREAM.md`](UPSTREAM.md).

Hallazgo: la decisión D-004 (núcleo intacto) tiene **dos excepciones** no
documentadas hasta ahora (`LayoutPage.vue`, `LeftSidebarHeader.vue`). Quedan
registradas como parches en `UPSTREAM.md`.

## 3. Secretos y credenciales

Método: búsqueda de patrones (contraseñas, tokens, claves privadas, cadenas de
conexión, URLs con credenciales, claves de AWS/Google/GitHub/Slack/OpenAI) sobre
**todo el contenido añadido respecto al tag oficial**, que incluye el historial
completo de ambas ramas. El contenido idéntico a Zammad oficial es público.

| Resultado | Detalle |
|---|---|
| Credenciales en el historial | **Ninguna.** Las 292 coincidencias son descripciones (p. ej. "token CSRF", "los tokens se guardan en texto plano") |
| Claves en `spec/fixtures/files/smime/*.key` | Fixtures públicos de pruebas de Zammad; idénticos al upstream |
| `config/database.yml` | Existe en local, **ignorado** por Git |
| Logs, `tmp/`, `node_modules/`, `vendor/bundle/` | Ignorados |
| Código C.O.S.E. | Usa la sesión del agente y CSRF; no contiene tokens de servicio |

Nota: no se pudo ejecutar `gitleaks` (descarga de binarios no autorizada en esta
sesión). Se recomienda pasarlo antes de cada publicación importante.

## 4. Datos sensibles

| Dato | Ubicación | Acción |
|---|---|---|
| IP del servidor de BD de producción | 5 documentos del motor SLA | **Redactado** a `<IP_BD_PRODUCCION>` en el árbol actual. Sigue presente en el commit `3bddd041` (ver 6.2) |
| Nombre de BD y usuario de producción (`pgvector_db`, `pgvector_user`) | Mismos documentos | Se mantienen: son necesarios para la lista negra de migraciones y no son credenciales |
| Correo y dominio de un cliente externo real | `VALIDACION_FUNCIONAL_ATENCIONES_COSE.md` | **Redactado** en el árbol actual; presente en `3bddd041` |
| Correos y nombres del equipo de Restaurant.pe | Varios documentos | Se mantienen: repositorio privado de uso interno |
| Capturas de pantalla con datos reales | `docs/atenciones-zammad/evidencias/` (no versionado) | **No se publican**; ignoradas en `.gitignore`, conservadas en disco |
| Copias `.orig` de archivos | `docs/atenciones-zammad/revert/` (no versionado) | **No se publican**; ignoradas, conservadas en disco |

## 5. Calidad del código C.O.S.E.

| Comprobación | Resultado |
|---|---|
| Pruebas Vitest (`cose-atenciones`) | 23/23 correctas |
| `oxlint` sobre código C.O.S.E. | 2 errores encontrados y corregidos (cuerpo en GET, spread acumulativo) |
| Type-check completo (`vue-tsc`) | No ejecutado: supera 7 minutos en este equipo |

## 6. Condiciones para publicar

1. **GitHub Actions deshabilitado** en el repositorio nuevo antes del primer
   push: los workflows heredados de Zammad ejecutan CI completo en cada PR y
   cada viernes, consumiendo minutos de pago en un repositorio privado.
2. **Historial con datos redactados.** La IP de producción y el correo del
   cliente externo siguen en el commit `3bddd041`. Opciones:
   - a) Publicar tal cual (repositorio privado; riesgo bajo).
   - b) Reescribir **solo** el commit local `3bddd041` y posteriores antes del
     primer push, conservando la rama original con una etiqueta de respaldo.
     Nunca se ha publicado, por lo que no afecta a nadie.
3. Destino y visibilidad confirmados por el responsable antes del push.
4. Licencia AGPL-3.0: validación legal pendiente (decisión abierta en `decisiones.md`).
