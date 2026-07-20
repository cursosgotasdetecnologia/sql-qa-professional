-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 44 - COALESCE e TRIM: tratando dados nulos e vazios na investigação
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Exercícios práticos para fixar o uso de COALESCE e TRIM
--   em investigações de dados.
-- ============================================================


-- ============================================================
-- EXERCÍCIOS — COALESCE
-- ============================================================


-- EXERCÍCIO 1 — Produtos sem Desconto
-- ============================================================
-- PERGUNTA: Queremos listar todos os produtos que NÃO têm desconto.
--           O campo discount_percentage pode ser NULL ou 0.
--           Como fazer para incluir os dois casos?
--
-- REGRA: Produto sem desconto = discount_percentage IS NULL OR discount_percentage = 0
--
-- TABELA: products
-- CAMPOS: id, name, price, discount_percentage
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    name,
    price,
    discount_percentage
FROM products
WHERE COALESCE(discount_percentage, 0) = 0
ORDER BY price DESC;


-- ============================================================
-- EXERCÍCIO 2 — Pedidos sem Desconto
-- ============================================================
-- PERGUNTA: Queremos listar todos os pedidos que NÃO tiveram desconto.
--           O campo discount_amount pode ser NULL ou 0.
--           Como fazer para incluir os dois casos?
--
-- REGRA: Pedido sem desconto = discount_amount IS NULL OR discount_amount = 0
--
-- TABELA: orders
-- CAMPOS: id, order_number, total_amount, discount_amount
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    order_number,
    total_amount,
    discount_amount
FROM orders
WHERE COALESCE(discount_amount, 0) = 0
ORDER BY total_amount DESC;


-- ============================================================
-- EXERCÍCIO 3 — Calculando Preço com Desconto
-- ============================================================
-- PERGUNTA: Você precisa calcular o preço final de todos os produtos
--           aplicando o desconto. O campo discount_percentage pode ser NULL.
--           Como fazer o cálculo funcionar para todos os produtos?
--
-- FÓRMULA: preco_final = price - (price * discount_percentage / 100)
--
-- TABELA: products
-- CAMPOS: id, name, price, discount_percentage
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    name,
    price,
    discount_percentage,
    price - (price * COALESCE(discount_percentage, 0) / 100) AS preco_final
FROM products
ORDER BY preco_final;


-- ============================================================
-- EXERCÍCIOS — TRIM
-- ============================================================


-- EXERCÍCIO 4 — Produtos com Espaço no Nome
-- ============================================================
-- PERGUNTA: Queremos encontrar todos os produtos que têm espaços
--           no começo ou no final do nome.
--
-- REGRA: name com espaço = name != TRIM(name)
--
-- TABELA: products
-- CAMPOS: id, name
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    name AS nome_original,
    TRIM(name) AS nome_limpo
FROM products
WHERE name != TRIM(name)
ORDER BY id;


-- ============================================================
-- EXERCÍCIO 5 — Nomes Duplicados por Espaço
-- ============================================================
-- PERGUNTA: Queremos saber se existem produtos com o mesmo nome
--           mas que são considerados diferentes por causa de espaços.
--
-- REGRA: Agrupar por TRIM(name) e contar quantos têm o mesmo nome
--
-- TABELA: products
-- CAMPOS: id, name
-- ============================================================

-- RESPOSTA:
SELECT
    TRIM(name) AS nome_limpo,
    COUNT(*) AS quantidade
FROM products
GROUP BY TRIM(name)
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;


-- ============================================================
-- EXERCÍCIO 6 — Categorias com Espaço no Nome
-- ============================================================
-- PERGUNTA: Queremos encontrar todas as categorias que têm espaços
--           no começo ou no final do nome.
--
-- REGRA: name com espaço = name != TRIM(name)
--
-- TABELA: categories
-- CAMPOS: id, name
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    name AS nome_original,
    TRIM(name) AS nome_limpo
FROM categories
WHERE name != TRIM(name)
ORDER BY id;


-- ============================================================
-- GABARITO RESUMIDO
-- ============================================================
-- Exercício | Solução
-- ----------|-------------------------------------------------
-- 1         | COALESCE(discount_percentage, 0) = 0
-- 2         | COALESCE(discount_amount, 0) = 0
-- 3         | price - (price * COALESCE(discount_percentage, 0) / 100)
-- 4         | WHERE name != TRIM(name)
-- 5         | GROUP BY TRIM(name) HAVING COUNT(*) > 1
-- 6         | WHERE name != TRIM(name)
-- ============================================================