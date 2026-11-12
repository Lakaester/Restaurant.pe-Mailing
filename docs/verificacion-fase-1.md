# Verificación del código base — Fase 1

Fecha: 12 de noviembre de 2026
Estado: **verificación satisfactoria**

## Resumen

La copia original descargada en el Escritorio es **idéntica byte a byte** al
archivo oficial del tag `7.2.3` publicado en GitHub. No hay archivos alterados,
faltantes ni sobrantes.

## Método

1. Se descargó el archivo oficial del tag:
   `https://github.com/zammad/zammad/archive/refs/tags/7.2.3.zip`
2. Se calculó el SHA-256 del archivo descargado:
   `30F9C4D2374A7D6B0AB04B6D0D2228D9487499C88125D6CBA3CC303BCA033EBC`
3. Se calculó el SHA-256 de **cada archivo** de la copia original y se comparó
   con el SHA-256 del mismo archivo dentro del ZIP oficial.

## Resultado

| Concepto | Cantidad |
|---|---|
| Archivos en el ZIP oficial | 14.074 |
| Coinciden byte a byte (SHA-256) | **14.074** |
| Archivos con contenido distinto | 0 |
| Archivos faltantes | 0 |
| Archivos sobrantes | 0 |

La misma comprobación se repitió sobre la copia de trabajo `C:\dev\mailing`
después de copiarla, con resultado idéntico: 14.074 coincidencias.

## Versión

- `VERSION` del repositorio: `7.2.3`
- `CHANGELOG.md`: corresponde a Zammad 7.2.3
- Tag oficial: `7.2.3`, commit `d3f316a`
- Firma del tag: verificada por GitHub, autor Florian Liebe (mantenedor)

## Notas técnicas

- La carpeta original no incluye el historial de Git (`.git`), por lo que la
  comprobación se hizo contra el archivo del tag, no contra el historial.
- Al copiar en Windows aparecieron dos limitaciones conocidas: rutas de más de
  260 caracteres y enlaces simbólicos. Ninguna afecta al contenido: la
  verificación se hizo leyendo directamente desde el ZIP oficial.
- La carpeta original en OneDrive **no fue modificada**.
