# Álgebra Relacional e Fundamentos

A álgebra relacional é a base matemática e teórica formal sobre a qual o modelo relacional de banco de dados e a linguagem SQL foram construídos. Proposta por Edgar F. Codd em 1970, ela trata tabelas como relações (conjuntos de tuplas) e define operadores que recebem relações e produzem novas relações como resultado (propriedade de fechamento).

---

## 1. Conceitos Fundamentais
- **Relação (R):** Conjunto não ordenado de tuplas (análogo a uma tabela).
- **Tupla (t):** Elemento da relação contendo valores para cada atributo (análogo a uma linha/registro).
- **Atributo (A):** Propriedade ou característica nomeada (análogo a uma coluna).
- **Domínio (dom(A)):** Conjunto de valores válidos e atômicos permitidos para um determinado atributo.

---

## 2. Operadores Fundamentais

### 2.1. Seleção (Sigma - $\sigma$)
Filtra tuplas que satisfazem uma condição lógica ou predicado. Opera horizontalmente na tabela, reduzindo o número de linhas.

- **Notação:** $\sigma_{condicao}(R)$
- **Exemplo na Álgebra:** $\sigma_{salario > 5000 \land departamento = 'TI'}(Funcionarios)$
- **Equivalente em SQL:**
  ```sql
  SELECT * 
  FROM funcionarios 
  WHERE salario > 5000 AND departamento = 'TI';
  ```

---

### 2.2. Projeção (Pi - $\pi$)
Seleciona um subconjunto de colunas, descartando as demais. Opera verticalmente na tabela e, na definição matemática pura, remove duplicatas.

- **Notação:** $\pi_{A_1, A_2, \dots, A_n}(R)$
- **Exemplo na Álgebra:** $\pi_{nome, cargo, salario}(Funcionarios)$
- **Equivalente em SQL:**
  ```sql
  SELECT DISTINCT nome, cargo, salario 
  FROM funcionarios;
  ```
  *(Nota: No SQL padrão, o SELECT mantém duplicatas por padrão, necessitando do DISTINCT para reproduzir o comportamento exato da álgebra).*

---

### 2.3. Produto Cartesiano ($\times$)
Combina cada linha da relação R com todas as linhas da relação S. Se R tem $n$ tuplas e S tem $m$ tuplas, o resultado terá $n \times m$ linhas.

- **Notação:** $R \times S$
- **Exemplo na Álgebra:** $Funcionarios \times Departamentos$
- **Equivalente em SQL:**
  ```sql
  SELECT * 
  FROM funcionarios 
  CROSS JOIN departamentos;
  ```

---

### 2.4. União ($\cup$)
Combina as linhas de duas tabelas compatíveis (mesma quantidade de atributos e tipos correspondentes), eliminando duplicadas.

- **Notação:** $R \cup S$
- **Exemplo na Álgebra:** $Clientes\_PF \cup Clientes\_PJ$
- **Equivalente em SQL:**
  ```sql
  SELECT nome, documento FROM clientes_pf
  UNION
  SELECT nome, documento FROM clientes_pj;
  ```

---

### 2.5. Diferença de Conjuntos ($-$)
Retorna tuplas que existem na relação R, mas não existem na relação S. As tabelas precisam ter esquemas compatíveis.

- **Notação:** $R - S$
- **Exemplo na Álgebra:** $Todos\_Clientes - Clientes\_Inadimplentes$
- **Equivalente em SQL:**
  ```sql
  SELECT id_cliente FROM todos_clientes
  EXCEPT  -- No Oracle utiliza-se MINUS
  SELECT id_cliente FROM clientes_inadimplentes;
  ```

---

### 2.6. Renomeação (Rho - $\rho$)
Altera temporariamente o nome da relação ou de seus atributos.

- **Notação:** $\rho_{S(B_1, B_2, \dots)}(R)$
- **Equivalente em SQL:**
  ```sql
  SELECT f.nome AS nome_funcionario, f.salario AS remuneracao
  FROM funcionarios AS f;
  ```

---

## 3. Operadores Derivados

### 3.1. Interseção ($\cap$)
Retorna tuplas que estão presentes simultaneamente em R e em S.
- **Definição:** $R \cap S = R - (R - S)$
- **Equivalente em SQL:**
  ```sql
  SELECT id_cliente FROM compras_loja_fisica
  INTERSECT
  SELECT id_cliente FROM compras_online;
  ```

---

### 3.2. Junção (Theta Join / Natural Join - $\bowtie$)
Combina um produto cartesiano seguido de uma seleção baseada em condição de igualdade ou comparação entre chaves.
- **Theta Join:** $R \bowtie_{\theta} S = \sigma_{\theta}(R \times S)$
- **Equi-Join:** Quando a condição $\theta$ é de igualdade ($R.id = S.id$).
- **Equivalente em SQL (INNER JOIN):**
  ```sql
  SELECT *
  FROM funcionarios f
  INNER JOIN departamentos d ON f.departamento_id = d.id;
  ```

---

### 3.3. Divisão ($\div$)
Expressa consultas do tipo: "encontre todos os elementos de R que estão relacionados a TODOS os elementos de S".
- **Equivalente em SQL:** Expressa normalmente via subconsultas com `NOT EXISTS` ou agrupamento com `HAVING COUNT(DISTINCT ...)`:
  ```sql
  SELECT id_cliente
  FROM pedidos
  WHERE id_produto IN (SELECT id FROM produtos WHERE categoria = 'Servidores')
  GROUP BY id_cliente
  HAVING COUNT(DISTINCT id_produto) = (
      SELECT COUNT(*) FROM produtos WHERE categoria = 'Servidores'
  );
  ```

---

## 4. Tabela de Mapeamento Álgebra -> SQL

| Operação | Símbolo Álgebra | Equivalente SQL |
| :--- | :---: | :--- |
| **Seleção** | $\sigma$ | `WHERE` / `HAVING` |
| **Projeção** | $\pi$ | `SELECT` / `SELECT DISTINCT` |
| **Produto Cartesiano** | $\times$ | `CROSS JOIN` |
| **Junção** | $\bowtie$ | `INNER JOIN ... ON ...` |
| **União** | $\cup$ | `UNION` |
| **Interseção** | $\cap$ | `INTERSECT` |
| **Diferença** | $-$ | `EXCEPT` (ou `MINUS`) |
| **Renomeação** | $\rho$ | `AS` |
| **Agregação** | $\mathcal{F}$ | `GROUP BY`, `SUM()`, `AVG()`, `COUNT()` |
