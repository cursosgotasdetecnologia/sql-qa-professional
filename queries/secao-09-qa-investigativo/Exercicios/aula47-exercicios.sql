-- ============================================================
-- CURSO : SQL & Banco de Dados para QA
-- SEÇÃO : 09 - QA Investigativo
-- AULA  : 47 - Quando a UI Mente: Divergências entre API e Banco
-- BANCO : Supabase Northwind (PostgreSQL)
-- ============================================================
-- OBJETIVO:
--   Exercícios práticos sobre divergências entre UI, API e Banco.
--   Cada chamado apresenta uma suspeita, e você deve investigar
--   com SQL para provar ou descartar a hipótese.
-- ============================================================


-- ============================================================
-- EXERCÍCIO 1 — Chamado: Produto sumiu do carrinho
-- ============================================================
-- CHAMADO: "Cliente estava com produto no carrinho, saiu do site, 
--           voltou no dia seguinte e o produto não estava mais lá. 
--           Ninguém deletou nada."
--
-- HIPÓTESE: O produto foi inativado depois que o cliente adicionou
--           ao carrinho — e o sistema limpou o carrinho sem avisar.
--
-- PERGUNTA: Existem produtos inativos que ainda estão no carrinho?
--
-- TABELAS: cart_items, products
-- ============================================================

-- RESPOSTA:
SELECT
    p.name AS produto,
    p.is_active AS produto_ativo,
    ci.user_id AS usuario,
    ci.quantity AS quantidade,
    ci.created_at AS adicionado_ao_carrinho,
    p.updated_at AS produto_atualizado_em
FROM cart_items ci
INNER JOIN products p ON p.id = ci.product_id
WHERE p.is_active = false;


-- ============================================================
-- EXERCÍCIO 2 — Chamado: Pedido com preço errado
-- ============================================================
-- CHAMADO: "Cliente reclamou que no boleto veio R$249,90, mas
--           na tela do produto estava R$199,90."
--
-- HIPÓTESE: A tela mostra preço antigo (cache) e o banco já tem
--           o preço novo. Ou o pedido gravou o preço errado.
--
-- PERGUNTA: O preço do pedido bate com o preço atual do banco?
--
-- TABELAS: order_items, products
-- ============================================================

-- RESPOSTA:
SELECT
    oi.id AS item_pedido,
    p.name AS produto,
    oi.price AS preco_no_pedido,
    p.price AS preco_atual_banco,
    oi.created_at AS data_pedido,
    p.updated_at AS produto_atualizado_em,
    CASE
        WHEN oi.price = p.price THEN '✅ Preços iguais'
        ELSE '❌ PREÇO DIVERGE!'
    END AS conclusao
FROM order_items oi
INNER JOIN products p ON p.id = oi.product_id
WHERE oi.price != p.price
ORDER BY oi.created_at DESC;


-- ============================================================
-- EXERCÍCIO 3 — Chamado: Contagem de produtos não bate
-- ============================================================
-- CHAMADO: "O endpoint GET /products?active=true retornou 8 produtos.
--           Mas o time de produto jura que tem 10 ativos cadastrados."
--
-- HIPÓTESE: A API está aplicando filtros não documentados
--           (ex: filtrar produtos sem estoque ou sem imagem)
--
-- PERGUNTA: Quantos produtos o banco tem vs quantos a API retornou?
--
-- TABELA: products
-- ============================================================

-- RESPOSTA:
-- PASSO 1: total de ativos no banco
SELECT COUNT(*) AS total_ativos_banco
FROM products
WHERE is_active = true;

-- PASSO 2: possíveis filtros da API
SELECT COUNT(*) AS possivel_filtro_api
FROM products
WHERE is_active = true
  AND stock_quantity > 0
  AND image_url IS NOT NULL
  AND price > 0;


-- ============================================================
-- EXERCÍCIO 4 — Chamado: Produto esgotado mas ainda vendendo
-- ============================================================
-- CHAMADO: "O produto 'Mouse Gamer' está com estoque zerado há 3 dias,
--           mas ainda aparece disponível no site e clientes estão comprando."
--
-- HIPÓTESE: O estoque não foi atualizado no banco, ou a UI ignora
--           o estoque na hora de exibir.
--
-- PERGUNTA: Existem produtos ativos com estoque zerado?
--
-- TABELA: products
-- ============================================================

-- RESPOSTA:
SELECT
    id,
    name AS produto,
    stock_quantity AS estoque,
    is_active AS ativo,
    updated_at AS ultima_atualizacao
FROM products
WHERE is_active = true
    AND stock_quantity = 0
ORDER BY id;


-- ============================================================
-- EXERCÍCIO 5 — Chamado: Status do pedido não atualiza
-- ============================================================
-- CHAMADO: "Cliente recebeu o pedido, mas no site ainda aparece
--           como 'Em trânsito' há 5 dias."
--
-- HIPÓTESE: O status foi atualizado no banco mas a UI não reflete.
--
-- PERGUNTA: Existem pedidos com status inconsistente?
--
-- TABELA: orders
-- ============================================================

-- RESPOSTA:
-- Pedidos com status 'delivered' sem data de entrega
SELECT
    id,
    order_number,
    status,
    delivered_at
FROM orders
WHERE status = 'delivered'
    AND delivered_at IS NULL;


-- ============================================================
-- EXERCÍCIO 6 — Chamado: Categoria sumiu da loja
-- ============================================================
-- CHAMADO: "A categoria 'Eletrônicos' sumiu do menu, mas o time
--           de produto diz que ela está ativa e tem produtos."
--
-- HIPÓTESE: A categoria foi inativada por engano, ou os produtos
--           foram desvinculados.
--
-- PERGUNTA: A categoria está ativa? Os produtos estão vinculados?
--
-- TABELAS: categories, products
-- ============================================================

-- RESPOSTA:
SELECT
    c.id AS categoria_id,
    c.name AS categoria,
    c.is_active AS categoria_ativa,
    COUNT(p.id) AS total_produtos,
    SUM(CASE WHEN p.is_active = true THEN 1 ELSE 0 END) AS produtos_ativos
FROM categories c
LEFT JOIN products p ON p.category_id = c.id
WHERE c.name = 'Eletrônicos'
GROUP BY c.id, c.name, c.is_active;


-- ============================================================
-- GABARITO RESUMIDO
-- ============================================================
-- Exercício | Chamado                              | Query Principal
-- ----------|--------------------------------------|----------------------------------
-- 1         | Produto sumiu do carrinho            | WHERE p.is_active = false
-- 2         | Preço do pedido diferente            | WHERE oi.price != p.price
-- 3         | Contagem de produtos não bate        | COUNT(*) vs filtros da API
-- 4         | Produto esgotado mas ainda vendendo  | WHERE stock_quantity = 0
-- 5         | Status do pedido não atualiza        | WHERE status = 'delivered' AND delivered_at IS NULL
-- 6         | Categoria sumiu da loja              | c.is_active + COUNT(p.id)
-- ============================================================