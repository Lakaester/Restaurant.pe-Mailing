# ENTREGA — Atenciones C.O.S.E. sobre Zammad 7.2.3 (versión candidata)

**Fecha:** 17/11/2026
**Repositorio:** `/home/acast/mailing` (WSL), rama `main`, HEAD `80e0f313`.
**Estado (actualizado 17/11/2026):** versión candidata **validada parcialmente en navegador y contra API**. Flujo funcional demostrado con datos de prueba. Envío de correo y comparación visual con la captura siguen pendientes. Detalle en `VALIDACION_FUNCIONAL_ATENCIONES_COSE.md`.

## 1. Qué se entregó

Una pantalla nueva **«Atenciones»** dentro de Zammad, en el menú principal, con tres zonas como la referencia de C.O.S.E.:

| Zona | Contenido | Datos |
|---|---|---|
| Bandeja (288 px) | Buscador, chips Todas/Abiertas/Pendientes/Cerradas con contador, canal, «Asignadas a mí», lista de tickets | `GET /tickets/search` |
| Conversación (flexible) | Cabecera del ticket, acciones (Asignar a mí, estado, Resolver), hilo de artículos con adjuntos, compositor con **Responder por correo** y **Nota interna** | `GET /ticket_articles/by_ticket/:id`, `POST /ticket_articles`, `PUT /tickets/:id` |
| Panel operativo (420–520 px) | Cliente (correo, dominio, responsable), registro operativo con clasificación oficial, pestañas Resumen / Actividad / Operación / Historial | `GET /users/:id`, `GET /ticket_history/:id`, `PUT /tickets/:id` |

**Integración por arquitectura:** la página se registra con `routes.ts` dentro de `pages/`, que Zammad descubre por glob. **No se modificó ningún archivo del núcleo.** Los CSS del tema C.O.S.E. se reutilizan con sus variables `--cose-*`.

### Archivos nuevos (todos bajo `app/frontend/apps/desktop/pages/cose-atenciones/`)

| Archivo | Función |
|---|---|
| `routes.ts` | Ruta `/cose/atenciones/:ticketId?`, entrada de menú, permiso `ticket.agent` |
| `views/CoseAtencionesView.vue` | Pantalla de tres zonas |
| `composables/useAtenciones.ts` | Estado y operaciones; cada una confirma solo tras respuesta de Zammad |
| `services/zammadRest.ts` | Cliente REST con cookie de sesión y `X-CSRF-Token`; sin tokens en JavaScript |
| `services/atencionesApi.ts` | Llamadas a rutas REST verificadas en `config/routes/ticket.rb` y `user.rb` |
| `services/atencionesDominio.ts` | Reglas puras: filtros, grupos de estado, clasificación del par, saneado HTML, fechas en America/Lima |
| `catalog/catalogo-cose.ts` | Catálogo generado desde `catalogo-oficial.json` (13 categorías, 65 subcategorías) |
| `services/__tests__/atencionesDominio.spec.ts` | 16 pruebas de las reglas |

Como referencia, la página **no** modificó nada de `docs/captures/`, ni `CategoryData.ts`, ni `public.v_unificado_norm`, ni la base de datos.

## 2. Verificación realizada

| Verificación | Resultado | Evidencia |
|---|---|---|
| Reglas puras (filtros, estados, catálogo, dominio, texto) | **15 OK, 0 fallos, 1 omitida** | Ejecutadas con `tsx` (Node 24) sobre copias en `%TEMP%` |
| Pendiente: prueba que necesita DOM (`textoDeCuerpo` con HTML) | **No ejecutada** | Requiere `DOMParser`; no hay navegador en la prueba |
| TypeScript estricto de la capa de servicio, API y catálogo | **0 errores** | `tsc --noEmit --strict` |
| Consistencia del catálogo | 13 categorías, 65 subcategorías, 3 valores repetidos | Verificado en código y en la prueba |
| Cambios en el núcleo de Zammad | **Ninguno** | `git status`: solo aparece la carpeta nueva y los archivos sin versionar previos |

**Actualización de verificación (17/11/2026, segunda fase):**

- **Vitest dentro de Zammad: 23/23 pruebas aprobadas** (20 de dominio + 3 de barrera de correo), incluida la prueba con `DOMParser`.
- **`vue-tsc` dirigido a los archivos nuevos: 0 errores.** El `vue-tsc` de todo el proyecto agotó la memoria (OOM del proceso, no errores de código).
- **Aplicación en navegador: verificada** en `http://localhost:3000/desktop/cose/atenciones`: tres zonas, bandeja con 4 tickets, conversación, adjunto, clasificación, dominio, nota e historial. Sin errores de consola.
- **API en vivo: verificada** en todos los pasos del flujo (ver documento de validación).
- **Sin verificar:** envío de correo (barrera activa), permisos con un usuario sin `ticket.agent`, diseño a tres columnas con viewport ancho, botón «Cargar más» con más de 25 tickets y build de producción.

## 3. Referencia visual

La captura indicada (`/mnt/data/image(20261117-212844).png`) **no existe** en el entorno. Las dos imágenes recientes de `Descargas` tampoco son el módulo Atenciones (una es la auditoría de insumos de otro sistema y otra es un error de Rappi). Por eso la maquetación toma como referencia el **código real** del módulo Atenciones de C.O.S.E. (`restaurant-bi/frontend/src/pages/cope/Atenciones.tsx`: bandeja `w-72`, workspace flexible, panel `clamp(420px, 32vw, 520px)`). **No hay comparación de píxeles con la captura.** Si se entrega la captura, debe compararse antes de aceptar la similitud visual.

## 4. Riesgos antes de usar la pantalla

1. **Responder envía correo real.** `POST /ticket_articles` con `type: email` utiliza el canal configurado en Zammad. Antes de probar, debe usarse un canal de pruebas o desactivar el envío en el entorno de desarrollo. No se envió ningún correo durante esta entrega.
2. **Búsqueda con `query: '*'`.** Verificada en vivo: HTTP 200, `total_count=4`, `page`/`per_page` funcionan. Búsqueda por término también (`recap` → ticket 91009).
3. **Atributo `categoria_subcategoria`.** Confirmado en vivo: existe, es `tree_select` con 13 categorías y 65 hojas, idéntico al catálogo oficial. `dominio` existe como `input`.
4. **Valores repetidos del catálogo.** Resuelto: se creó el campo `cose_categoria` (ObjectManager id 62) y se escribe la categoría junto a la hoja. Verificado con el par ambiguo `SERVIDOR · redes_y_conexiones` y después `OPERATIVO · caída_del_servidor`.
5. **Catálogo duplicado en el frontend.** `catalog/catalogo-cose.ts` es una copia generada. Cualquier cambio en el catálogo oficial debe regenerarlo.

## 5. Brechas frente a Zendesk (matriz de paridad, resumen)

| Funcionalidad de Atenciones C.O.S.E. | Estado en esta entrega |
|---|---|
| Bandeja con búsqueda y filtros reales | **Parcial:** trae los 200 tickets más recientes; el filtrado es en el cliente. Sin paginación real |
| Conversación con artículos originales | **Implementado** (sin verificar en vivo) |
| Adjuntos | **Parcial:** enlace a `ticket_attachment`; sin vista previa; si Zammad devuelve solo ids, el nombre es genérico |
| Responder por correo | **Implementado** (sin verificar; envía correo real, ver §4.1) |
| Notas internas | **Implementado** (sin verificar en vivo) |
| Asignar | **Parcial:** solo «Asignar a mí». Falta asignar a otro agente |
| Cambiar estado | **Implementado** (sin verificar en vivo) |
| Clasificar (categoría y subcategoría) | **Implementado** con limitación de valores repetidos (§4.4) |
| Registrar dominio del cliente | **No implementado.** Solo se muestra el dominio del correo |
| Historial y actividad | **Parcial:** lista cruda de `ticket_history` y de artículos; formato sin verificar |
| Operación | **Parcial:** resumen de clasificación, responsable y estado |
| Resolver | **Implementado:** cambia al estado `closed` si existe |
| SLA | **Pendiente de integración:** se muestra el aviso, sin plazos calculados |
| WhatsApp, Rappi, PedidosYa, Uber, Didi, integraciones | **Excluido por alcance** |
| Estado por defecto al entrar | **No cambiado:** Atenciones aparece en el menú, pero el inicio sigue siendo el de Zammad |

## 6. Plan de pruebas pendiente (antes de la candidata)

1. Levantar Zammad con memoria suficiente y autorización.
2. Abrir `/cose/atenciones` con un agente de prueba y verificar consola limpia.
3. Probar búsqueda, cada chip, «Asignadas a mí» y canal.
4. Seleccionar un ticket de prueba: conversación, adjunto, HTML saneado.
5. Nota interna; respuesta **solo con canal de pruebas**.
6. Asignar, cambiar estado, clasificar (válida, inválida y valor repetido) y resolver. Confirmar en la base de datos o en la API que cada cambio persiste.
7. Permisos: un usuario sin `ticket.agent` no debe ver la ruta.
8. Ejecutar `npx vitest run app/frontend/apps/desktop/pages/cose-atenciones` y el type-check de Zammad.

## 7. Plan de reversión

- Eliminar la carpeta `app/frontend/apps/desktop/pages/cose-atenciones/`. Al desaparecer `routes.ts`, la entrada de menú y la ruta desaparecen sin afectar a nada más.
- Existe **un** cambio de esquema en la base local de desarrollo: atributo `cose_categoria` (ObjectManager id 62), creado con la API nativa y migrado con `object_manager_attributes_execute_migrations`. Para revertirlo: `DELETE /api/v1/object_manager_attributes/62` y volver a ejecutar las migraciones de atributos (esto elimina la columna; **no hacerlo sin antes decidir qué se hace con los datos ya registrados**).
- No hay cambios en migraciones de Rails ni en el núcleo de Zammad.
- Si se hubiera enviado algún correo desde la pantalla, no es reversible; por eso §4.1 exige canal de pruebas.

## 8. Dependencias

- Zammad 7.2.3 en ejecución y sesión de agente.
- Permiso `ticket.agent`.
- Catálogo oficial generado (`catalog/catalogo-cose.ts`).
- Canal de correo configurado (solo para responder).
- Decisión sobre valores repetidos y sobre el atributo `categoria_subcategoria` (§4.3–4.4).

## 9. Guía breve de uso (cuando esté verificado)

1. Iniciar Zammad (`bundle exec script/rails server -b 127.0.0.1 -p 3000` y Vite) con memoria suficiente.
2. Entrar como agente y abrir directamente **`http://localhost:3000/desktop/cose/atenciones`**. La URL `/cose/atenciones` **no existe** en Rails: el frontend se sirve bajo `/desktop/`. La entrada «Atenciones» del menú principal debe llevar a esa ruta.
3. Seleccionar una atención en la bandeja: la conversación y el panel se cargan a la derecha.
4. Clasificar en el panel operativo; asignar, cambiar estado o resolver con los botones de la cabecera.
5. Responder por correo o guardar una nota interna en la pestaña correspondiente.

## 10. Confirmación

- No se hizo commit ni push. No se cambió de rama.
- No se modificó el proyecto Windows `C:\dev\mailing`.
- No se conectó a PostgreSQL empresarial ni se usaron credenciales.
- Durante la fase de validación, la creación del atributo y su migración provocaron un **OOM** que terminó puma, websocket y worker; se restauraron los tres con los comandos documentados en `Procfile.dev`. Estado final: puma, websocket, worker y Vite activos; Rails responde 200. No se detuvo ningún servicio ajeno ni se modificó su configuración.
- No se modificó ningún archivo del núcleo de Zammad.
- **Se creó un atributo de ObjectManager** en la base local de desarrollo (`cose_categoria`). Ver §7.

## 11. Extensión global de la identidad (18/11/2026)

La entrega dejó de ser un módulo aislado:

- `Atenciones` se registró como **alias `/`** de la ruta Vue, por delante del Dashboard en el orden del glob, para que sea la pantalla de entrada del agente. Debe confirmarse en navegador que gana la precedencia.
- Nueva entrada **SLA** en la navegación principal, con pantalla honesta de «integración pendiente» y sin métricas simuladas.
- Bloque 7 de los tres archivos `99-cose-theme.css`: marca C.O.S.E. en la barra lateral, enlaces y encabezados en paleta institucional, table headers y selección, y elemento activo de navegación en naranja. Aplica a frontend Vue desktop, móvil y login/frontend clásico.
- Tres columnas de Atenciones conservadas hasta 700 px (antes se apilaban por debajo de 1100 px).
- `vue-tsc` dirigido a `cose-atenciones` + `cose-sla`: **0 errores**. Ambos módulos aparecen en el router servido por Vite.

Detalle y guion de presentación: `ENTREGA_PRESENTACION_ZAMMAD_COSE.md`.
