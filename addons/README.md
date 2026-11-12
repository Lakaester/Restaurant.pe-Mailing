# MAILING — Addons

Esta carpeta contiene las personalizaciones de Mailing. Todo lo que sea propio
del proyecto debe vivir aquí y **no** dentro del núcleo de Zammad.

## Regla principal

El núcleo de Zammad (todo lo que está fuera de `addons/`) se mantiene sin
cambios. Así se puede actualizar Zammad en el futuro sin perder trabajo.

## Cómo funciona

Zammad admite paquetes de extensión con extensión `.szpm`. Un addon puede:

- Añadir o modificar pantallas de la interfaz nueva (Vue 3).
- Añadir campos, automatizaciones o lógica propia.
- Extenderse sin sobrescribir archivos del núcleo: los cambios de interfaz se
  aplican en tiempo de compilación, no editando los archivos originales.

## Estructura prevista

```text
addons/
  mailing-core/          # Base común de Mailing
    <archivos del addon>
    <nombre>.weave.mjs   # Reglas de extensión de la interfaz (opcional)
```

## Pendiente de definir

- Nombre definitivo del primer addon.
- Qué personalizaciones van en el addon y cuáles bastan con configuración
  normal de Zammad (grupos, estados, SLA, disparadores, plantillas).

Consulta `docs/` para las decisiones del proyecto.
