# VALIDACIÓN FUNCIONAL — Atenciones C.O.S.E. sobre Zammad 7.2.3

**Fecha:** 17/11/2026
**Repositorio:** `/home/acast/mailing`, rama `main`, HEAD `80e0f313`.
**Sesión usada:** agente `vcastagnino@restaurant.pe` (id 5, roles Admin + Agent), CSRF de la página, sin credenciales escritas en archivos ni en comandos.
**Datos de prueba:** ticket **#91009** ("Your meeting recap - Capacitación FE - RD", cliente `<correo-cliente-externo>`, grupo Soporte Especializado).
**Estado:** **versión candidata verificada parcialmente**. Flujo bandeja → abrir → conversar → adjunto → asignar → dominio → clasificar → nota → estado → resolver **demostrado y persistido**. No se declara plataforma terminada.

---

## 1. Estado de arranque

### Antes de la validación

| Servicio | Estado observado |
|---|---|
| puma (Rails, `127.0.0.1:3000`) | Activo desde hacía 11 h |
| Vite (`127.0.0.1:3036`) | Activo |
| PostgreSQL 16 y Redis | Activos |
| background-worker, websocket (`6042`) | Activos |
| Memoria | 2,9 GB totales, ~562 MB disponibles, 1,5 GB swap libre |

No fue necesario iniciar Zammad: **ya estaba corriendo**.

### Incidente y restauración

Al ejecutar la migración del campo de ObjectManager (ver §3), el kernel mató **puma, websocket y background-worker** por falta de memoria (`dmesg`: OOM). Vite, PostgreSQL y Redis sobrevivieron. Se restauraron los tres procesos con los comandos de `Procfile.dev`, usando el Ruby correcto de rbenv (un primer intento con `bash -c` resolvió al Ruby de Windows y falló; se corrigió con `bash -lc`):

```bash
cd /home/acast/mailing
bundle exec script/rails server -b 127.0.0.1 -p 3000
bundle exec script/websocket-server.rb -b 127.0.0.1 -p 6042 start
bundle exec script/background-worker.rb start
```

**Estado final verificado:** los cuatro procesos activos, `GET /` → **HTTP 200**. No se cambió configuración de ningún servicio.

### Acceso correcto

- `http://localhost:3000/cose/atenciones` → **404**. Rails solo sirve el frontend Vue bajo `/desktop/*` (`config/routes/desktop.rb`).
- `http://localhost:3000/desktop/cose/atenciones` → **pantalla Atenciones** (título "C.O.S.E - Atenciones").

El primer `404` no era un fallo de la ruta Vue: el glob de `routes.ts` se reindexó al tocar `app/frontend/apps/desktop/router/index.ts`; el módulo `cose-atenciones/routes.ts` aparece hoy en el router transformado por Vite.

---

## 2. Cambios aplicados en esta fase

| Archivo | Cambio | Motivo |
|---|---|---|
| `services/atencionesApi.ts` | Búsqueda con `page`, `per_page`, `with_total_count`; `clasificarTicket` escribe la hoja **y** la categoría; `registrarDominio`; `historialTicket` desenvuelve `{history, assets}` | Paginación real, par reconstruible, dominio editable, historial roto |
| `composables/useAtenciones.ts` | Estado de paginación (`cargarMas`), `clasificar`, `guardarDominio`, barrera de envío | Funcionalidad y seguridad |
| `views/CoseAtencionesView.vue` | Footer «Cargar más», editor de dominio, visualización del par categoría+subcategoría, pestaña «Responder por correo» bloqueada por defecto | Interfaz operativa |
| `services/atencionesDominio.ts` | `normalizarDominio`, `nombreDeSubcategoria`, `hayPaginaSiguiente` | Reglas puras nuevas |
| `services/politicaEnvio.ts` | **Nuevo**. Barrera de salida de correo | Evitar envíos reales durante pruebas |
| `services/__tests__/*.spec.ts` | 23 pruebas (20 + 3) | Regresión |

### Cambio de esquema (base local de desarrollo)

- Se verificó primero que **`cose_categoria` no existía**.
- `categoria_subcategoria` **ya existía**: `tree_select` con 13 categorías y 65 hojas, idéntico al catálogo oficial; `dominio` ya existía como `input`. Por eso **no se crearon esos dos campos**.
- Se creó `cose_categoria` (`input`, Texto, 255) vía `POST /api/v1/object_manager_attributes` → **201**, id **62**.
- Se aplicó con `POST /api/v1/object_manager_attributes_execute_migrations` → **200**, `to_migrate: false`, columna visible en `GET /tickets/:id?expand=true`.
- La fuente original del catálogo (`catalogo-oficial.json`) **no se modificó**.

---

## 3. Errores encontrados y corregidos

| # | Error | Causa | Corrección | Estado |
|---|---|---|---|---|
| 1 | `404` en `/cose/atenciones` | Rails no tiene catch-all; solo `/desktop/*path` | Usar `/desktop/cose/atenciones` y documentarlo | Corregido (documentación + ruta verificada) |
| 2 | Pestaña Historial vacía | `/ticket_history/:id` devuelve `{history, assets}`, no un array | `historialTicket` desenvuelve `history` | Corregido y verificado en UI: 17 entradas visibles |
| 3 | Pérdida de categoría en 3 valores repetidos | El `tree_select` guarda solo la hoja | Campo `cose_categoria` escrito en cada clasificación | Corregido y verificado en UI + API |
| 4 | Dominio solo de lectura | No había control de edición | Input + `Guardar dominio` con normalización | Corregido y verificado |
| 5 | Bandeja fija de 200 tickets | `per_page` sin paginación | `page`/`per_page` + «Cargar más» | Implementado; no ejercitado con >25 tickets |
| 6 | El glob de Vue no vio la carpeta nueva | Vite iniciado antes de crear los archivos | `touch` al router; el módulo ya aparece en el bundle | Corregido |
| 7 | OOM de puma/websocket/worker | Presión de memoria al migrar atributos | Restauración de los 3 procesos | Corregido; entorno estable |
| 8 | `vue-tsc` completo = OOM | Límite de memoria del contenedor | Type-check dirigido a los archivos nuevos | Verificado (0 errores); el global no es válido |

---

## 4. Pruebas ejecutadas

| Prueba | Comando | Resultado |
|---|---|---|
| Vitest — reglas de dominio | `pnpm test --run .../atencionesDominio.spec.ts` | **20/20 OK** |
| Vitest — barrera de correo | `pnpm test --run .../politicaEnvio.spec.ts` | **3/3 OK** |
| Pruebas ligeras con `tsx` (copias en `%TEMP%`) | `tsx run.ts` | **22 OK, 0 fallos, 1 omitida** (el DOM ya se cubre con Vitest) |
| TypeScript estricto de servicios/API/catálogo | `tsc --noEmit --strict ...` | **0 errores** |
| Vue type-check dirigido | `vue-tsc --noEmit -p tsconfig.cose-check.json` | **0 errores**. Tsconfig temporal eliminado |
| Carga en navegador | pestaña en `/desktop/cose/atenciones` | 3 zonas, datos reales, **0 errores de consola** |
| API en vivo | `fetch` con sesión + CSRF | Ver §5 |
| `vue-tsc` de todo el proyecto | `pnpm lint:ts` | **NOT_RUN** por OOM del proceso (no por errores de código) |
| Build de producción | — | **NOT_RUN** |
| Permisos con usuario sin `ticket.agent` | — | **NOT_RUN** (no hay segunda sesión) |

No se ejecutaron pruebas pesadas en paralelo. No se envió ningún correo.

---

## 5. Resultado de cada operación

### Por API (Zammad en vivo)

| Operación | Verificación | Persistencia comprobada |
|---|---|---|
| Bandeja `GET /tickets/search?query=*&page=1&per_page=25&with_total_count=true` | HTTP 200, `total=4`, ids `[9,8,7,1]` | — |
| Búsqueda por término `query=recap` | HTTP 200, `total=1`, ticket 91009 | — |
| Página 2 `page=2` | HTTP 200, sin filas (solo hay 4 tickets) | — |
| Selección `GET /tickets/9?expand=true` | HTTP 200, numero 91009, estado `new`, grupo Soporte Especializado | — |
| Lectura de artículos `GET /ticket_articles/by_ticket/9` | HTTP 200, 1 artículo tipo `email` | — |
| Adjunto `/ticket_attachment/9/7/35` | **HTTP 200**, `message.html`, **34.844 bytes** | — |
| Asignación `PUT owner_id=5` | HTTP 200 | `owner_id=5`, propietario `vcastagnino@restaurant.pe` |
| Dominio `PUT dominio=<dominio-cliente-externo>` | HTTP 200 | `dominio=<dominio-cliente-externo>` |
| Clasificación ambigua `PUT redes_y_conexiones` + `cose_categoria=SERVIDOR` | HTTP 200 | Ambos campos guardados |
| Nota interna `POST /ticket_articles` (`note`, `internal=true`) | **HTTP 201**, id 8 | Artículos de 1 a 2 |
| Cambio de estado `state_id=2` | HTTP 200 | `state=open` |
| Resolución `state_id=4` | HTTP 200 | `state=closed` |
| Historial `GET /ticket_history/9` | HTTP 200, **17 entradas** | Incluye `dominio`, `categoria_subcategoria`, `cose_categoria`, `state new→open→closed` |

### Desde la interfaz (mismos datos, acciones de usuario)

| Acción UI | Confirmación en pantalla | Verificación posterior en API |
|---|---|---|
| Cargar bandeja | "4 de 4", chips Todas 4 / Abiertas 3 / Cerradas 1 | `total_count=4` |
| Seleccionar #91009 | Conversación, cabecera, adjunto `message.html`, barra de acciones | URL `/desktop/cose/atenciones/9` |
| Pestaña Historial | 17 entradas con fechas y cambios | Historial del ticket |
| Reclasificar a `OPERATIVO · Caída del servidor` | "Clasificación confirmado por Zammad", vigente actualizado | `categoria_subcategoria=caída_del_servidor`, `cose_categoria=OPERATIVO` |
| Guardar dominio `prueba.restaurant.pe` | "Dominio confirmado por Zammad" | `dominio=prueba.restaurant.pe` |
| Guardar nota desde el compositor | "Nota interna guardada confirmado por Zammad" | 3 artículos, 2 notas internas, texto persistido |

Las acciones solo muestran éxito tras la respuesta HTTP de Zammad. No se encontraron botones principales sin acción dentro del flujo probado.

### Captura

- `docs/atenciones-zammad/evidencias/01-bandeja-inicial.jpeg` — bandeja cargada con 4 tickets, contadores y filtros, vista sin seleccionar.
- No se pudo tomar una segunda captura con el ticket abierto: la API de captura del navegador informó que la ventana de escritorio no estaba visible. El estado con ticket abierto se verificó por DOM y se transcribe arriba; **no hay captura de ese estado**.

---

## 6. Seguridad del correo

- `services/politicaEnvio.ts` implementa la barrera. Valor por defecto: **`bloqueado`**. Solo se habilita con `VITE_COSE_ENVIO_CORREO=habilitado` (exacto, sin distinción de mayúsculas).
- En la UI, la pestaña «Responder por correo» muestra **«bloqueado»** y el botón «Enviar respuesta» queda deshabilitado; el mensaje indica el motivo y ofrece «Nota interna».
- `decidirEnvio` también exige destinatario y texto antes de permitir el envío.
- **No se realizó ningún envío.** Los artículos creados en las pruebas son `type=note`, `internal=true`. El ticket sigue teniendo un solo artículo `email`, el original recibido en Zammad.
- Para habilitar envíos más adelante, hace falta: (1) canal o buzón aislado de pruebas, (2) verificar que el destinatario es controlado, (3) fijar la variable de entorno, (4) ejecutar una sola prueba y confirmar el artículo creado. Hasta entonces la barrera permanece activa.

---

## 7. Brechas restantes

| Brecha | Detalle |
|---|---|
| Diseño responsive | Con el viewport disponible (~745 px) Zammad avisa "The desktop layout works best on wider screens" y el layout se apila: no se verificaron las tres columnas simultáneas a anchura de escritorio. La captura evidencia este estado |
| Referencia visual | `/mnt/data/image(20261117-212844).png` no existe; no hay comparación píxel a píxel con C.O.S.E. Atenciones |
| Envío de correo | Bloqueado y sin probar. Requiere canal aislado |
| Permisos | No probado con un usuario sin `ticket.agent` |
| Búsqueda | El filtro de texto es local sobre la página cargada; la API soporta `query`, pero la UI no lo envía |
| Paginación | Implementada con `page`/`per_page` y «Cargar más»; no ejercitada con más de 25 tickets (el entorno solo tiene 4) |
| Asignación | Solo «Asignar a mí»; falta asignar a otro agente desde la UI |
| Historial y actividad | Listas crudas; algunos valores son IDs de `assets` sin resolver a nombre |
| Adjuntos | Descarga verificada; sin vista previa en la pantalla |
| SLA | Aviso honesto de integración pendiente, sin métricas inventadas |
| Identidad por defecto | Atenciones aparece en el menú; el inicio sigue siendo el dashboard de Zammad |
| Base de datos | Queda un campo nuevo (`cose_categoria`) y datos de prueba modificados en el ticket 91009 |
| Producción | No se hizo migración productiva ni corte de Zendesk |

---

## 8. Estado Git y reversión

```
rama: main
HEAD: 80e0f313
sin commits, sin push, sin reset, sin clean, sin stash
5 entradas sin versionar:
  ?? app/assets/stylesheets/custom/99-cose-theme.css
  ?? app/frontend/apps/desktop/pages/cose-atenciones/
  ?? app/frontend/apps/desktop/styles/custom/99-cose-theme.css
  ?? app/frontend/apps/mobile/styles/custom/99-cose-theme.css
  ?? docs/atenciones-zammad/
```

Los tres CSS y `docs/atenciones-zammad/` ya existían antes de esta fase. No se modificó `C:\dev\mailing`, `docs/captures/`, `CategoryData.ts`, la base empresarial ni el catálogo original.

**Reversión:** eliminar `app/frontend/apps/desktop/pages/cose-atenciones/` retira la ruta y la entrada de menú sin tocar el núcleo. Para retirar el esquema, borrar el atributo `cose_categoria` (id 62) con la API de ObjectManager y ejecutar las migraciones de atributos; antes conviene decidir el destino de los valores registrados. La reversión de los datos de prueba del ticket 91009 es manual y no se realizó.

---

## 9. Instrucciones para iniciar y usar

```bash
# 1) Servicios (si no están ya corriendo), desde /home/acast/mailing:
bundle exec script/rails server -b 127.0.0.1 -p 3000
bundle exec script/vite-server.rb dev
bundle exec script/websocket-server.rb -b 127.0.0.1 -p 6042 start
bundle exec script/background-worker.rb start

# 2) Verificar:
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/   # 200

# 3) Navegar, con sesión de agente:
http://localhost:3000/desktop/cose/atenciones
```

Si se crea la carpeta de páginas con Zammad apagado, no hace falta ningún paso extra. Si Zammad ya estaba encendido, tocar `app/frontend/apps/desktop/router/index.ts` fuerza a Vite a reindexar el glob de rutas.

Uso: elegir una atención en la bandeja → leer la conversación y el adjunto → en el panel, fijar dominio y clasificación → en la cabecera, asignar / cambiar estado / resolver → «Nota interna» para registrar trabajo sin enviar correo.

---

## 10. Conclusión

Se ha demostrado un **flujo operativo real de extremo a extremo** contra un Zammad 7.2.3 en ejecución, con persistencia comprobada en la API y confirmaciones visibles en la interfaz. La versión candidata cumple el circuito prioritario pedido (bandeja → abrir → responder/classificar → asignar → resolver), con la salvedad de que «responder por correo» está deliberadamente bloqueado por seguridad.

**No se declara la plataforma terminada.** Para la aceptación faltan: canal de correo aislado y prueba de envío, comparación visual con la captura de referencia, verificación de permisos y del diseño a tres columnas en pantalla ancha, y build/type-check completos con memoria suficiente.

---

## 11. Cambios globales del 18/11/2026 (estado de verificación)

Se añadió la transformación global de la identidad C.O.S.E. descrita en `ENTREGA_PRESENTACION_ZAMMAD_COSE.md`:

| Cambio | Verificación disponible | Estado |
|---|---|---|
| Alias `/` en `cose-atenciones/routes.ts` | Navegación a `/desktop/` → título **«C.O.S.E - Atenciones»** y bandeja real | **VERIFICADO en navegador** |
| Entrada SLA con pantalla honesta | Botón `aria-label="SLA"` en la barra lateral → ruta `/desktop/cose/sla`, título «C.O.S.E - SLA», texto «Integración pendiente» y sin métricas | **VERIFICADO en navegador** |
| Identidad en los tres themes CSS | Fondo de la barra lateral `rgb(63, 74, 78)`; `::after` del encabezado calculado como `"C.O.S.E."`; botones de navegación `Atenciones` y `SLA` presentes | **VERIFICADO en navegador** |
| Tres columnas hasta 700 px | A 708 px: bandeja x=56/190 px, conversación x=246/242 px, panel x=488/220 px, todas con y=0. Conversación, adjunto `message.html` y nota visibles | **VERIFICADO en navegador** |

**Notas de la verificación del 18/11:**

- La sesión expiró al iniciar; el primer intento de login del usuario devolvió 502 por timeout del proxy (30 s) con Rails caliente y 395 MB libres. Tras reintentar, la sesión quedó activa (API `/users/me` → 200).
- La carga directa de una URL `/desktop/...` en una pestaña recién abierta mostró intermitentemente «Loading failed, please try again later»; un recargado o la navegación SPA desde la barra lateral resolvió el ingreso. No se identificó un error de consola ni una petición fallida asociada. Es un riesgo conocido para la presentación: **entrar por `/desktop/` y navegar desde el menú**.
- No se pudo tomar una segunda captura: la API de captura informó que la ventana de escritorio no estaba visible. La verificación visual se hizo por geometría, estilos computados y texto del DOM.
- No se modificó el ticket #91009 en esta entrega; solo se abrió para leer. Su estado sigue `closed` con la clasificación `OPERATIVO · Caída del servidor`.
- Apareció un ticket nuevo #91010 en la bandeja (5 tickets en total); no fue creado ni modificado por esta implementación.

Las pruebas y la persistencia del flujo del 17/11 siguen siendo válidas: el cambio fue de presentación y rutas, sin tocar la lógica de negocio ni los contratos de API.
