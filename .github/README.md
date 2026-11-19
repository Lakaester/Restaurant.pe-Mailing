# Restaurant.pe — Mailing (C.O.S.E.)

Plataforma interna de atención por correo electrónico del **Centro de Operaciones
de Soporte Especializado (C.O.S.E.)** de Restaurant.pe.

Está construida sobre **[Zammad](https://github.com/zammad/zammad) 7.2.3**
(AGPL-3.0) con una capa de personalización propia: tema visual C.O.S.E.,
cabecera de navegación y las vistas de **Atenciones** y **SLA** en la interfaz
de escritorio (Vue 3).

> Repositorio **privado** de uso interno. No contiene credenciales: la
> configuración real (base de datos, buzones, tokens) vive solo en cada equipo
> o servidor. Ver [Seguridad](#seguridad).

## Estado

| Área | Estado |
|---|---|
| Núcleo Zammad 7.2.3 | Verificado byte a byte contra el tag oficial `7.2.3` |
| Tema visual C.O.S.E. | Implementado (escritorio, móvil y vista clásica) |
| Vista de Atenciones | Implementada; pruebas unitarias 23/23 |
| Vista de SLA | Esqueleto de interfaz; motor SLA en diseño |
| Motor SLA (backend) | Diseño y SQL de esquema documentados; sin desplegar |

## Ramas

| Rama | Contenido |
|---|---|
| `main` | Zammad 7.2.3 oficial + correcciones de permisos y enlaces simbólicos para Linux |
| `cose/personalizaciones` | Desarrollo de C.O.S.E. sobre `main` |

## Estructura propia del proyecto

Todo lo que no aparece aquí es código original de Zammad 7.2.3.

```text
app/frontend/apps/desktop/
  components/layout/cose/            Cabecera C.O.S.E.
  pages/cose-atenciones/             Vista de Atenciones (servicios, catálogo, pruebas)
  pages/cose-sla/                    Vista de SLA
  styles/custom/99-cose-theme.css    Tema escritorio
app/frontend/apps/mobile/styles/custom/99-cose-theme.css
app/assets/stylesheets/custom/99-cose-theme.css   Tema de la interfaz clásica
public/cose/                         Logotipos
public/assets/fonts/montserrat-*     Tipografía Montserrat (SIL OFL 1.1)
docs/                                Documentación del proyecto (empezar por docs/README.md)
addons/README.md                     Reglas para futuros addons
```

Archivos del núcleo de Zammad modificados (parches que se revisan en cada
actualización): ver [`docs/UPSTREAM.md`](../docs/UPSTREAM.md).

## Desarrollo local (Ubuntu / WSL2)

Requisitos: Ruby (ver `.ruby-version`), Node.js + pnpm, PostgreSQL y Redis.

```bash
cp config/database/database.yml config/database.yml   # completar credenciales locales
bundle install
pnpm install
bundle exec rails db:create db:migrate db:seed
bin/dev                                               # Rails + Vite + worker
```

La vista de Atenciones queda en `http://localhost:3000/desktop/cose/atenciones`.

Pruebas y lint del código C.O.S.E.:

```bash
pnpm test --run app/frontend/apps/desktop/pages/cose-atenciones
npx oxlint app/frontend/apps/desktop/pages/cose-atenciones app/frontend/apps/desktop/pages/cose-sla app/frontend/apps/desktop/components/layout/cose
```

## Seguridad

- Nunca se versionan `config/database.yml`, `.env*`, claves, dumps ni backups
  (ver sección `MAILING` de `.gitignore`).
- Las capturas de evidencia (`docs/**/evidencias/`) contienen datos reales de
  clientes y se mantienen solo en local.
- Los datos de infraestructura de producción se escriben en los documentos como
  marcadores (`<IP_BD_PRODUCCION>`); el valor real se entrega por canal seguro.
- Los workflows de GitHub Actions heredados de Zammad (CI completa, Docker y
  publicación de paquetes) están deshabilitados en este repositorio; solo corre
  `cose-ci.yml`, una CI ligera del código C.O.S.E. Ver
  [`docs/GITHUB_ACTIONS.md`](../docs/GITHUB_ACTIONS.md).

Auditoría de publicación: [`docs/AUDITORIA_PUBLICACION_GITHUB.md`](../docs/AUDITORIA_PUBLICACION_GITHUB.md).

## Licencia

Zammad se distribuye bajo **GNU AGPL-3.0** (`LICENSE`). Las modificaciones de
este repositorio son obra derivada y quedan bajo la misma licencia. Si Mailing
se ofrece a usuarios a través de una red, la AGPL obliga a poner el código
fuente modificado a disposición de esos usuarios; al ser uso interno de
Restaurant.pe, la validación legal sigue pendiente (ver `docs/decisiones.md`).
El README original de Zammad está en [`/README.md`](../README.md).
