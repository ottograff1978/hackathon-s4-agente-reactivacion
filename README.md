# 🤖 Agente de Reactivación Comercial
### Hackathon S4 · Curso Claude para Productividad

## ¿Qué hace?

Este agente lee una tabla de clientes en Supabase, identifica los que llevan **más de 30 días sin contacto**, redacta mensajes de reactivación personalizados, los **auto-verifica** antes de guardarlos y registra cada corrida en una tabla de bitácora.

## Carriles completados

| Carril | Descripción | Estado |
|--------|-------------|--------|
| **Carril 1 · Fundamentos** | Lee Supabase → filtra (+30 días) → redacta → guarda | ✅ |
| **Carril 2 · Verificación** | Loop de auto-revisión con 2 reglas de calidad antes de guardar | ✅ |
| **Carril 3 · Autónomo** | Se dispara solo cada día a las 9 am con /schedule de Cowork | ✅ |

## Flujo del agente

```
Supabase (cuentas)
  └── estatus_agente = pendiente
        └── dias_sin_contacto > 30
              └── Redactar mensaje personalizado
                    └── Verificar: ≤90 palabras + tono cálido + sin frases acartonadas
                          ├── ✅ Aprobado → guardar (verificado=true)
                          └── ❌ Falla → reescribir (máx 2 intentos) → guardar
                                └── Registrar corrida en tabla corridas
```

## Reglas de verificación (Carril 2)

- **Regla 1:** el mensaje no supera 90 palabras y no contiene frases acartonadas como "estimado cliente", "lamentamos profundamente", "sinergias" o "valor agregado".
- **Regla 2:** el tono es cálido y natural, no robótico ni corporativo.
- Si falla, se reescribe y re-verifica. Máximo 2 intentos.

## Columnas que actualiza en Supabase

| Columna | Qué guarda |
|---------|-----------|
| mensaje_generado | El texto final del mensaje |
| estatus_agente | Cambia de pendiente a contactado |
| verificado | true si pasó la verificación |
| intentos | 1 si aprobó directo, 2 si necesitó reescritura |
| notas_verificacion | Qué se corrigió (auditoría) |

## Configuración

1. Crea tu proyecto en Supabase y ejecuta schema.sql
2. Copia .env.example a .env y llena tus credenciales
3. Otorga permisos: GRANT SELECT, UPDATE ON public.cuentas TO anon;
4. En Cowork, usa el prompt de agente_prompt.md con /schedule

## Tecnologías

- Claude (Cowork) — redacción, verificación y automatización
- Supabase — base de datos PostgreSQL en la nube
- Claude /schedule — disparo automático diario sin servidores adicionales
