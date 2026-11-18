# ENTREGA PARA PRESENTACIÓN — ZAMMAD C.O.S.E.

**Fecha:** 18/11/2026
**Repositorio:** `/home/acast/mailing` (WSL), rama `main`, HEAD `80e0f313`, sin commits.
**Versión:** candidata presentable. No se declara reemplazo productivo de Zendesk.

---

## 1. Qué se transformó

| Elemento | Antes | Ahora |
|---|---|---|
| Identidad global | Temas C.O.S.E. solo como variables de color | Paleta naranja/charcoal aplicada a enlaces, encabezados, tablas, botones y selección en las tres capas (Vue desktop, Vue mobile y frontend clásico/login) |
| Barra lateral | Logo de Zammad | Marca de texto **C.O.S.E.** en la cabecera de la barra lateral, con borde naranja; elemento activo en naranja |
| Pantalla de entrada | Dashboard de Zammad | `Atenciones` registrada como alias `/` de la ruta Vue, antes del dashboard en el orden del glob |
| Navegación | Solo entradas nativas | **Atenciones** y **SLA** como entradas principales C.O.S.E.; SLA muestra estado honesto de integración pendiente |
| Bandeja | Tope fijo de 200 tickets | Paginación real (`page`/`per_page`) y «Cargar más» |
| Clasificación | Solo `value` del `tree_select` (ambiguo en 3 casos) | Par completo: hoja en `categoria_subcategoria` + categoría en `cose_categoria` |
| Dominio | Solo lectura | Campo editable y persistente en `dominio` |
| Historial | Pestaña vacía por contrato incorrecto | Lee `{history, assets}` y muestra los 17 eventos del ticket de prueba |
| Layout de Atenciones | Se apilaba por debajo de 1100 px | Tres columnas simultáneas hasta 700 px; por debajo, apilado |
| Correo | Envío directo | Barrera de salida: deshabilitado salvo `VITE_COSE_ENVIO_CORREO=habilitado` |

### Archivos nuevos o modificados en esta entrega

- `app/frontend/apps/desktop/pages/cose-atenciones/routes.ts` — alias `/` y navegación principal.
- `app/frontend/apps/desktop/pages/cose-atenciones/views/CoseAtencionesView.vue` — columnas y ancho del panel.
- `app/frontend/apps/desktop/pages/cose-sla/{routes.ts,views/CoseSlaView.vue}` — entrada SLA honesta.
- `app/frontend/apps/desktop/styles/custom/99-cose-theme.css` — identidad global del shell.
- `app/frontend/apps/mobile/styles/custom/99-cose-theme.css` — identidad global móvil.
- `app/assets/stylesheets/custom/99-cose-theme.css` — login y frontend clásico.

No se modificaron los 58 archivos de `docs/captures/`, `CategoryData.ts`, la fuente oficial del catálogo, las técnicas del motor SLA ni la base empresarial.

---

## 2. Qué funciona (evidencia previa, verificada el 17/11)

- Bandeja con tickets reales: `total_count=4`, búsqueda por término (`recap` → 91009).
- Selección de ticket, conversación con artículos originales y adjunto descargable (`message.html`, 34.844 bytes, HTTP 200).
- Asignación, dominio, clasificación y reclasificación del par ambiguo, nota interna, cambio de estado, resolución e historial: todos con respuesta de Zammad y persistencia comprobada en la API.
- Pestaña «Responder por correo» bloqueada; botón deshabilitado; **ningún correo enviado**.
- Pruebas: Vitest 20/20 + 3/3; `tsc --strict` y `vue-tsc` dirigido sin errores.
- Cambios de esta entrega: `vue-tsc` dirigido a `cose-atenciones` + `cose-sla` → **0 errores**; ambos módulos presentes en el router servido por Vite.

**Verificación visual de esta entrega global: realizada en navegador.** `/desktop/` abre Atenciones; la barra lateral muestra la marca C.O.S.E. y las entradas Atenciones/SLA; SLA muestra su estado honesto; con 708 px de ancho las tres columnas están simultáneas (190/242/220 px) y la conversación, el adjunto y la clasificación son visibles. No se pudo capturar pantalla porque la ventana de escritorio no estaba visible para la herramienta; la evidencia es geometría, estilos computados y texto del DOM. Detalle en `VALIDACION_FUNCIONAL_ATENCIONES_COSE.md`.

---

## 3. Cómo iniciar y URL exacta

```bash
cd /home/acast/mailing
bundle exec script/rails server -b 127.0.0.1 -p 3000
bundle exec script/vite-server.rb dev
bundle exec script/websocket-server.rb -b 127.0.0.1 -p 6042 start
bundle exec script/background-worker.rb start
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/   # debe dar 200
```

- **Acceso:** `http://localhost:3000/`
- **Atenciones directo:** `http://localhost:3000/desktop/cose/atenciones`
- **SLA:** `http://localhost:3000/desktop/cose/sla`
- **Nota:** `/cose/atenciones` sin el prefijo `/desktop` devuelve 404; Rails solo sirve el frontend Vue bajo `/desktop/*`.

El entorno ya tenía los servicios activos; no hace falta reiniciarlos para la presentación. Si se crean carpetas nuevas de páginas con Vite ya encendido, basta con tocar `app/frontend/apps/desktop/router/index.ts` para que reindexe el glob de rutas.

**Usuario de demostración:** `vcastagnino@restaurant.pe` (agente con rol Admin). Su contraseña no se comparte ni se guarda en este repositorio: debe introducirla quien presenta la sesión.

---

## 4. Guion de presentación (10–12 minutos)

1. **Identidad (1 min).** Abrir `http://localhost:3000/`, iniciar sesión y mostrar la barra lateral con la marca C.O.S.E., el naranja institucional y la entrada «Atenciones» como pantalla de entrada.
2. **Bandeja (2 min).** Mostrar los 4 tickets reales, contadores por estado, chips «Todas / Abiertas / Pendientes / Cerradas», filtro de canal y «Asignadas a mí». Escribir `recap` en el buscador y explicar que el filtrado es local sobre la página cargada.
3. **Abrir una atención (1 min).** Seleccionar un ticket de prueba verificado (no asumir el estado del #91009). Mostrar las tres columnas simultáneas.
4. **Conversación y adjuntos (2 min).** Recorrer los artículos originales de Zammad, abrir `message.html` desde el enlace nativo y explicar que el cuerpo HTML se sanea antes de mostrarse.
5. **Panel operativo (2 min).** Editar el dominio y guardarlo; elegir una categoría y subcategoría del catálogo oficial, guardar y mostrar que reaparece el par completo. Mencionar los tres valores duplicados resueltos con `cose_categoria`.
6. **Acciones (2 min).** Asignar a mí, agregar nota interna, cambiar estado, resolver. Señalar el mensaje de confirmación y el historial con cada cambio.
7. **Correo y SLA (1 min).** Mostrar la pestaña «Responder por correo» bloqueada y explicar la barrera; abrir «SLA» y mostrar el estado de integración pendiente sin métricas inventadas.
8. **Cierre (1 min).** Navegar a una pantalla administrativa nativa para demostrar que sigue funcionando con la identidad C.O.S.E.

**Escenario seguro:** usar solo tickets de prueba ya existentes y verificar su estado antes de modificarlos. No enviar correos. No usar datos de clientes reales como escenario.

---

## 5. Qué queda pendiente

| Pendiente | Impacto |
|---|---|
| Canal aislado para probar envío de correo | La respuesta sigue bloqueada; no se simula éxito |
| Captura de pantalla de la versión final | La herramienta no pudo capturar porque la ventana de escritorio no estaba visible; se sustituye por evidencia geométrica y de DOM |
| Comparación con la captura original de C.O.S.E. | El archivo indicado no existe en el entorno; no se afirma similitud píxel a píxel |
| Permisos con usuario sin `ticket.agent` | No probado; la API debe rechazar, no solo ocultar |
| `vue-tsc` completo y build de producción | Agotaron memoria/ no ejecutados; no son bloqueantes para la demostración local |
| «Cargar más» con más de 25 tickets | Implementado; el entorno solo tiene 4 |
| Asignar a otro agente desde la UI | Falta; la API lo soporta |

---

## 6. Riesgos conocidos

- La memoria disponible ronda los 500 MB. Ejecutar builds o pruebas pesadas en paralelo puede provocar otro OOM y terminar puma/websocket/worker. Si ocurre, restaurar con los comandos del §3.
- Existe un campo nuevo en la base local de desarrollo (`cose_categoria`, ObjectManager id 62) y datos de prueba en el ticket #91009. No es un cambio productivo.
- La ruta raíz `/` la disputan tres módulos (Atenciones, Dashboard y el overview nativo en DEV). **Verificado:** Atenciones gana la precedencia y `/desktop/` abre su bandeja.
- La carga directa de URLs `/desktop/...` en pestañas nuevas falló de forma intermitente con «Loading failed» sin error de consola; recargar o navegar desde el menú lo resuelve. Para la presentación, entrar por `/desktop/` y usar la navegación SPA.
- Las reglas globales de CSS son de presentación; no ocultan funcionalidades nativas. Si una regla afecta a una pantalla administrativa, retirar solo esa regla del bloque 7 del tema.
- `stylelint` sobre los tres archivos de tema reporta 75 incidencias de estilo (`color-hex-length`, `custom-property-empty-line-before`, etc.), preexistentes en esos archivos sin versionar. No son errores de sintaxis ni afectan a la ejecución; no se aplicó `--fix` para no sobrescribir el trabajo previo.

---

## 7. Preparación para reemplazar Zendesk

No se realizará corte productivo. Antes de proponerlo:

1. Completar la matriz de paridad funcional (Atenciones vs. Zendesk) con evidencia de cada operación.
2. Validar correo real con buzón aislado y confirmar entrega y reconstructibilidad del hilo.
3. Probar permisos por rol y auditoría de las operaciones sensibles.
4. Definir migración de tickets y adjuntos sin escrituras simultáneas sobre el mismo ticket.
5. Documentar reversión: la pantalla se retira borrando `pages/cose-atenciones/` y `pages/cose-sla/`; el campo `cose_categoria` se elimina con la API de ObjectManager.
6. Obtener aceptación formal de los asesores sobre la interfaz y los plazos SLA.

---

## 8. Estado Git final

```
rama: main
HEAD: 80e0f313
sin commits, sin push, sin reset, sin clean, sin stash
```

Entradas sin versionar: los tres CSS `99-cose-theme.css`, la carpeta `pages/cose-atenciones/`, la carpeta `pages/cose-sla/` y `docs/atenciones-zammad/`.
