PROYECTO 5 - E-Commerce Logistics BI
=====================================

PERSPECTIVA OPERACIONES
------------------------
P1 — Warehouse block con mayor retraso:
→ Hallazgo: todos los warehouses tienen tasa similar (58-60%)
→ Insight: problema sistémico, no de un warehouse específico
→ Recomendación: 

SELECT 
    Warehouse_block,
    COUNT(*) AS total_shipments,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM [E-commerce data]
GROUP BY Warehouse_block
ORDER BY delay_rate_pct DESC;

P2 — Modo de envío más confiable:
→ Hallazgo: Road 58.81% / Ship 59.76% / Flight 60.16%
→ Insight: ningún modo de envío es significativamente mejor
→ Conexión con P1: junto con warehouses, confirma problema sistémico
→ Dato extra: Ship concentra el 67% del volumen total (7.462 envíos)

SELECT 
    Mode_of_Shipment,
    COUNT(*) AS total_shipments,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate
FROM [E-commerce data]
GROUP BY Mode_of_Shipment
ORDER BY delay_rate DESC


P3 — Impacto del peso en retrasos:
→ Hallazgo: rango 2.5-4kg tiene 99.9% de retraso (1.334 de 1.335 envíos)
→ Rango Heavy (4-6kg) solo 43.12% - el mejor desempeño
→ Insight: el peso SÍ es un factor crítico, pero no de forma lineal
→ Recomendación: investigar procesos específicos para productos 2.5-4kg
→ Lección técnica: siempre explorar MIN/MAX/AVG antes de definir rangos CASE WHEN
→ Patrón adicional: a menor volumen de envíos, mayor tasa de retraso
→ Implicación: la operación está optimizada para Heavy (4-6kg) que concentra el 54% del volumen total

SELECT 
    CASE 
        WHEN [Weight_in_gms] < 2500 THEN 'Light (< 2.5kg)'
        WHEN [Weight_in_gms] BETWEEN 2500 AND 4000 THEN 'Medium (2.5-4kg)'
        WHEN [Weight_in_gms] BETWEEN 4000 AND 6000 THEN 'Heavy (4-6kg)'
        ELSE 'Very Heavy (> 6kg)'
    END AS weight_category,
    COUNT(*) AS total_shipments,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM [E-commerce data]
GROUP BY weight_category
ORDER BY delay_rate_pct DESC


P4 — Impacto del descuento en retrasos:
→ Hallazgo: descuento > 10% = 100% tasa de retraso (sin excepción)
→ Descuento 1-10% = 46.89% de retraso
→ Insight: la política de descuentos es el factor más correlacionado con retrasos encontrado hasta ahora
→ Recomendación: revisar si los productos con alto descuento son los mismos del rango 2.5-4kg (posible doble problema)
→ Pregunta para el negocio: ¿los descuentos altos se aplican en temporadas de alto volumen?

SELECT CASE WHEN [Discount_offered] = 0 THEN 'No discount'
            WHEN [Discount_offered] BETWEEN 1 AND 10 THEN 'Low(1-10%)'
			WHEN [Discount_offered] BETWEEN 11 AND 30 THEN 'Medium(11-30%)'
			WHEN [Discount_offered] between 31 AND 50 THEN 'High(31-50%)'
			ELSE 'Very high(>50%)'
		END AS Discount_category,
		COUNT(*) AS Total_shipments,
		SUM([Reached.on.Time_Y.N]) AS delayed,
        ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate
FROM [E-commerce data]
GROUP BY discount_category
ORDER BY delay_rate DESC


P5 — Llamadas al cliente vs rating y retrasos:
→ Hallazgo 1: rating promedio igual en todos los segmentos (≈3.0)
→ Hallazgo 2: más llamadas = menor tasa de retraso (65% low vs 51% very high)
→ Insight: las llamadas no mejoran satisfacción pero sí generan priorización informal de pedidos
→ Recomendación: implementar sistema de priorización formal para eliminar dependencia de presión del cliente
→ Riesgo: clientes que no llaman están siendo sistemáticamente desatendidos

SELECT CASE WHEN [Customer_care_calls] BETWEEN 1 AND 2 THEN 'Low (1-2 calls)'
                           WHEN [Customer_care_calls] BETWEEN 3 AND 4 THEN 'Medium (3-4 calls)'
                           WHEN [Customer_care_calls] BETWEEN 5 AND 6 THEN 'High (5-6 calls)'
                           ELSE 'Very High (> 6 calls)'
                END AS call_category,
    COUNT(*) AS total_customers,
    ROUND(AVG(CAST([Customer_rating] AS FLOAT)), 2) AS avg_rating,
    ROUND(AVG(CAST([Customer_care_calls] AS FLOAT)), 2) AS avg_calls,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate
FROM [E-commerce data]
GROUP BY call_category
ORDER BY avg_calls DESC


P6 — Importancia del producto vs retrasos:
→ Hallazgo: High importance = 64.98% retraso (el peor)
→ Medium = 59.05% / Low = 59.28% (similares entre sí)
→ Rating promedio igual en todos los niveles (≈3.0)
→ Insight: el sistema de priorización por importancia no funciona
→ Recomendación: integrar flag de importancia en el proceso operacional de despacho, no solo en el sistema comercial
→ Conexión con P5: ni las llamadas ni la importancia garantizan  mejor servicio, el sistema opera sin priorización efectiva

SELECT [Product_importance],
    COUNT(*) AS total_shipments,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate,
    ROUND(AVG(CAST([Customer_rating] AS FLOAT)), 2) AS avg_rating
FROM [E-commerce data]
GROUP BY [Product_importance]
ORDER BY delay_rate ASC


P7 — Compras previas vs retrasos:
→ Hallazgo: clientes frecuentes (7+) tienen 62.67% retraso
→ Clientes nuevos (2-3) tienen 63.46% - prácticamente igual
→ Solo Medium (4-6) muestra mejora leve: 53.14%
→ Insight: no existe programa de fidelización operacional
→ Recomendación: implementar priorización para clientes frecuentes
→ Riesgo: clientes con pocas recompras probablemente abandonaron por mal servicio previo - dato no visible en este dataset

SELECT CASE WHEN [Prior_purchases] BETWEEN 2 AND 3 THEN 'Low (2-3)'
            WHEN [Prior_purchases] BETWEEN 4 AND 6 THEN 'Medium (4-6)'
            ELSE 'High (7+)'
       END AS purchase_category,
    COUNT(*) AS total_customers,
    SUM([Reached.on.Time_Y.N]) AS delayed,
    ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate,
    ROUND(AVG(CAST([Customer_rating] AS FLOAT)), 2) AS avg_rating
FROM [E-commerce data]
GROUP BY purchase_category
ORDER BY delay_rate ASC

P8 - Ranking de warehouse
→ Hallazgo: Todos operan parecido

WITH warehouse_stats AS (
    SELECT 
        [Warehouse_block],
        COUNT(*) AS total_shipments,
        ROUND(SUM([Reached.on.Time_Y.N]) * 100.0 / COUNT(*), 2) AS delay_rate_pct,
        ROUND(AVG(CAST([Customer_rating] AS FLOAT)), 2) AS avg_rating,
        ROUND(AVG(CAST([Customer_care_calls] AS FLOAT)), 2) AS avg_calls,
        ROUND(AVG(CAST([Discount_offered] AS FLOAT)), 2) AS avg_discount
    FROM [E-commerce data]
    GROUP BY [Warehouse_block]
),
ranked AS (SELECT *,
        RANK() OVER (ORDER BY delay_rate_pct ASC) AS performance_rank
    FROM warehouse_stats
)
SELECT 
    performance_rank,
    Warehouse_block,
    total_shipments,
    delay_rate_pct,
    avg_rating,
    avg_calls,
    avg_discount
FROM ranked
ORDER BY performance_rank;

CONCLUSIÓN GENERAL — Fase SQL:
→ La operación tiene un problema sistémico, no puntual
→ Dos factores accionables identificados:
   1. Rango de peso 2.5-4kg requiere intervención inmediata
   2. Política de descuentos >10% debe revisarse urgente
→ El sistema no tiene priorización efectiva en ninguna dimensión
→ Todos los warehouses operan igual, problema de proceso, no de gestión local