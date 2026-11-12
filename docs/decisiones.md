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

## Pendientes de decisión

| Tema | Estado |
|---|---|
| Repositorio remoto privado (GitHub u otro) | Sin autorizar |
| Entorno local de ejecución (WSL2, contenedor o servidor) | En evaluación |
| Elasticsearch en local y en producción | Pendiente |
| Validación legal de la licencia AGPL-3.0 | Pendiente |
| Dominio definitivo de Mailing | Pendiente |
| Primer addon y alcance funcional | Pendiente |
