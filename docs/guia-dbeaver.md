# 🦫 Guia de Referência Rápida — DBeaver

> Documento vivo — atualizado a cada aula com novos recursos do DBeaver.  
> Versão: 1.0 | Curso: SQL & Banco de Dados para QA

---

## ⌨️ Atalhos Essenciais

| Atalho | O que faz |
|---|---|
| `Ctrl + Enter` | Executa a query onde está o cursor |
| `Ctrl + Shift + Enter` | Executa tudo que está selecionado |
| `Ctrl + ]` | Abre novo editor de script SQL |
| `Ctrl + S` | Salva o script atual |
| `Ctrl + A` | Seleciona todo o conteúdo do editor |
| `Ctrl + /` | Comenta/descomenta a linha selecionada |
| `Ctrl + Shift + F` | Formata o SQL automaticamente |
| `Ctrl + Space` | Abre o autocomplete |
| `F3` | Abre a aba de resultado numa janela maior |

---

## 📝 Editor de Scripts SQL

### Abrindo um novo script
- Menu superior: **SQL Editor → Open SQL Script**
- Atalho: `Ctrl + ]`

### Boas práticas no editor
- **Sempre confira o banco selecionado** no seletor do topo antes de executar — se estiver errado, você roda a query no banco errado.
- **Salve o script** com `Ctrl + S` antes de executar — se o DBeaver travar, você não perde o trabalho.
- **Uma query por vez** com `Ctrl + Enter` — quando tiver múltiplas queries no arquivo, posicione o cursor na que quer rodar.

### Fixando e renomeando abas
- **Fixar aba:** clique com botão direito na aba → **Pin Tab** — aba fixada não fecha acidentalmente.
- **Renomear aba:** clique com botão direito na aba → **Rename** — use nomes descritivos como `products-investigacao.sql`.

---

## ✍️ Padrões de Escrita SQL no DBeaver

### Palavras reservadas em maiúsculo
```sql
-- ✅ correto — palavras reservadas em maiúsculo
SELECT name, price
FROM products
WHERE is_active = true
ORDER BY price ASC;

-- ❌ evite — dificulta leitura e identificação de erros
select name, price from products where is_active = true;
```

### Ponto e vírgula no final
```sql
-- ✅ sempre feche a query com ponto e vírgula
SELECT * FROM products;

-- quando tiver múltiplas queries no mesmo script,
-- o ponto e vírgula separa cada uma
SELECT * FROM products;
SELECT * FROM categories;
SELECT * FROM suppliers;
```

### Formatação automática
- Escreve a query → `Ctrl + Shift + F` → DBeaver indenta e organiza automaticamente.
- Útil quando receber uma query de terceiro sem formatação.

### Autocomplete
- `Ctrl + Space` após digitar as primeiras letras de uma tabela ou coluna.
- O DBeaver sugere nomes reais do banco conectado — evita erro de digitação.

---

## 🎨 Cores de Sintaxe

| Cor (padrão dark) | O que representa |
|---|---|
| Azul claro | Palavras reservadas (SELECT, FROM, WHERE...) |
| Branco/cinza | Nomes de tabelas e colunas |
| Verde | Strings entre aspas simples ('valor') |
| Laranja/amarelo | Números |
| Verde escuro | Comentários (-- comentário) |

> Se uma palavra que deveria ser reservada não ficou colorida, verifique a digitação — provavelmente está errada.

---

## 📊 Área de Resultados

### Navegando no resultado
- Resultado aparece na aba **Data** abaixo do editor.
- Clique no cabeçalho de uma coluna pra ordenar pelo resultado — útil pra inspecionar rapidamente.
- Barra de status no rodapé mostra: **total de linhas** retornadas e **tempo de execução**.

### Exportando resultado
*(detalhes serão adicionados na Aula 40)*

| Formato | Quando usar |
|---|---|
| CSV | Evidência em planilha, anexo no Jira/Azure DevOps |
| HTML | Relatório visual, abre no browser formatado |
| SQL | Recria os dados em outro ambiente como INSERT |

---

## 🔌 Conexões

### Verificando a conexão ativa
- Painel esquerdo **Database Navigator** → conexão com ícone verde = ativa.
- Ícone cinza = desconectada → clique com botão direito → **Connect**.

### Conexões do curso
| Conexão | Banco | Quando usar |
|---|---|---|
| PostgreSQL Local | postgres@localhost | Testes locais, aulas iniciais |
| Supabase Northwind | PostgreSQL remoto | Aulas de SQL, investigação, portfólio |

---

## 💬 Comentários no Script

```sql
-- comentário de linha única — use para explicar o objetivo da query

/*
  comentário de bloco
  use para blocos maiores de explicação
  ou para desativar temporariamente um trecho de código
*/

-- boa prática: sempre documente o objetivo da query
-- OBJETIVO: validar produtos ativos sem estoque (US-042)
SELECT name, stock_quantity
FROM products
WHERE is_active = true
  AND stock_quantity = 0;
```

---

## 🗂️ Explorando Objetos do Banco

### Navegando pelas tabelas
1. Painel esquerdo → nome do banco → **Schemas** → **public** → **Tables**
2. Clique na tabela → aba **Properties** → lista colunas com tipo e nullable
3. Aba **ER Diagram** → diagrama de relacionamentos da tabela

### Ver dados de uma tabela rapidamente
- Botão direito na tabela → **View Data** → DBeaver gera `SELECT *` automático
- Útil pra explorar, não pra trabalhar — prefira o editor de scripts

### Inspecionar estrutura de uma coluna
- Clique na tabela → aba **Columns** → clique na coluna → detalhes no painel inferior

---

## ⚠️ Erros Comuns e Soluções

| Erro | Causa provável | Solução |
|---|---|---|
| `relation "products" does not exist` | Banco errado selecionado | Confira o seletor de banco no topo do editor |
| `column "name" does not exist` | Nome de coluna errado | Use autocomplete `Ctrl + Space` pra confirmar o nome |
| `syntax error at or near "WHERE"` | Falta vírgula ou ponto e vírgula antes | Revise a linha anterior ao WHERE |
| `ERROR: column reference is ambiguous` | Duas tabelas têm coluna com mesmo nome | Use alias: `p.name` em vez de só `name` |
| Resultado vazio inesperado | Filtro muito restritivo ou dado não existe | Remova cláusulas uma por uma até achar o ponto |
| DBeaver lento ao abrir | Muitas abas abertas | Feche abas não fixadas, reinicie o DBeaver |

---

## 📁 Organização dos Scripts no Projeto

```
queries/
├── secao-07-sql-essencial/
│   ├── aula-25-select-where-orderby-limit.sql
│   └── ...
└── ...
```

> **Convenção de nome:** `aula-XX-tema-principal.sql`  
> Sempre em minúsculo, palavras separadas por hífen, sem acento.

---
 
## 🔄 Trabalhando com Transactions no DBeaver
 
> **Atenção:** por padrão o DBeaver usa autocommit — cada query é confirmada automaticamente. Para usar BEGIN/ROLLBACK/COMMIT corretamente, você precisa desabilitar o autocommit primeiro.
 
### Passo 1 — Desabilitar o autocommit
 
Procure na barra de ferramentas do editor SQL:
 
```
🔄 Auto-commit  ← clica para desabilitar
```
 
Ou pelo menu: **SQL Editor → Auto-commit** → desabilita.
 
Quando desabilitado, a barra do editor muda de aparência — confirme antes de continuar.
 
> ⚠️ Com autocommit **ligado**, o ROLLBACK não funciona — o INSERT já foi confirmado antes de você rodar o ROLLBACK.
 
---
 
### Passo 2 — Rodar bloco por bloco
 
Nunca selecione tudo e rode com `Ctrl + Shift + Enter` — o DBeaver executa tudo junto e perde o efeito visual da transaction.
 
**O jeito certo: cursor em cada comando + `Ctrl + Enter`**
 
```sql
-- 1. cursor aqui → Ctrl+Enter
BEGIN;
 
-- 2. cursor aqui → Ctrl+Enter
INSERT INTO categories (name, slug, is_active)
VALUES ('Categoria Teste', 'cat-teste', true);
 
-- 3. cursor aqui → Ctrl+Enter
-- confirma que aparece (só você vê neste momento)
SELECT id, name FROM categories
WHERE slug = 'cat-teste';
 
-- 4. cursor aqui → Ctrl+Enter
ROLLBACK;
 
-- 5. cursor aqui → Ctrl+Enter
-- confirma que sumiu — deve retornar 0 linhas
SELECT id, name FROM categories
WHERE slug = 'cat-teste';
```
 
**O que você vai ver:**
- Passo 3 → retorna 1 linha — INSERT funcionou dentro da transaction
- Passo 5 → retorna 0 linhas — ROLLBACK desfez tudo
---
 
### Passo 3 — Reabilitar o autocommit depois
 
Sempre reabilite o autocommit ao terminar os exercícios de transaction.
 
Se deixar desabilitado, todo INSERT da próxima aula ficará pendente até você rodar COMMIT ou ROLLBACK manualmente — e você pode perder dados sem perceber.
 
---
 
### Resumo rápido
 
| Situação | Autocommit | Comportamento |
|---|---|---|
| Aulas normais (SELECT, INSERT, UPDATE) | ✅ Ligado | Cada query confirma automaticamente |
| Aulas de Transaction (BEGIN/ROLLBACK) | ❌ Desligado | Você controla quando confirmar |
 
*Última atualização: Aula 41 — Transações: BEGIN, COMMIT e ROLLBACK*