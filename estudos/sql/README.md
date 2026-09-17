# Estudos em Banco de Dados e SQL — Caderno de Anotações

Caderno de anotações teóricas, regras de modelagem e consultas práticas em SQL (voltado para PostgreSQL, MySQL e SQLite).

---

## Objetivo
Documentar a base teórica e prática de bancos de dados relacionais: partindo dos fundamentos matemáticos da álgebra relacional, passando pelos três níveis de modelagem (conceitual, lógica e física), regras formais de normalização (até BCNF), até o domínio completo da sintaxe SQL (DDL, DML, DQL, DCL, TCL) e técnicas de performance (índices e otimização).

Além das anotações conceituais deste caderno, os scripts práticos executáveis estão disponíveis em:
- [pratica_ddl_constraints.sql](./pratica_ddl_constraints.sql): Criação de esquemas, tabelas e constraints na prática.
- [pratica_dml_queries.sql](./pratica_dml_queries.sql): Inserções de teste e consultas analíticas (Joins, Agrupamentos, Filtros).
- [pratica_avancada.sql](./pratica_avancada.sql): Transações, Views, Triggers e análise de desempenho.

---

## Estrutura do Módulo

- **Parte 1:** Álgebra Relacional (a matemática por trás do SQL)
- **Parte 2:** Modelagem de Dados (Conceitual, Lógica e Física)
- **Parte 3:** Chaves, Dependência Funcional e Formas Normais (1FN a BCNF)
- **Parte 4:** Divisão dos Comandos SQL (DDL, DQL, DML, DCL, TCL)
- **Parte 5:** Consultas Avançadas, Joins e Filtros (DQL detalhado)
- **Parte 6:** Views, Triggers, Índices e Otimização de Consultas

---

## Parte 1: Álgebra Relacional

A álgebra relacional é a teoria matemática criada por Edgar F. Codd (1970) que serviu de alicerce para a criação dos bancos relacionais e da linguagem SQL. Ela trata tabelas como relações (conjuntos de tuplas/linhas) e define operadores com **propriedade de fechamento**: qualquer operação sobre uma ou mais relações resulta sempre em uma nova relação.

### Anotações e Operadores:
- **Seleção ($\sigma$):** Filtra linhas (tuplas) com base em uma condição lógica. Opera na horizontal da tabela.
  - No SQL: vira a cláusula `WHERE`.
  - Exemplo: $\sigma_{salario > 4000}(Funcionarios) \to$ `SELECT * FROM funcionarios WHERE salario > 4000;`
- **Projeção ($\pi$):** Escolhe quais colunas (atributos) exibir, descartando o resto. Opera na vertical da tabela.
  - No SQL: vira a lista de colunas no `SELECT`.
  - Exemplo: $\pi_{nome, email}(Clientes) \to$ `SELECT DISTINCT nome, email FROM clientes;`
  - *Detalhe:* na álgebra pura, a projeção elimina duplicatas automaticamente (porque relação é conjunto matemático). No SQL, o `SELECT` mantém duplicatas por padrão, precisando do `DISTINCT` para emular o comportamento puro.
- **Produto Cartesiano ($\times$):** Cruza todas as linhas da tabela A com todas as linhas da tabela B ($n \times m$ linhas).
  - No SQL: `CROSS JOIN` (ou `SELECT * FROM A, B;`).
- **Junção ($\bowtie$):** É um produto cartesiano seguido de uma seleção que cruza chaves correspondentes.
  - No SQL: `INNER JOIN ... ON ...`.
- **União ($\cup$):** Junta os registros de duas tabelas de mesma estrutura, eliminando duplicatas.
  - No SQL: `UNION`. Para manter duplicatas no SQL usa-se `UNION ALL`.
- **Diferença ($-$):** Registros que estão na primeira tabela mas não estão na segunda.
  - No SQL: `EXCEPT` (no PostgreSQL/SQLite) ou `MINUS` (no Oracle).
- **Interseção ($\cap$):** Apenas os registros presentes em ambas as tabelas ao mesmo tempo.
  - No SQL: `INTERSECT`.
- **Renomeação ($\rho$):** Dá um apelido temporário à tabela ou coluna.
  - No SQL: `AS`.

---

## Parte 2: Modelagem de Dados (Conceitual, Lógica e Física)

Modelar dados é entender as regras de negócio e estruturá-las para que o banco seja íntegro, rápido e sem redundâncias inúteis. O processo segue três etapas bem definidas:

### 1. Modelo Conceitual
- É o modelo de mais alto nível, 100% independente de tecnologia, SGBD ou sintaxe SQL.
- Focado no negócio e no vocabulário do cliente.
- Ferramenta padrão: **MER (Modelo Entidade-Relacionamento)** / Diagrama ER.
- **Entidades:**
  - *Forte:* Existe por si só, tem identificador próprio (ex: `CLIENTE`, `PRODUTO`).
  - *Fraca:* Só existe se a entidade mãe existir, depende da chave da mãe (ex: `DEPENDENTE` só existe associado a um `FUNCIONARIO`).
- **Atributos:**
  - *Simples (atômico):* Indivisível (ex: `idade`, `cpf`).
  - *Composto:* Pode ser quebrado em partes (ex: `endereco` que se desdobra em `rua`, `bairro`, `cep`, `cidade`).
  - *Monovalorado:* Um único valor por registro (ex: `data_nascimento`).
  - *Multivalorado:* Pode ter vários valores para o mesmo registro (ex: `telefones`, `redes_sociais`). No modelo relacional, atributo multivalorado precisa virar tabela própria para respeitar a 1FN.
  - *Derivado:* Valor calculado a partir de outro (ex: `idade` derivada de `data_nascimento`, ou `total` derivado de `preco * quantidade`). Não deve ser armazenado fisicamente sem necessidade.
- **Relacionamentos e Cardinalidade:**
  - Mostra quantas instâncias de uma entidade podem se associar a instâncias de outra.
  - Cardinalidade Mínima (0 ou 1): define se a participação é opcional (0) ou obrigatória (1).
  - Cardinalidade Máxima (1 ou N): define se o limite é um único registro (1) ou muitos (N).
  - Pares comuns: (0,1), (1,1), (0,N), (1,N).
- **Generalização e Especialização (Herança):**
  - Cria uma superclasse com atributos comuns e subclasses com atributos específicos (ex: `PESSOA` genérica, especializada em `PESSOA_FISICA` e `PESSOA_JURIDICA`).
  - *Total:* Todo registro da mãe TEM que ser de alguma filha.
  - *Parcial:* Podem existir registros na mãe que não pertencem a nenhuma filha.
  - *Disjunta:* Exclusiva. O registro só pode ser de UMA filha (ou é PF ou é PJ).
  - *Sobreposta:* O registro pode ser de mais de uma filha ao mesmo tempo (ex: alguém pode ser `ALUNO` e `PROFESSOR` simultaneamente).

### 2. Modelo Lógico
- Adapta o modelo conceitual para as regras do paradigma relacional (tabelas, colunas e chaves), ainda sem se prender a detalhes de hardware ou arquivos de um SGBD específico.
- **Regras clássicas de mapeamento:**
  - **Relacionamento 1:1:** A chave primária de uma tabela vai para a outra como chave estrangeira com restrição `UNIQUE` (ou as duas tabelas viram uma só se ambas forem obrigatórias).
  - **Relacionamento 1:N:** A chave primária do lado **1** migra como chave estrangeira (FK) para o lado **N** (Muitos). Exemplo: o `departamento_id` vai para dentro da tabela de `funcionarios`.
  - **Relacionamento N:M:** Gera obrigatoriamente uma **tabela associativa / intermediária**. A chave primária dessa tabela intermediária costuma ser a combinação das FKs das duas tabelas originais, além de guardar atributos que pertencem à relação (ex: tabela `matriculas(aluno_id, curso_id, data_matricula)`).

### 3. Modelo Físico
- Implementação direta no SGBD escolhido (PostgreSQL, MySQL, SQLite, etc.).
- Envolve os scripts DDL reais, definição de tipos exatos de colunas (`INT`, `BIGINT`, `VARCHAR(100)`, `NUMERIC(10,2)`, `TIMESTAMPTZ`, `UUID`), constraints de integridade, criação de índices, partições e configurações de armazenamento.

---

## Parte 3: Chaves, Dependência Funcional e Normalização

### Tipos de Chaves
- **Superchave:** Qualquer conjunto de uma ou mais colunas que identifica de forma única uma linha da tabela (ex: `{cpf}`, `{cpf, nome}`, `{cpf, email}`).
- **Chave Candidata:** Uma superchave mínima. Se você tirar qualquer coluna dela, ela deixa de identificar a linha de forma única (ex: `{cpf}` e `{email}`).
- **Chave Primária (PK):** A chave candidata escolhida para ser o identificador oficial da tabela. Não pode aceitar nulos (`NOT NULL`) e não pode ter duplicatas (`UNIQUE`).
- **Chave Alternativa:** As chaves candidatas que sobraram e não foram escolhidas como primária. No banco, devem ser protegidas com `UNIQUE`.
- **Chave Estrangeira (FK):** Coluna que aponta para a chave primária de outra tabela, garantindo que não existam registros órfãos (integridade referencial).
- **Chave Composta:** Chave primária formada por duas ou mais colunas juntas (comum em tabelas de N:M).
- **Surrogate Key (Chave Substituta/Artificial):** Um ID numérico ou UUID gerado automaticamente (`SERIAL`, `AUTO_INCREMENT`), sem significado de negócio.
- **Natural Key (Chave Natural):** Um atributo que já existe no mundo real (ex: CPF, CNPJ, código ISBN). No dia a dia de engenharia de dados, prefere-se surrogate keys para evitar problemas caso uma chave natural precise ser corrigida ou mude de formato.

### Dependência Funcional (DF)
Dizemos que $X \to Y$ ($X$ determina funcionalmente $Y$) quando, para cada valor de $X$, existe exatamente um único valor correspondente de $Y$.
- Exemplo: `cpf -> nome` (sabendo o CPF, você descobre com certeza o nome correspondente).
- **Tipos de Dependência:**
  - *Dependência Total:* $Y$ depende da chave inteira, e não de um pedaço dela (obrigatório para chaves compostas na 2FN).
  - *Dependência Parcial:* $Y$ depende de apenas uma coluna de uma chave primária que é composta.
  - *Dependência Transitiva:* $X \to Y$ e $Y \to Z$. O atributo $Z$ depende indiretamente de $X$ através de $Y$ (ambos não-chave).

### As Formas Normais
Normalizar é organizar as colunas e tabelas para eliminar redundância desnecessária e evitar **anomalias de inserção, alteração e exclusão**.

```text
Tabela Bruta (Não normalizada)
       │
       ▼
   [ 1FN ]  ──> Eliminar atributos multivalorados e garantir atomicidade
       │
       ▼
   [ 2FN ]  ──> Estar na 1FN + Eliminar dependências parciais da PK composta
       │
       ▼
   [ 3FN ]  ──> Estar na 2FN + Eliminar dependências transitivas (não-chave -> não-chave)
       │
       ▼
  [ BCNF ]  ──> Estar na 3FN + Para toda dependência X -> Y, X DEVE ser superchave
```

#### 1FN (Primeira Forma Normal)
- **Regra:** Todos os valores devem ser atômicos (indivisíveis). Proibido ter colunas com listas, vetores ou valores separados por vírgula. Cada linha deve ser identificável unicamente.
- *Exemplo de erro:* Coluna `telefones` guardando `"619999-0001, 619999-0002"`.
- *Correção:* Criar uma tabela separada `telefones_clientes(cliente_id, telefone)`.

#### 2FN (Segunda Forma Normal)
- **Regra:** Estar na 1FN e **não ter dependência parcial**. Todos os atributos não-chave devem depender da chave primária inteira.
- *Nota prática:* Se a sua tabela tem uma chave primária simples (de uma só coluna, como `id`), e já está na 1FN, ela já está automaticamente na 2FN. A 2FN só corre risco de ser violada quando a PK é composta.
- *Exemplo de erro:* Tabela `itens_pedido` com PK composta `(pedido_id, produto_id)` contendo as colunas `quantidade`, `nome_produto` e `preco_produto`.
  - `quantidade` depende de `(pedido_id, produto_id)` -> Dependência Total.
  - `nome_produto` depende só de `produto_id` -> Dependência Parcial! Se o produto mudar de nome, teríamos que atualizar milhares de linhas de pedidos antigos.
- *Correção:* Separar `produtos(produto_id, nome_produto, preco_produto)` e deixar em `itens_pedido(pedido_id, produto_id, quantidade)`.

#### 3FN (Terceira Forma Normal)
- **Regra:** Estar na 2FN e **não ter dependência transitiva**. Nenhum atributo não-chave pode depender de outro atributo não-chave.
- *Exemplo de erro:* Tabela `funcionarios(id, nome, departamento_id, nome_departamento, andar_departamento)`.
  - `id -> departamento_id`
  - `departamento_id -> nome_departamento, andar_departamento`
  - Aqui, `nome_departamento` depende de `departamento_id`, que não é a PK da tabela.
- *Correção:* Mover os dados do departamento para uma tabela própria: `departamentos(id, nome, andar)` e deixar em funcionários apenas a chave estrangeira `departamento_id`.

#### BCNF / FNBC (Forma Normal de Boyce-Codd)
- **Regra:** É uma versão mais rigorosa da 3FN. Para **toda** dependência funcional $X \to Y$, o lado esquerdo ($X$) **tem que ser obrigatoriamente uma Superchave**.
- Na 3FN tradicional existia uma brecha: se $Y$ fosse um atributo primo (fizesse parte de alguma chave candidata), a regra passava mesmo se $X$ não fosse superchave. A BCNF fecha essa brecha.
- *Cenário clássico de violação:*
  - Tabela de agendamento de consultorias: `consultorias(aluno_id, materia, professor)`.
  - Regra 1: Cada aluno tem só um professor para cada matéria: `(aluno_id, materia) -> professor`.
  - Regra 2: Cada professor leciona apenas UMA matéria: `professor -> materia`.
  - Chaves candidatas: `(aluno_id, materia)` e `(aluno_id, professor)`.
  - Observe a dependência `professor -> materia`: o atributo `materia` faz parte de uma chave candidata (é atributo primo), então a tabela passa na 3FN!
  - Mas `professor` sozinho **não é uma superchave**. Logo, **viola a BCNF**.
  - *Problema prático:* Não conseguimos cadastrar que um novo professor dá aula de determinada matéria sem antes matricular um aluno com ele.
  - *Correção:* Decompor em:
    1. `professores(professor, materia)` onde `professor` é PK (superchave).
    2. `orientacoes(aluno_id, professor)` onde ambos formam a PK.

---

## Parte 4: Divisão dos Comandos SQL

A linguagem SQL é dividida em subconjuntos conforme o tipo de instrução:

| Sigla | Significado | Finalidade | Comandos Principais |
| :--- | :--- | :--- | :--- |
| **DDL** | Data Definition Language | Cria, altera e remove a estrutura física de tabelas e esquemas. | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| **DML** | Data Manipulation Language | Insere, atualiza e remove os dados armazenados nas linhas. | `INSERT`, `UPDATE`, `DELETE` |
| **DQL** | Data Query Language | Realiza consultas e extrações de dados sem alterar o banco. | `SELECT` |
| **DCL** | Data Control Language | Gerencia permissões, privilégios e controle de segurança de usuários. | `GRANT`, `REVOKE` |
| **TCL** | Transaction Control Language | Gerencia o controle de transações garantindo consistência (ACID). | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

---

## Parte 5: DDL e Constraints (Estrutura)

### Comandos de DDL
- `CREATE TABLE`: Cria uma nova tabela e define os tipos das colunas.
- `ALTER TABLE`: Altera estrutura de tabela existente (adiciona coluna, altera tipo, renomeia, adiciona constraints).
- `DROP TABLE`: Apaga a tabela inteira e seus dados do disco.
- `TRUNCATE TABLE`: Esvazia todas as linhas da tabela de forma rápida, sem registrar log linha a linha como o DELETE faz, e reinicia sequences.

### Constraints (Restrições de Integridade)
Constraints são regras aplicadas nas colunas para impedir que dados inválidos ou corrompidos entrem no banco:

1. **`PRIMARY KEY` (PK):** Identificador exclusivo. Combina `NOT NULL` com `UNIQUE`.
2. **`FOREIGN KEY` (FK):** Garante a integridade referencial com a tabela mãe.
   - `ON DELETE RESTRICT` (padrão): Impede apagar o registro pai se houver filhos amarrados a ele.
   - `ON DELETE CASCADE`: Apagou o pai, o banco apaga automaticamente todos os filhos correspondentes.
   - `ON DELETE SET NULL`: Apagou o pai, o banco preenche a FK dos filhos com `NULL`.
3. **`NOT NULL`:** Não permite que o campo fique vazio/nulo.
4. **`UNIQUE`:** Impede valores repetidos naquela coluna (permite `NULL`, a menos que tenha `NOT NULL` junto).
5. **`CHECK`:** Condição customizada que toda linha precisa respeitar (ex: `salario > 0`, `status IN ('ativo', 'inativo')`).
6. **`DEFAULT`:** Preenche um valor padrão se a linha for inserida sem especificar aquele campo (ex: `DEFAULT CURRENT_TIMESTAMP` ou `DEFAULT 'ativo'`).

---

## Parte 6: DQL — Consultas, Filtros, Agrupamentos e Joins

### Ordem de Escrita vs. Ordem Real de Execução no SGBD
Entender como o banco processa a consulta é fundamental para escrever consultas eficientes:

```text
Ordem em que você escreve:        Ordem em que o banco executa internamente:
1. SELECT                         1. FROM / JOIN (localiza e cruza as tabelas)
2. FROM / JOIN                    2. WHERE (filtra as linhas brutas)
3. WHERE                          3. GROUP BY (agrupa os dados filtrados)
4. GROUP BY                       4. HAVING (filtra os grupos consolidados)
5. HAVING                         5. SELECT (projeta as colunas e executa aliases)
6. ORDER BY                       6. DISTINCT (elimina duplicatas)
7. LIMIT / OFFSET                 7. ORDER BY (ordena o resultado final)
                                  8. LIMIT / OFFSET (corta a quantidade de linhas)
```
*Por isso você não pode usar um alias criado no `SELECT` dentro da cláusula `WHERE`: o `WHERE` executa muito antes do `SELECT` ser processado!*

### Cláusulas e Operadores:
- **`SELECT ... FROM`:** Projeta colunas de uma tabela.
- **`WHERE`:** Filtra linhas antes de qualquer agrupamento.
- **Operadores de Comparação e Filtro:**
  - `=`, `<>`, `!=`, `<`, `>`, `<=`, `>=`.
  - `IN ('SP', 'RJ', 'MG')`: Verifica pertinência a uma lista de valores.
  - `NOT IN`: Negação de pertinência. *(Cuidado: se a subconsulta do NOT IN retornar algum NULL, o resultado todo pode vir vazio).*
  - `BETWEEN 100 AND 500`: Intervalo inclusivo.
  - `LIKE 'Ana%'`: Busca textual sensível a maiúsculas (usa `%` para múltiplos caracteres e `_` para um caractere).
  - `ILIKE 'ana%'`: Busca insensível (case-insensitive, muito comum no PostgreSQL).
  - `IS NULL` e `IS NOT NULL`: Verificação de valores nulos. **Nunca use `= NULL`**, pois em SQL `NULL = NULL` resulta em `UNKNOWN`, não em verdadeiro!
- **`ORDER BY`:** Ordena resultados por uma ou mais colunas de forma ascendente (`ASC`, padrão) ou descendente (`DESC`).
- **`LIMIT` e `OFFSET`:** Paginação de resultados. `LIMIT 10` traz 10 registros, `OFFSET 20` pula os 20 primeiros.
- **`DISTINCT`:** Remove linhas duplicadas do resultado final.
- **`COUNT(DISTINCT coluna)`:** Conta a quantidade de valores únicos e não nulos daquela coluna.
- **`AS`:** Define aliases (apelidos) legíveis para colunas ou tabelas.

### Funções de Agregação
Consolidam várias linhas em um único valor resumido. Ignoram valores `NULL` (com exceção de `COUNT(*)`):
- `COUNT(*)`: Conta o número total de linhas.
- `COUNT(coluna)`: Conta o número de linhas onde aquela coluna não é nula.
- `SUM(coluna)`: Soma dos valores numéricos.
- `AVG(coluna)`: Média aritmética simples dos valores não nulos.
- `MAX(coluna)`: Retorna o maior valor.
- `MIN(coluna)`: Retorna o menor valor.

### `GROUP BY` e `HAVING`
- **`GROUP BY`:** Divide as linhas em grupos com base em uma ou mais colunas. Todas as colunas presentes no `SELECT` que não estejam dentro de uma função de agregação **devem** obrigatoriamente estar listadas no `GROUP BY`.
- **`HAVING`:** Funciona como um filtro para os **grupos consolidados**, após as funções de agregação terem sido calculadas.
  - *Diferença de ouro:* `WHERE` filtra **linhas antes de agrupar**; `HAVING` filtra **grupos já formados**.

```sql
SELECT 
    departamento_id,
    COUNT(*) AS total_funcionarios,
    ROUND(AVG(salario), 2) AS media_salarial
FROM funcionarios
WHERE status = 'ativo'                -- Filtra linha a linha antes
GROUP BY departamento_id
HAVING COUNT(*) > 5 AND AVG(salario) > 4000  -- Filtra grupos agregados
ORDER BY media_salarial DESC;
```

### Joins (Junções de Tabelas)
Permitem cruzar informações de duas ou mais tabelas usando as chaves de relacionamento:

```text
       INNER JOIN                     LEFT JOIN                    RIGHT JOIN
    ┌───────┬───────┐              ┌───────┬───────┐            ┌───────┬───────┐
    │       │ XXXXX │              │ XXXXX │ XXXXX │            │       │ XXXXX │
    │   A   │ XXXXX │  B           │ XXXXX │ XXXXX │  B         │   A   │ XXXXX │  B
    │       │ XXXXX │              │ XXXXX │       │            │       │ XXXXX │
    └───────┴───────┘              └───────┴───────┘            └───────┴───────┘
  Apenas correspondências         Tudo da esquerda +            Tudo da direita +
    presentes em ambas           correspondências da direita    correspondências da esquerda
```

- **`INNER JOIN`:** Retorna somente as linhas que possuem correspondência em **ambas** as tabelas. Linhas sem par são descartadas.
- **`LEFT JOIN` (ou `LEFT OUTER JOIN`):** Retorna **todas** as linhas da tabela da esquerda (a que vem no `FROM`), mais os dados correspondentes da tabela da direita. Se não houver correspondência na direita, os campos dela vêm preenchidos como `NULL`.
- **`RIGHT JOIN`:** O inverso do Left Join. Retorna todas as linhas da tabela da direita. Na prática da indústria, quase sempre se padroniza o uso de `LEFT JOIN`, invertendo a ordem das tabelas se necessário, por questão de legibilidade.
- **`FULL OUTER JOIN`:** Retorna todas as linhas de ambas as tabelas, preenchendo com `NULL` onde não houver casamento.
- **`CROSS JOIN`:** Produto cartesiano puro (cruza todas as linhas com todas as linhas).

---

## Parte 7: DML — Manipulação de Dados

### `INSERT INTO`
Insere novos registros na tabela.
```sql
-- Inserção especificando colunas
INSERT INTO departamentos (nome, orcamento) 
VALUES ('Engenharia de Dados', 150000.00);

-- Inserção múltipla em batch
INSERT INTO clientes (nome, email) VALUES 
('Lucas Silva', 'lucas@email.com'),
('Mariana Costa', 'mariana@email.com');

-- Inserção a partir de consulta (INSERT INTO ... SELECT)
INSERT INTO historico_salarios (funcionario_id, salario, registrado_em)
SELECT id, salario, CURRENT_DATE FROM funcionarios WHERE status = 'ativo';
```

### `UPDATE`
Altera dados de linhas já existentes.
> **Atenção:** Sempre use `WHERE` no update, a menos que você realmente queira alterar a tabela inteira!
```sql
UPDATE funcionarios
SET salario = salario * 1.10, status = 'promovido'
WHERE departamento_id = 3 AND salario < 5000;
```

### `DELETE`
Remove linhas da tabela.
```sql
-- Deleta registros específicos
DELETE FROM logs_sessao
WHERE data_evento < CURRENT_DATE - INTERVAL '30 days';
```

---

## Parte 8: TCL, Transações e o Padrão ACID

Uma transação é uma sequência de operações executadas como uma unidade de trabalho única e indivisível. Ou tudo é gravado com sucesso, ou nada é gravado.

### As Propriedades ACID:
- **Atomicidade:** Tudo ou nada. Se uma etapa falhar, o banco desfaz todas as alterações anteriores daquela transação (`ROLLBACK`).
- **Consistência:** A transação só pode levar o banco de um estado válido para outro estado válido, respeitando todas as constraints e integridades.
- **Isolamento:** Transações simultâneas não devem interferir de forma descontrolada umas nas outras.
- **Durabilidade:** Uma vez confirmada a transação (`COMMIT`), os dados ficam salvos permanentemente no disco, mesmo em caso de queda de energia do servidor.

```sql
BEGIN; -- ou START TRANSACTION

UPDATE contas SET saldo = saldo - 500.00 WHERE id = 1;
UPDATE contas SET saldo = saldo + 500.00 WHERE id = 2;

-- Se tudo deu certo:
COMMIT;

-- Se algo deu errado no meio:
-- ROLLBACK;
```

---

## Parte 9: DCL — Controle de Acesso e Segurança

Gerencia usuários, perfis (roles) e permissões no banco:
- **`GRANT`:** Concede privilégios a usuários ou roles.
- **`REVOKE`:** Remove privilégios concedidos anteriormente.

```sql
-- Criar role de analista de dados apenas com permissão de leitura
CREATE ROLE analista_dados;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analista_dados;

-- Conceder permissão ao usuário
GRANT analista_dados TO usuario_henrique;

-- Revogar permissão de escrita/deleção se houver
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM usuario_henrique;
```

---

## Parte 10: Views, Triggers, Índices e Otimização

### Views (Visões)
Uma `VIEW` é uma consulta SQL salva no catálogo do banco que funciona como uma tabela virtual. Não duplica dados em disco, apenas encapsula a lógica da consulta facilitando relatórios e aumentando a segurança (restringindo colunas confidenciais).
```sql
CREATE VIEW vw_resumo_departamentos AS
SELECT 
    d.nome AS departamento,
    COUNT(f.id) AS total_funcionarios,
    COALESCE(SUM(f.salario), 0) AS folha_mensal
FROM departamentos d
LEFT JOIN funcionarios f ON d.id = f.departamento_id
GROUP BY d.nome;
```

### Triggers (Gatilhos)
Procedimentos automáticos disparados pelo SGBD antes ou depois de eventos DML (`INSERT`, `UPDATE`, `DELETE`).
- Muito usados para auditoria (gravar quem alterou o que e quando) ou validações complexas.
- No PostgreSQL, um trigger invoca uma `FUNCTION` que retorna um tipo `TRIGGER`:
```sql
CREATE OR REPLACE FUNCTION audit_salario_func()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO auditoria_salarios(funcionario_id, salario_antigo, salario_novo, alterado_em)
        VALUES (OLD.id, OLD.salario, NEW.salario, NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_salario
AFTER UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION audit_salario_func();
```

### Índices e Otimização de Consultas
Um índice é uma estrutura de dados auxiliar (geralmente uma árvore balanceada **B-Tree**) que acelera a localização de linhas sem precisar varrer a tabela inteira linha a linha (**Seq Scan** / *Full Table Scan*).

- **Quando criar índices:**
  - Colunas frequentemente usadas em filtros `WHERE` seletivos.
  - Colunas usadas como chaves de junção `ON` em `JOINs`.
  - Colunas ordenadas com frequência em `ORDER BY`.
- **Quando NÃO criar índices:**
  - Tabelas muito pequenas (o Seq Scan é mais rápido que carregar o índice).
  - Tabelas que sofrem altíssimo volume de `INSERT`/`UPDATE` contínuo, pois cada inserção física exige atualizar os índices em disco, degradando a escrita.
  - Colunas com baixa cardinalidade (ex: booleano com 50% true e 50% false).

```sql
-- Criação de índice convencional B-Tree
CREATE INDEX idx_funcionarios_email ON funcionarios(email);

-- Índice Composto (para filtros que combinam departamento e status)
CREATE INDEX idx_func_dept_status ON funcionarios(departamento_id, status);
```

### Dicas Práticas de Performance e Sargabilidade (Sargable Queries)
1. **Evite `SELECT *` em produção:** Puxe apenas as colunas necessárias para economizar largura de banda, memória e I/O de disco.
2. **Sargabilidade:** O otimizador de consultas do banco não consegue usar índices se você envelopar a coluna indexada dentro de uma função no `WHERE`.
   - Ruim (não usa índice): `WHERE EXTRACT(YEAR FROM criado_em) = 2026`
   - Bom (usa índice): `WHERE criado_em >= '2026-01-01' AND criado_em < '2027-01-01'`
3. **Analise o plano de execução:** No PostgreSQL, use `EXPLAIN ANALYZE <sua consulta>` para ver o tempo real gasto, custo estimado e se o banco usou `Index Scan` ou `Seq Scan`.
