// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

import { describe, expect, it } from 'vitest'
import { parse } from 'vue/compiler-sfc'

import { weaveSource } from '../../../../../../build/addonWeave/plugin.mjs'
import { addonWeaveRules } from '../cose-layout.weave.mjs'

// Fuente prístina del núcleo (Zammad 7.2.3, sin modificar en disco).
const coreSource = (relative: string) =>
  readFileSync(resolve(__dirname, '../../../../', relative), 'utf8')

const weaveCore = (relative: string) => {
  const rule = addonWeaveRules.find((candidate) => candidate.target.endsWith(relative))
  if (!rule) throw new Error(`Sin regla C.O.S.E. para ${relative}`)
  const woven = weaveSource(coreSource(relative), rule, relative)
  const { descriptor, errors } = parse(woven, { filename: relative })
  expect(errors).toHaveLength(0)
  return { woven, descriptor }
}

describe('C.O.S.E. — weave del layout de escritorio', () => {
  it('declara exactamente dos reglas, una por archivo del núcleo', () => {
    expect(addonWeaveRules.map((rule) => rule.target)).toEqual([
      'apps/desktop/components/layout/LayoutPage.vue',
      'apps/desktop/components/layout/LayoutSidebar/LeftSidebar/LeftSidebarHeader.vue',
    ])
  })

  describe('LayoutPage.vue', () => {
    const { woven, descriptor } = weaveCore('components/layout/LayoutPage.vue')

    it('envuelve la rejilla en un contenedor en columna con la cabecera C.O.S.E. primero', () => {
      const root = descriptor.template!.ast.children.find((node) => node.type === 1)
      expect(root).toMatchObject({ tag: 'div' })
      // @ts-expect-error -- nodo de elemento del AST de plantilla
      const [header, grid] = root.children.filter((node) => node.type === 1)
      expect(header.tag).toBe('CoseHeader')
      expect(grid.tag).toBe('div')
      expect(woven).toContain('data-test-id="cose-layout"')
    })

    it('mantiene la rejilla original de Zammad ocupando el alto restante', () => {
      expect(woven).toMatch(/class="grid min-h-0 flex-1 grid-cols-\(--grid-columns\)/)
      expect(woven).toContain('grid-rows-[minmax(0,1fr)]')
      expect(woven).toContain(':style="{')
    })

    it('permite que el contenido principal se encoja', () => {
      expect(woven).toMatch(/id="main-content"\s+class="relative min-h-0 overflow-hidden"/)
    })

    it('importa la cabecera y fija el estado inicial de la navegación', () => {
      expect(descriptor.scriptSetup!.content).toContain(
        "import CoseHeader from '#desktop/components/layout/cose/CoseHeader.vue'",
      )
      expect(descriptor.scriptSetup!.content).toContain(
        "togglePrimaryNavSidebar(isSmallestScreen.value, { storage: 'session' })",
      )
    })
  })

  describe('LeftSidebarHeader.vue', () => {
    const { woven } = weaveCore('components/layout/LayoutSidebar/LeftSidebar/LeftSidebarHeader.vue')

    it('sustituye el icono de Zammad por el logo C.O.S.E.', () => {
      expect(woven).not.toMatch(/<CommonIcon\s+name="logo"/)
      expect(woven).toContain('<img :src="__coseLogoIcono" alt="C.O.S.E."')
      expect(woven).toContain("const __coseLogoIcono = '/cose/logo-icono.png'")
    })
  })
})
