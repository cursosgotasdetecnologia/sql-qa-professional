-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 46 - Dados inconsistentes, soft delete e UUID
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Exercícios práticos para fixar os conceitos de DISTINCT,
--   Soft Delete, UUID e CAST.
-- ============================================================


-- ============================================================
-- EXERCÍCIO 1 — DISTINCT
-- ============================================================
-- PERGUNTA: Quantos fornecedores diferentes têm produtos ativos?
--
-- TABELA: products
-- CAMPOS: supplier_id, is_active
-- ============================================================

-- RESPOSTA:
SELECT COUNT(DISTINCT supplier_id) AS total_fornecedores
FROM products
WHERE is_active = true;


-- ============================================================
-- EXERCÍCIO 2 — Soft Delete
-- ============================================================
-- PERGUNTA: Existem produtos inativos que estão no carrinho de clientes?
--           Liste o item do carrinho, o usuário e o produto.
--
-- TABELAS: cart_items, products
-- CAMPOS: cart_items.id, cart_items.user_id, products.name, products.is_active
-- ============================================================

-- RESPOSTA:
SELECT
    ci.id AS item_carrinho,
    ci.user_id,
    p.name AS produto,
    p.is_active AS ativo
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = false;


-- ============================================================
-- EXERCÍCIO 3 — UUID
-- ============================================================
-- PERGUNTA: Existem usuários com UUID em formato inválido?
--           (tamanho diferente de 36)
--
-- TABELA: users
-- CAMPOS: id
-- ============================================================

-- RESPOSTA:
SELECT 
    id,
    LENGTH(id::TEXT) AS tamanho
FROM users
WHERE LENGTH(id::TEXT) != 36;


-- ============================================================
-- EXERCÍCIO 4 — CAST: data::TEXT
-- ============================================================
-- PERGUNTA: Qual o tamanho da string da data de criação dos pedidos?
--           Liste o id, a data e o tamanho da data em texto.
--
-- TABELA: orders
-- CAMPOS: id, created_at
-- ============================================================

-- RESPOSTA:
SELECT 
    id,
    created_at,
    LENGTH(created_at::TEXT) AS tamanho_data
FROM orders
LIMIT 10;


-- ============================================================
-- EXERCÍCIO 5 — CAST: texto::INTEGER
-- ============================================================
-- PERGUNTA: Converta o preço dos produtos para texto e depois para inteiro.
--           (ex: 99.90 → '99.90' → 99)
--           Liste id, name, price e price_int.
--
-- TABELA: products
-- CAMPOS: id, name, price
-- ============================================================

-- RESPOSTA:
SELECT 
    id,
    name,
    price,
    price::TEXT AS preco_texto,
    price::INTEGER AS preco_inteiro
FROM products
LIMIT 10;


-- ============================================================
-- EXERCÍCIO 6 — CAST: numero::TEXT
-- ============================================================
-- PERGUNTA: Converta o ID dos produtos para texto e mostre o tamanho.
--           Liste id, id_texto e tamanho do id_texto.
--
-- TABELA: products
-- CAMPOS: id
-- ============================================================

-- RESPOSTA:
SELECT 
    id,
    id::TEXT AS id_texto,
    LENGTH(id::TEXT) AS tamanho_id
FROM products
LIMIT 10;


-- ============================================================
-- GABARITO RESUMIDO
-- ============================================================
-- Exercício | Solução
-- ----------|-------------------------------------------------
-- 1         | COUNT(DISTINCT supplier_id)
-- 2         | INNER JOIN cart_items + products WHERE p.is_active = false
-- 3         | LENGTH(id::TEXT) != 36
-- 4         | LENGTH(created_at::TEXT)
-- 5         | price::INTEGER
-- 6         | LENGTH(id::TEXT)
-- ============================================================