# Decisiones del proyecto MAILING

Registro de decisiones tomadas. Cada decisión indica fecha, motivo y qué
implica.

## D-001 — Base tecnológica

- **Fecha:** 12/11/2026
- **Decisión:** usar Zammad 7.2.3 como núcleo de Mailing.
- **Motivo:** cubre buzones de correo, tickets, SLA, plantillas,
  automatizaciones y auditoría sin desarrollo desde cero.
- **Implica:** Mailing hereda las actualizaciones y los avisos de seguridad de
  Zammad.

## D-002 — Uso interno

- **Fecha:** 12/11/2026
- **Decisión:** Mailing es una plataforma de uso interno de Restaurant.pe.
- **Alcance:** solo correo electrónico y tickets derivados de correo. WhatsApp y
  chats quedan fuera de alcance; no se configurarán.
- **Implica:** no se eliminan módulos del núcleo, solo se dejan sin usar.

## D-003 — Alojamiento propio

- **Fecha:** 12/11/2026
- **Decisión:** no usar Railway ni contratar infraestructura externa.
- **Motivo:** Restaurant.pe dispone de servidores, dominios y PostgreSQL
  propios.
- **Implica:** el destino final es un servidor de la empresa. El desarrollo y
  las pruebas se hacen en local.

## D-004 — Núcleo intacto, personalizaciones en addons

- **Fecha:** 12/11/2026
- **Decisión:** no modificar archivos del núcleo de Zammad. Toda
  personalización va en `addons/`.
- **Motivo:** poder actualizar Zammad sin conflictos.
- **Implica:** si algún cambio exige tocar el núcleo, se documenta como parche
  y se revisa en cada actualización.

## D-005 — Verificación del código base

- **Fecha:** 12/11/2026
- **Decisión:** aceptar la copia descargada como base válida.
- **Motivo:** los 14.074 archivos coinciden byte a byte con el tag oficial.
- **Detalle:** `docs/verificacion-fase-1.md`.

## D-006 — Control de versiones

- **Fecha:** 12/11/2026
- **Decisión:** repositorio Git local en `C:\dev\mailing`, con el primer commit
  como base limpia de Zammad 7.2.3.
- **Implica:** todavía no hay repositorio remoto ni se ha subido código a
  ninguna plataforma.

## D-007 — Repositorio de trabajo en Ubuntu (WSL2)

- **Fecha:** 19/11/2026
- **Decisión:** el desarrollo continúa en `/home/acast/mailing` (Ubuntu/WSL2),
  rama `cose/personalizaciones`. `C:\dev\mailing` queda como copia de origen y
  no se modifica.
- **Motivo:** Windows rompe permisos de ejecución y enlaces simbólicos de Zammad
  (ver commits `80e0f313` y `f8bbeada`).

## D-008 — Parches sobre el núcleo (excepción a D-004)

- **Fecha:** 19/11/2026
- **Decisión:** se aceptan temporalmente dos parches en el layout de escritorio
  (`LayoutPage.vue`, `LeftSidebarHeader.vue`) para la cabecera y el logo C.O.S.E.
- **Implica:** quedan inventariados en `UPSTREAM.md`; el objetivo es moverlos a
  un addon con la capa de extensión de Vue de Zammad.
- **Actualización 19/11/2026:** resuelto. Los parches se sustituyeron por el
  manifiesto `cose-layout.weave.mjs`; el núcleo vuelve a ser idéntico a 7.2.3
  y D-004 se cumple sin excepciones.

## D-009 — Repositorio remoto privado en GitHub

- **Fecha:** 19/11/2026
- **Propuesta:** publicar como repositorio privado `Lakaester/Restaurant.pe-Mailing`.
  La organización `RestaurantPE` existe en GitHub, pero la cuenta `Lakaester`
  no es miembro; no se publica en ella sin autorización.
- **Condiciones:** auditoría de `AUDITORIA_PUBLICACION_GITHUB.md`; historial
  redactado (IP de producción y cliente externo); workflows heredados
  deshabilitados según `GITHUB_ACTIONS.md`; evidencias con datos reales fuera
  del repositorio.
- **Estado:** **publicado el 19/11/2026** con aprobación del responsable. Ramas
  `main` y `cose/personalizaciones`; visibilidad privada verificada.

## D-010 — Idioma de la interfaz C.O.S.E. y catálogo de traducción

- **Fecha:** 19/11/2026
- **Decisión:** los textos de la interfaz C.O.S.E. y los valores del catálogo
  de categorías se escriben directamente en español y **no** se marcan con
  `__()` para el catálogo de traducción de Zammad.
- **Motivo:** el catálogo de Zammad usa el inglés como idioma de origen y se
  gestiona en translations.zammad.org; mezclar cadenas en español lo
  contaminaría. Además, las categorías son valores de datos guardados en los
  tickets, no textos traducibles.
- **Implica:** la regla ESLint `zammad/zammad-detect-translatable-string` se
  desactiva por archivo (con justificación) en el código C.O.S.E. Si en el
  futuro se necesita multilenguaje, se definirá un catálogo propio.

## Pendientes de decisión

| Tema | Estado |
|---|---|
| Repositorio remoto privado (GitHub) | Publicado (D-009) |
| Entorno local de ejecución | WSL2 Ubuntu (D-007) |
| Elasticsearch en local y en producción | Pendiente |
| Validación legal de la licencia AGPL-3.0 | Pendiente |
| Dominio definitivo de Mailing | Pendiente |
| Primer addon y alcance funcional | Pendiente |
