-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 45 - DISTINCT: encontrando duplicidade de dados
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Exercícios práticos para fixar o uso de DISTINCT
--   em investigações de dados.
-- ============================================================


-- ============================================================
-- EXERCÍCIO 1 — Fornecedores Únicos
-- ============================================================
-- PERGUNTA: Quantos fornecedores diferentes têm produtos cadastrados?
--           Considere apenas produtos ativos (is_active = true)
--
-- TABELA: products
-- CAMPOS: supplier_id, is_active
-- ============================================================

-- RESPOSTA:
SELECT COUNT(DISTINCT supplier_id) AS total_fornecedores
FROM products
WHERE is_active = true;


-- ============================================================
-- EXERCÍCIO 2 — Combinações Únicas
-- ============================================================
-- PERGUNTA: Liste todas as combinações únicas de (categoria, status)
--           que existem na tabela de produtos.
--
-- TABELA: products
-- CAMPOS: category_id, is_active
-- ============================================================

-- RESPOSTA:
SELECT DISTINCT
    category_id,
    is_active
FROM products
ORDER BY category_id, is_active;


-- ============================================================
-- EXERCÍCIO 3 — Slugs Duplicados
-- ============================================================
-- PERGUNTA: Existem produtos com o mesmo slug?
--           (slug é um campo que deveria ser único)
--           Liste os slugs que estão duplicados e quantas vezes.
--
-- TABELA: products
-- CAMPOS: slug
-- ============================================================

-- RESPOSTA:
SELECT
    slug,
    COUNT(*) AS quantidade
FROM products
WHERE slug IS NOT NULL AND slug <> ''
GROUP BY slug
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;


-- ============================================================
-- GABARITO RESUMIDO
-- ============================================================
-- Exercício | Solução
-- ----------|-------------------------------------------------
-- 1         | COUNT(DISTINCT supplier_id)
-- 2         | SELECT DISTINCT category_id, is_active
-- 3         | GROUP BY slug HAVING COUNT(*) > 1
-- ============================================================