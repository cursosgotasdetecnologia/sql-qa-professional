-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 10 - Asserts e Evidências Profissionais
-- AULA  : 48 - Asserts em SQL (COUNT, EXISTS e comparações)
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Praticar a criação de asserts automatizados usando COUNT,
--   EXISTS, NOT EXISTS e comparações para validar qualidade de dados.
-- ============================================================
-- TABELAS UTILIZADAS:
--   - products, categories, orders, order_items, customers
-- ============================================================


-- ============================================================
-- EXERCÍCIO 1 — ASSERT com COUNT
-- ============================================================
-- CONTEXTO: Regra de negócio diz que todo pedido deve ter 
--           pelo menos 1 item. Pedidos sem itens são inválidos.
-- ============================================================

-- ASSERT: nenhum pedido pode estar sem itens
-- ESPERADO: 0 linhas

SELECT 
    o.id AS pedido_id,
    o.customer_id,
    o.order_date,
    COUNT(oi.id) AS total_itens
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.customer_id, o.order_date
HAVING COUNT(oi.id) = 0;


-- ============================================================
-- EXERCÍCIO 2 — ASSERT com COUNT e Comparação
-- ============================================================
-- CONTEXTO: Todo pedido deve ter valor total > 0. 
--           Pedidos com valor zero ou negativo indicam bug.
-- ============================================================

-- ASSERT: nenhum pedido pode ter valor total <= 0
-- ESPERADO: 0 linhas

SELECT 
    o.id AS pedido_id,
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS valor_total
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.customer_id
HAVING SUM(oi.quantity * oi.unit_price) <= 0;


-- ============================================================
-- EXERCÍCIO 3 — ASSERT com EXISTS
-- ============================================================
-- CONTEXTO: Clientes que fizeram compras recentes devem 
--           ter status 'ativo'. Clientes ativos sem compras 
--           recentes podem ser reavaliados.
-- ============================================================

-- ASSERT: existe pelo menos 1 cliente ativo com compra nos últimos 30 dias
-- ESPERADO: true

SELECT EXISTS (
    SELECT 1
    FROM customers c
    INNER JOIN orders o ON o.customer_id = c.id
    WHERE c.is_active = true
      AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
) AS cliente_ativo_com_compra_recente;


-- ============================================================
-- EXERCÍCIO 4 — ASSERT com NOT EXISTS
-- ============================================================
-- CONTEXTO: Todo produto ativo deve ter estoque > 0.
--           Produtos ativos sem estoque geram frustração no cliente.
-- ============================================================

-- ASSERT: não existe produto ativo com estoque zerado
-- ESPERADO: true

SELECT NOT EXISTS (
    SELECT 1
    FROM products
    WHERE is_active = true
      AND stock_quantity <= 0
) AS sem_produto_ativo_sem_estoque;


-- ============================================================
-- EXERCÍCIO 5 — ASSERT com EXISTS + COUNT (Composto)
-- ============================================================
-- CONTEXTO: Categoria 'eletronicos' deve ter pelo menos 
--           5 produtos ativos para campanha de marketing.
-- ============================================================

-- ASSERT: categoria 'eletronicos' tem pelo menos 5 produtos ativos
-- ESPERADO: true

SELECT 
    CASE 
        WHEN COUNT(*) >= 5 THEN true
        ELSE false
    END AS categoria_eletronicos_tem_5_produtos,
    COUNT(*) AS total_produtos_ativos
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE c.slug = 'eletronicos'
  AND p.is_active = true;


-- ============================================================
-- EXERCÍCIO 6 — ASSERT com LEFT JOIN (Bônus)
-- ============================================================
-- CONTEXTO: Pedidos com customer_id que não existe em customers
--           indicam violação de integridade referencial.
-- ============================================================

-- ASSERT: nenhum pedido com cliente inválido
-- ESPERADO: 0 linhas

SELECT 
    o.id AS pedido_id,
    o.customer_id,
    c.id AS cliente_existe
FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE c.id IS NULL;


-- ============================================================
-- EXERCÍCIO 7 — ASSERT com NOT EXISTS + COUNT (Bônus)
-- ============================================================
-- CONTEXTO: Produtos que nunca foram vendidos devem ter 
--           is_active = false para não poluir o catálogo.
-- ============================================================

-- ASSERT: não existe produto ativo que nunca foi vendido
-- ESPERADO: true

SELECT NOT EXISTS (
    SELECT 1
    FROM products p
    WHERE p.is_active = true
      AND NOT EXISTS (
          SELECT 1
          FROM order_items oi
          WHERE oi.product_id = p.id
      )
) AS sem_produto_ativo_sem_venda;


-- ============================================================
-- EXERCÍCIO 8 — ASSERT com COUNT e GROUP BY (Bônus)
-- ============================================================
-- CONTEXTO: Nenhum cliente pode ter mais de 10 pedidos 
--           em aberto (status = 'pending').
-- ============================================================

-- ASSERT: nenhum cliente tem mais de 10 pedidos em aberto
-- ESPERADO: 0 linhas

SELECT 
    customer_id,
    COUNT(*) AS total_pedidos_abertos
FROM orders
WHERE status = 'pending'
GROUP BY customer_id
HAVING COUNT(*) > 10;


-- ============================================================
-- EXERCÍCIO 9 — ASSERT com EXISTS e Subconsulta (Bônus)
-- ============================================================
-- CONTEXTO: Existe pelo menos um produto com preço acima da 
--           média da sua categoria. Isso indica produtos premium.
-- ============================================================

-- ASSERT: existe produto com preço acima da média da categoria
-- ESPERADO: true

SELECT EXISTS (
    SELECT 1
    FROM products p
    INNER JOIN categories c ON c.id = p.category_id
    WHERE p.price > (
        SELECT AVG(p2.price)
        FROM products p2
        WHERE p2.category_id = p.category_id
    )
) AS existe_produto_acima_media_categoria;


-- ============================================================
-- EXERCÍCIO 10 — ASSERT Completo com CTE (Bônus Master)
-- ============================================================
-- CONTEXTO: Relatório consolidado de qualidade da base de produtos
-- ============================================================

-- ASSERT: todos os checks devem retornar 0 ou TRUE
-- ESPERADO: todos os status = '✅ PASS'

WITH checks AS (
    SELECT 
        'produtos_sem_categoria' AS nome_check,
        COUNT(*) AS total
    FROM products p
    LEFT JOIN categories c ON c.id = p.category_id
    WHERE c.id IS NULL
    
    UNION ALL
    
    SELECT 
        'produtos_ativos_com_preco_invalido' AS nome_check,
        COUNT(*) AS total
    FROM products
    WHERE is_active = true AND price <= 0
    
    UNION ALL
    
    SELECT 
        'produtos_com_custo_maior_preco' AS nome_check,
        COUNT(*) AS total
    FROM products
    WHERE is_active = true AND cost_price > price
    
    UNION ALL
    
    SELECT 
        'skus_duplicados' AS nome_check,
        COUNT(*) AS total
    FROM (
        SELECT sku
        FROM products
        GROUP BY sku
        HAVING COUNT(*) > 1
    ) sub
)
SELECT 
    nome_check,
    total,
    CASE 
        WHEN total = 0 THEN '✅ PASS'
        ELSE '❌ FAIL - ' || total || ' ocorrências'
    END AS status
FROM checks
ORDER BY nome_check;


-- ============================================================
-- RESUMO DA AULA PRÁTICA:
--   ASSERT com COUNT      → validar volumes e contagens
--   ASSERT com EXISTS     → validar existência de registros
--   ASSERT com NOT EXISTS → validar ausência de registros
--   ASSERT com LEFT JOIN  → validar integridade referencial
--   ASSERT com CTE        → consolidar múltiplas validações
--   
--   Dica de QA → Sempre documente o que é esperado (0 linhas / true).
--                O assert ideal é aquele que prova que NÃO existe bug.
-- ============================================================