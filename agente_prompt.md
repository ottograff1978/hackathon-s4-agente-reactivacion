# Prompt del Agente de Reactivación (Carril 3 · Autónomo)

Este es el prompt autocontenido que Cowork ejecuta automáticamente cada día a las 9 am.
Las credenciales se leen del archivo `.env` (nunca se hardcodean aquí).

---

## Objetivo

Leer la tabla `cuentas` en Supabase, identificar clientes sin contacto por más de 30 días,
redactar mensajes de reactivación personalizados, verificarlos con reglas de calidad,
guardarlos en Supabase y registrar la corrida en la tabla `corridas`.

## Paso 1 — Leer cuentas pendientes

GET `{SUPABASE_URL}cuentas?select=id,empresa,contacto,email,ultimo_contacto&estatus_agente=eq.pendiente`
Headers: apikey y Authorization Bearer con SUPABASE_KEY.

## Paso 2 — Filtrar más de 30 días sin contacto

Calcular días desde hoy. Conservar solo registros con más de 30 días.
Las cuentas recientes (≤30 días) se saltan sin modificar.

## Paso 3 — Redactar y verificar cada mensaje

Para cada cuenta filtrada:
1. Redactar un mensaje cálido y personalizado con nombre del contacto y empresa (máximo 90 palabras).
2. Verificar con dos reglas:
   - Regla 1: ≤90 palabras Y sin frases acartonadas
     ("estimado cliente", "lamentamos profundamente", "sinergias", "valor agregado", "a su disposición").
   - Regla 2: tono cálido y humano, no robótico ni corporativo.
3. Si falla: reescribir y re-verificar (máximo 2 intentos).

## Paso 4 — Guardar en Supabase

PATCH `cuentas?id=eq.{id}` con:
- mensaje_generado: texto final aprobado
- estatus_agente: "contactado"
- verificado: true
- intentos: 1 o 2
- notas_verificacion: qué se corrigió o "Aprobado en primer intento"
- updated_at: timestamp actual

## Paso 5 — Registrar corrida

POST a `corridas` con:
- carril: "autonomo"
- cuentas_procesadas: total con +30 días
- cuentas_contactadas: total de PATCHes exitosos
- disparador: "schedule" (si fue automático) o "manual"

## Paso 6 — Reportar

Mostrar resumen: cuentas procesadas, cuántas se reescribieron, confirmación de corrida registrada.
