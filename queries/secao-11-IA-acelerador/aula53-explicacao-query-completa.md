# 📋 Explicação Técnica — Query de Auditoria Northwind

## Visão Geral

Esta query gera um relatório consolidado de produtos, unindo dados de categoria, fornecedor, avaliações, carrinho e pedidos em uma única linha por produto. Ela calcula margem de lucro, preço com desconto, totais de vendas/avaliações e classifica cada produto com selos de status de estoque e disponibilidade — pensada para auditoria de catálogo e saúde comercial.

## SELECT — Colunas e Cálculos

A maior parte das colunas vem diretamente de `products` (id, nome, sku, preço, custo, estoque, nível mínimo, ativo, destaque, desconto), apenas com apelidos em português. As colunas calculadas merecem atenção especial:

### `margem`
```sql
(p.price - p.cost_price)::numeric(10,2) AS margem
```
- **O que faz:** calcula o lucro bruto por unidade (preço de venda menos custo).
- **Por que existe:** essa informação não está pronta na tabela — precisa ser calculada na hora.
- **`::numeric(10,2)`:** arredonda para 2 casas decimais, evitando dízimas como `12.3333333`.
- **Se remover:** perde-se a visão de lucratividade do produto; seria necessário calcular manualmente depois.

### `preco_final`
```sql
(p.price * (1 - COALESCE(p.discount_percentage,0) / 100))::numeric(10,2) AS preco_final
```
- **O que faz:** aplica o desconto sobre o preço para obter o valor real de venda.
- **Por que o `COALESCE`:** se `discount_percentage` for `NULL` (produto sem desconto cadastrado), a conta resultaria em `NULL`, fazendo o preço final sumir do relatório. O `COALESCE(..., 0)` troca `NULL` por `0`, garantindo que produtos sem desconto mostrem o preço cheio.
- **Se remover o COALESCE:** todo produto sem desconto apareceria com `preco_final = NULL` — um bug silencioso comum em testes de QA.

### Colunas de agregação (`COUNT`, `AVG`, `SUM`)
```sql
COUNT(r.id)                     AS total_avaliacoes,
AVG(r.rating)::numeric(3,1)     AS media_avaliacao,
COUNT(ci.id)                    AS vezes_no_carrinho,
COUNT(oi.id)                    AS total_pedidos,
SUM(oi.subtotal)::numeric(10,2) AS receita_total
```
- **O que fazem:** contam avaliações, presenças no carrinho, itens de pedido e somam a receita, tudo por produto.
- **Por que existem:** essas informações vêm de tabelas separadas (`reviews`, `cart_items`, `order_items`), então é preciso unir (JOIN) e depois agregar por produto.
- **Ponto de atenção para QA:** `COUNT(r.id)` conta o **id**, não `COUNT(*)`. Isso é proposital — se o produto não tiver avaliação, o LEFT JOIN gera uma linha com `r.id = NULL`, e `COUNT(NULL)` resulta em `0`, enquanto `COUNT(*)` erradamente contaria `1`.
- **Se remover:** a query perde toda a visão de vendas e popularidade do produto, virando apenas um catálogo estático.

## JOINs — Como as Tabelas se Conectam

```sql
FROM products p
INNER JOIN categories c  ON c.id  = p.category_id
INNER JOIN suppliers  s  ON s.id  = p.supplier_id
LEFT  JOIN reviews    r  ON r.product_id = p.id
LEFT  JOIN cart_items ci ON ci.product_id = p.id
LEFT  JOIN order_items oi ON oi.product_id = p.id
```

### Por que `categories` e `suppliers` são `INNER JOIN`
- **O que faz:** só traz produtos que **têm** categoria e fornecedor cadastrados (o match precisa existir nos dois lados).
- **Por que faz sentido:** a regra de negócio assume que todo produto deveria ter categoria e fornecedor válidos — são dados obrigatórios.
- **Se fossem `LEFT JOIN`:** produtos com `category_id` ou `supplier_id` quebrados apareceriam com `categoria`/`fornecedor` em branco, mascarando um problema de integridade de dados.
- **Risco de QA:** o `INNER JOIN` faz produtos "órfãos" (sem categoria ou fornecedor válido) **sumirem silenciosamente** do relatório. Vale sempre comparar `COUNT(*) FROM products` com o total de linhas do resultado final.

### Por que `reviews`, `cart_items` e `order_items` são `LEFT JOIN`
- **O que fazem:** trazem **todos** os produtos, mesmo os que nunca foram avaliados, adicionados ao carrinho ou vendidos, preenchendo com `NULL` quando não há correspondência.
- **Por que faz sentido:** é normal um produto novo não ter avaliações ou vendas ainda — isso não é erro de dado, é um estado válido do negócio.
- **Se fossem `INNER JOIN`:** o relatório excluiria todo produto sem avaliação, carrinho ou pedido — justamente os produtos mais importantes de analisar (por que não vendem) desapareceriam.

## GROUP BY e Agregações

```sql
GROUP BY
  p.id, p.name, p.sku, p.price, p.cost_price,
  p.stock_quantity, p.reorder_level, p.is_active,
  p.is_featured, p.discount_percentage,
  c.name, c.is_active,
  s.company_name, s.email, s.city, s.is_active
```

- **O que faz:** agrupa de volta em uma linha por produto todas as linhas multiplicadas pelos LEFT JOINs (uma linha por avaliação, uma por item de carrinho, uma por pedido).
- **Por que é necessário:** como a query usa `COUNT`, `AVG` e `SUM`, o PostgreSQL exige que toda coluna não-agregada do `SELECT` apareça no `GROUP BY` — sem isso, a query nem executa.
- **Por que tantas colunas:** cada coluna "solta" no SELECT precisa estar aqui, pois o PostgreSQL não infere automaticamente que `p.id` já garante unicidade das demais colunas de `p`.
- **Se remover:** a query falha com erro de sintaxe (`column must appear in the GROUP BY clause or be used in an aggregate function`) e não roda.

## CASE WHEN — Classificações de Status

### `status_estoque`
```sql
CASE
  WHEN p.stock_quantity = 0 THEN '🔴 SEM ESTOQUE'
  WHEN p.stock_quantity <= p.reorder_level THEN '🟡 ESTOQUE CRÍTICO'
  ELSE '🟢 OK'
END AS status_estoque
```
- **O que classifica:** o nível de estoque em 3 categorias — zerado, crítico (abaixo do ponto de reposição) ou normal.
- **Ordem importa:** o `CASE` avalia de cima para baixo e para na primeira condição verdadeira. `= 0` precisa vir antes de `<= reorder_level`, senão um estoque zerado também cairia em "crítico" e nunca mostraria "SEM ESTOQUE".
- **Se remover:** perde-se o alerta visual rápido de reposição; seria necessário comparar `stock_quantity` e `reorder_level` manualmente.

### `status_geral`
```sql
CASE
  WHEN p.is_active = false THEN '❌ INATIVO'
  WHEN c.is_active = false THEN '⚠️ CATEGORIA INATIVA'
  WHEN s.is_active = false THEN '⚠️ FORNECEDOR INATIVO'
  ELSE '✅ DISPONÍVEL'
END AS status_geral
```
- **O que classifica:** se o produto está realmente disponível para venda, considerando não só ele mesmo, mas também se sua categoria e fornecedor estão ativos.
- **Por que é útil:** um produto pode estar `is_active = true`, mas pertencer a uma categoria ou fornecedor desativado — na prática, ele não deveria estar disponível. Esse `CASE` simula essa regra em cascata.
- **Ordem importa:** prioriza o problema mais direto (produto inativo) antes de checar as dependências.
- **Se remover:** o relatório mostraria produtos como "disponíveis" mesmo com categoria/fornecedor inativos — um bug de negócio silencioso.

## ORDER BY

```sql
ORDER BY receita_total DESC NULLS LAST
```

- **O que faz:** ordena os produtos do maior para o menor faturamento (`receita_total`).
- **Por que `NULLS LAST`:** produtos nunca vendidos têm `receita_total = NULL` (pois `SUM` sem correspondência no LEFT JOIN resulta em `NULL`, não em `0`). Por padrão, o PostgreSQL colocaria os `NULL` **primeiro** em ordenação `DESC`, jogando produtos sem venda para o topo do relatório. `NULLS LAST` corrige isso, empurrando os `NULL` para o final.
- **Se remover:** produtos "zerados" apareceriam antes dos mais vendidos — uma ordenação contraintuitiva, fácil de passar despercebida em revisão.

## Como Usar Esta Query

Casos de uso práticos para QA:

1. **Teste de integridade referencial:** compare `COUNT(*) FROM products` com o total de linhas retornadas — se forem diferentes, há produtos sem categoria ou fornecedor válido sendo excluídos pelo `INNER JOIN`.
2. **Teste de desconto ausente:** verifique produtos com `discount_percentage IS NULL` — `preco_final` deve exibir o preço cheio, nunca `NULL`.
3. **Teste de produto sem interação:** verifique produtos sem avaliação/carrinho/pedido — `total_avaliacoes`, `vezes_no_carrinho` e `total_pedidos` devem ser `0`, nunca `NULL`.
4. **Teste de limite de estoque:** cadastre um produto com `stock_quantity = reorder_level` e confirme que ele cai em "🟡 ESTOQUE CRÍTICO", não em "🟢 OK".
5. **Teste de cascata de disponibilidade:** ative um produto mas desative sua categoria ou fornecedor, e confirme que `status_geral` reflete a inatividade herdada.
6. **Teste de ordenação:** confirme que produtos sem venda (`receita_total = NULL`) aparecem no final da listagem, não no início.