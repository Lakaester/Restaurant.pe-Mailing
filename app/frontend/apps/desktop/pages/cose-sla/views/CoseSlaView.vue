<!-- Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="cose-sla">
    <header class="cose-sla__cabecera">
      <div>
        <p class="cose-sla__eyebrow">C.O.S.E. · Restaurant.pe</p>
        <h1>SLA</h1>
      </div>
      <span class="cose-sla__estado">Integración pendiente</span>
    </header>

    <section class="cose-sla__tarjeta">
      <h2>El motor SLA no está conectado a Zammad</h2>
      <p>
        La medición de plazos de primera respuesta y resolución es responsabilidad del motor SLA
        propio de C.O.S.E. La arquitectura prevista es
        <strong>Zammad → API/BFF → motor SLA de C.O.S.E.</strong>
      </p>
      <p class="cose-sla__aviso">
        Esta vista no muestra plazos, porcentajes ni semáforos: no existe una fuente de datos
        conectada y no se van a inventar métricas. No se aplican políticas SLA nativas de Zammad.
      </p>

      <dl class="cose-sla__datos">
        <dt>Datos que se mostrarán cuando exista integración</dt>
        <dd>Estado SLA · tiempo transcurrido · tiempo restante · vencimiento</dd>
        <dt>Primera respuesta</dt>
        <dd>Pendiente del motor</dd>
        <dt>Resolución</dt>
        <dd>Pendiente del motor</dd>
        <dt>Incumplimiento</dt>
        <dd>Pendiente del motor</dd>
      </dl>

      <button type="button" class="cose-sla__btn" @click="router.push({ name: 'CoseAtenciones' })">
        Volver a Atenciones
      </button>
    </section>
  </div>
</template>

<style scoped>
.cose-sla {
  --sla-primary: var(--cose-primary, #b45309);
  --sla-primary-10: var(--cose-primary-10, #fde8d7);
  --sla-text: var(--cose-text, #4c5b5f);
  --sla-muted: var(--cose-text-muted, #6e7678);
  --sla-border: var(--cose-border, #e1e5e6);
  --sla-bg: var(--cose-bg, #f5f6f5);

  height: 100%;
  overflow-y: auto;
  padding: 24px;
  background: var(--sla-bg);
  color: var(--sla-text);
}

.cose-sla__cabecera {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.cose-sla__eyebrow {
  margin: 0;
  color: var(--sla-primary);
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.cose-sla__cabecera h1 {
  margin: 4px 0 0;
  font-size: 26px;
}

.cose-sla__estado {
  border: 1px solid var(--sla-primary);
  background: var(--sla-primary-10);
  color: var(--sla-primary);
  border-radius: 999px;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 600;
}

.cose-sla__tarjeta {
  max-width: 760px;
  background: #fff;
  border: 1px solid var(--sla-border);
  border-radius: 12px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cose-sla__tarjeta h2 {
  margin: 0;
  font-size: 18px;
}

.cose-sla__aviso {
  border-left: 3px solid var(--sla-primary);
  background: var(--sla-primary-10);
  padding: 10px 12px;
  margin: 0;
}

.cose-sla__datos {
  display: grid;
  grid-template-columns: max-content 1fr;
  gap: 8px 16px;
  margin: 8px 0;
}

.cose-sla__datos dt {
  color: var(--sla-muted);
}

.cose-sla__datos dd {
  margin: 0;
}

.cose-sla__btn {
  align-self: flex-start;
  border: 1px solid var(--sla-primary);
  background: var(--sla-primary);
  color: #fff;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
  font: inherit;
}
</style>
