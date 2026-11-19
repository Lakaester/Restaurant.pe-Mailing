// Copyright (C) 2012-2026 Zammad Foundation, https://zammad-foundation.org/

/* eslint-disable zammad/zammad-detect-translatable-string --
   C.O.S.E. es una interfaz solo en español y sus textos/valores de catálogo no
   forman parte del catálogo de traducción de Zammad (fuente en inglés). Ver
   docs/decisiones.md (D-010). */

/**
 * Catálogo oficial de C.O.S.E. (13 categorías, 65 subcategorías).
 * GENERADO desde backend/src/domain/sla/catalogo/catalogo-oficial.json
 * (sha256 de la fuente: 55cec0dea77edbb462021c2a63bbac50694428125ddb20869cddecb020d9e97e). No editar a mano.
 *
 * Identidad: el par categoría + subcategoría. El `value` es el identificador
 * usado en el atributo `categoria_subcategoria`; tres valores se repiten entre
 * categorías, por lo que nunca debe inferirse la categoría desde el `value`.
 */

export interface CatalogoSubcategoria {
  label: string
  value: string
}

export interface CatalogoCategoria {
  categoria: string
  subcategorias: CatalogoSubcategoria[]
}

export const CATALOGO_COSE: CatalogoCategoria[] = [
  {
    "categoria": "FACTURACIÓN ELECTRÓNICA",
    "subcategorias": [
      {
        "label": "Activacion NV",
        "value": "activacion_nv"
      },
      {
        "label": "Ajustes FE",
        "value": "ajustes_fe"
      },
      {
        "label": "Cambio de razón social",
        "value": "cambio_de_razón_social"
      },
      {
        "label": "Cambio impuesto FE",
        "value": "cambio_impuesto_fe"
      },
      {
        "label": "Activacion FE",
        "value": "activacion_fe"
      },
      {
        "label": "Emisión de invoice",
        "value": "emisión_de_invoice_o_factura"
      },
      {
        "label": "Requisitos FE",
        "value": "requisitos_fe"
      },
      {
        "label": "Error FE del facturador",
        "value": "error_fe_del_facturador_o_ente_regulador"
      },
      {
        "label": "Error FE de cálculo",
        "value": "error_fe_de_cálculo"
      },
      {
        "label": "Error FE por duplicidad",
        "value": "error_fe_por_duplicidad"
      },
      {
        "label": "Error FE envio manual",
        "value": "error_fe_envio_manual_postman"
      },
      {
        "label": "Consecutivos topes folios",
        "value": "consecutivos_topes_folios"
      },
      {
        "label": "FE solicitud xml pdf",
        "value": "fe_solicitud_xml_pdf"
      },
      {
        "label": "Validación de comprobantes FE",
        "value": "validación_de_comprobantes_fe"
      }
    ]
  },
  {
    "categoria": "LOGÍSTICA",
    "subcategorias": [
      {
        "label": "Capacitación logistica avanzado",
        "value": "capacitación_logistica_avanzado"
      },
      {
        "label": "Capacitación logistica insumos recetas",
        "value": "capacitación_logistica_insumos_recetas"
      },
      {
        "label": "Tarea o capacitación logistica",
        "value": "tarea_o_capacitación_logistica"
      },
      {
        "label": "Temas operativos punto de venta",
        "value": "temas_operativos_punto_de_venta"
      },
      {
        "label": "Error logistica",
        "value": "error_logistica"
      }
    ]
  },
  {
    "categoria": "INTEGRACIONES",
    "subcategorias": [
      {
        "label": "Solicitud de integracion rappi",
        "value": "solicitud_de_integración_rappi"
      },
      {
        "label": "Solicitud de integracion Pedidos ya",
        "value": "solicitud_de_integración_pedidos_ya"
      },
      {
        "label": "Solicitud de integracion uber",
        "value": "solicitud_de_integración_uber"
      },
      {
        "label": "Integraciones y apis",
        "value": "integraciones_y_apis"
      },
      {
        "label": "Consulta consumo de apis",
        "value": "consulta_consumo_de_apis"
      },
      {
        "label": "Error integracion",
        "value": "error_integracion"
      },
      {
        "label": "Solicitud de integracion sistemas contables",
        "value": "solicitud_de_integración_sistemas_contables"
      }
    ]
  },
  {
    "categoria": "SOFTWARE",
    "subcategorias": [
      {
        "label": "Error punto de venta",
        "value": "error_punto_de_venta"
      },
      {
        "label": "Error web",
        "value": "error_web"
      },
      {
        "label": "Error backend",
        "value": "error_backend"
      },
      {
        "label": "Mejora personalizada",
        "value": "mejora_personalizada"
      },
      {
        "label": "Seguimiento de errores",
        "value": "seguimiento_de_errores"
      },
      {
        "label": "Error add on asistencias",
        "value": "error_add_on_asistencias"
      }
    ]
  },
  {
    "categoria": "GESTIÓN",
    "subcategorias": [
      {
        "label": "Seguimiento proactivo",
        "value": "seguimiento_proactivo"
      },
      {
        "label": "Seguimiento de cdt",
        "value": "seguimiento_de_cdt"
      },
      {
        "label": "Renovación certificado normal",
        "value": "renovación_certificado_normal"
      },
      {
        "label": "Venta de CDT certificado",
        "value": "venta_de_cdt_certificado"
      },
      {
        "label": "Envio de pago",
        "value": "envio_de_pago"
      },
      {
        "label": "Pagos prorrogas descuentos",
        "value": "pagos__prorrogas__descuentos"
      }
    ]
  },
  {
    "categoria": "ADMINISTRATIVO",
    "subcategorias": [
      {
        "label": "Nueva licencia o sucursal",
        "value": "nueva_licencia_o_sucursal"
      },
      {
        "label": "Baja sucursal",
        "value": "baja_sucursal"
      },
      {
        "label": "Cambio de razón social",
        "value": "cambio_de_razón_social"
      },
      {
        "label": "Temas administrativos",
        "value": "temas_administrativos_o_configuraciones_del_sistema"
      },
      {
        "label": "Solicitud de migración",
        "value": "solicitud_de_migración"
      },
      {
        "label": "Activación de Addons",
        "value": "activación_de_addons"
      }
    ]
  },
  {
    "categoria": "OPERATIVO",
    "subcategorias": [
      {
        "label": "Temas operativos",
        "value": "temas_operativos"
      },
      {
        "label": "Cajas",
        "value": "cajas"
      },
      {
        "label": "Redes y conexiones",
        "value": "redes_y_conexiones"
      },
      {
        "label": "Caída del servidor",
        "value": "caída_del_servidor"
      }
    ]
  },
  {
    "categoria": "CAPACITACIÓN",
    "subcategorias": [
      {
        "label": "Capacitación logistica",
        "value": "capacitación_logistica"
      },
      {
        "label": "Capacitación integraciones",
        "value": "capacitación_integraciones"
      },
      {
        "label": "Capacitación adm Reportes",
        "value": "capacitación_adm_reportes"
      },
      {
        "label": "Capacitación adm Productos",
        "value": "capacitación_adm_productos"
      },
      {
        "label": "Capacitación operativa",
        "value": "capacitación_operativa"
      },
      {
        "label": "Capacitación delivery pro",
        "value": "capacitación_delivery_pro"
      },
      {
        "label": "Solicitud agenda capacitación",
        "value": "solicitud_agenda_capacitación"
      }
    ]
  },
  {
    "categoria": "SERVIDOR",
    "subcategorias": [
      {
        "label": "Caída del servidor",
        "value": "caída_del_servidor"
      },
      {
        "label": "Redes y conexiones",
        "value": "redes_y_conexiones"
      }
    ]
  },
  {
    "categoria": "SIN HOMOLOGAR",
    "subcategorias": [
      {
        "label": "Sin dato",
        "value": "sin_dato"
      },
      {
        "label": "Duplicado o spam",
        "value": "duplicado_o_spam"
      },
      {
        "label": "No contestó",
        "value": "no_contestó"
      }
    ]
  },
  {
    "categoria": "RECLAMO",
    "subcategorias": [
      {
        "label": "Reclamo",
        "value": "reclamo"
      }
    ]
  },
  {
    "categoria": "QUEJA",
    "subcategorias": [
      {
        "label": "Servicio",
        "value": "queja_servicio"
      },
      {
        "label": "Producto",
        "value": "queja_producto"
      },
      {
        "label": "Otro",
        "value": "queja_otro"
      }
    ]
  },
  {
    "categoria": "DEVOLUCIÓN",
    "subcategorias": [
      {
        "label": "Solicitud de devolución",
        "value": "solicitud_de_devolución"
      }
    ]
  }
]
