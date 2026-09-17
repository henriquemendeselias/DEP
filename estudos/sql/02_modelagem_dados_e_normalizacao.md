# Modelagem de Dados, Chaves e Normalização

Caderno detalhado cobrindo o processo de estruturação de dados relacionais: do nível abstrato (conceitual) até o nível de armazenamento (físico), além da teoria formal de chaves e formas normais até a Forma Normal de Boyce-Codd (BCNF).

---

## 1. Níveis de Modelagem de Dados

```text
  [ Modelo Conceitual ]  ---> Focado no negócio, entidades e relacionamentos (MER/DER)
           │
           ▼ (Mapeamento)
    [ Modelo Lógico ]    ---> Regras relacionais, tabelas, colunas, PKs e FKs
           │
           ▼ (Implementação física)
    [ Modelo Físico ]    ---> Tipos de dados específicos do SGBD, DDL, constraints e índices
```

### 1.1. Modelo Conceitual
Independente de SGBD e de tecnologia. Focado no entendimento das regras de negócio do problema.
- **Entidades:**
  - *Forte:* Possui existência própria e identificador autônomo (ex: `CLIENTE`, `PRODUTO`).
  - *Fraca:* Depende da existência de uma entidade forte para existir, necessitando de uma chave parcial/discriminador (ex: `DEPENDENTE` de um `FUNCIONARIO`).
- **Atributos:**
  - *Simples / Atômico:* Indivisível no contexto do negócio (ex: `idade`, `salario`).
  - *Composto:* Pode ser dividido em partes menores (ex: `endereco` -> `rua`, `numero`, `bairro`, `cep`).
  - *Monovalorado:* Guarda no máximo um valor por entidade (ex: `cpf`).
  - *Multivalorado:* Pode conter múltiplos valores para uma mesma entidade (ex: `telefones`).
  - *Derivado:* Valor calculável a partir de outros atributos existentes (ex: `idade` a partir da `data_nascimento`).
- **Relacionamentos e Cardinalidade:**
  - Cardinalidade mínima (0 ou 1): define se a participação é opcional ou obrigatória.
  - Cardinalidade máxima (1 ou N): define se o limite é unitário ou múltiplo.
  - Notações usuais: (0,1), (1,1), (0,N), (1,N).
- **Generalização e Especialização:**
  - Modela hierarquia/herança entre uma superclasse genérica e subclasses especializadas (ex: `PESSOA` especializada em `PESSOA_FISICA` e `PESSOA_JURIDICA`).
  - *Total:* Toda instância da superclasse é obrigatoriamente instância de alguma subclasse.
  - *Parcial:* Podem existir instâncias da superclasse que não pertencem a nenhuma subclasse.
  - *Disjunta:* Instância só pode pertencer a uma subclasse exclusiva (ou é PF ou é PJ).
  - *Sobreposta:* Uma instância pode pertencer a mais de uma subclasse simultaneamente (ex: um `FUNCIONARIO` que também é `ALUNO`).

---

### 1.2. Modelo Lógico
Mapeia o modelo conceitual para as estruturas tabulares do paradigma relacional.
- **Regras de Mapeamento DER para Tabelas:**
  - **Relacionamento 1:1:** A PK de um dos lados migra como FK para o outro lado, recebendo constraint `UNIQUE` (ou as duas tabelas são unificadas se ambos os lados forem obrigatórios).
  - **Relacionamento 1:N:** A chave primária da tabela do lado **1** migra como chave estrangeira (FK) para a tabela do lado **N** (Muitos).
  - **Relacionamento N:M:** Gera obrigatoriamente uma **tabela associativa / intermediária**. A chave primária dessa nova tabela é tipicamente a combinação das FKs das duas tabelas de origem, contendo ainda atributos que pertencem à relação em si.

---

### 1.3. Modelo Físico
Implementação direta no SGBD (PostgreSQL, MySQL, SQLite). Envolve scripts DDL, escolha de tipos primitivos (`VARCHAR`, `INT`, `NUMERIC`, `TIMESTAMPTZ`, `UUID`), constraints de validação, criação de índices B-Tree e partições de disco.

---

## 2. Teoria de Chaves no Modelo Relacional

| Tipo de Chave | Definição | Exemplo |
| :--- | :--- | :--- |
| **Superchave** | Qualquer conjunto de um ou mais atributos cujos valores identificam unicamente uma linha da tabela. | `{cpf}`, `{cpf, nome}`, `{cpf, email}` |
| **Chave Candidata** | Uma superchave mínima (sem atributos redundantes). | `{cpf}` e `{email}` na tabela de usuários |
| **Chave Primária (PK)** | A chave candidata escolhida para identificar as linhas da tabela. Não permite nulos (`NOT NULL`) nem repetições (`UNIQUE`). | Coluna `id` ou `cpf` |
| **Chave Alternativa** | As chaves candidatas que não foram eleitas como chave primária. Devem receber restrição `UNIQUE`. | Coluna `email` quando `id` é a PK |
| **Chave Estrangeira (FK)** | Coluna que referencia a PK de outra tabela, garantindo integridade referencial. | Coluna `departamento_id` em `funcionarios` |
| **Chave Composta** | Chave primária formada por duas ou mais colunas combinadas. | `(pedido_id, produto_id)` em `itens_pedido` |
| **Surrogate Key (Substituta)** | Identificador artificial/sintético sem regra de negócio (geralmente `SERIAL`, `BIGINT` ou `UUID`). | Coluna `id` autoincremento |
| **Natural Key (Natural)** | Atributo identificador que existe no mundo real. | CPF, CNPJ, ISBN |

---

## 3. Dependências Funcionais e Anomalias

### Conceito de Dependência Funcional (DF)
Dado um esquema de relação $R$, o atributo $Y$ é funcionalmente dependente de $X$ ($X \to Y$) se, e somente se, cada valor de $X$ estiver associado a no máximo um único valor de $Y$.
- Exemplo: $CPF \to Nome$.

### Tipos de Dependência:
1. **Dependência Funcional Total:** $Y$ depende da chave completa $X$, e de nenhum subconjunto de $X$. É o requisito central da 2FN para chaves compostas.
2. **Dependência Funcional Parcial:** $Y$ depende de apenas uma parte de uma chave composta.
3. **Dependência Funcional Transitiva:** $X \to Y$ e $Y \to Z$. O atributo $Z$ depende indiretamente de $X$ por meio de $Y$ (ambos não-chave). É o que a 3FN elimina.

### Anomalias de Falta de Normalização:
- **Anomalia de Inserção:** Impossibilidade de cadastrar um dado sem precisar inventar outro artificialmente.
- **Anomalia de Exclusão:** Perda não intencional de informações importantes ao deletar uma linha.
- **Anomalia de Atualização:** Risco de inconsistência ao alterar um mesmo dado repetido em vários registros.

---

## 4. Normalização de Dados (1FN até BCNF)

### 4.1. Primeira Forma Normal (1FN)
- **Regra:** Todos os atributos devem conter valores atômicos (indivisíveis). É proibido guardar listas, vetores ou múltiplos valores separados por vírgula em uma mesma célula.
- *Problema:*
  - `clientes(id, nome, telefones)` onde telefones = `"61999-1111, 61888-2222"`.
- *Solução:*
  - `clientes(id [PK], nome)`
  - `telefones_cliente(cliente_id [FK], telefone, PRIMARY KEY(cliente_id, telefone))`

---

### 4.2. Segunda Forma Normal (2FN)
- **Regra:** Estar na 1FN e **eliminar dependências parciais da chave primária**. Todos os atributos não-chave devem depender da PK por inteiro.
- *Observação:* Se a chave primária da tabela for simples (uma coluna só), e a tabela já estiver na 1FN, ela já está garantida na 2FN.
- *Problema (PK composta com dependência parcial):*
  - `itens_pedido(pedido_id [PK], produto_id [PK], quantidade, nome_produto, preco_produto)`
  - `(pedido_id, produto_id) -> quantidade` (Dependência Total)
  - `produto_id -> nome_produto, preco_produto` (Dependência Parcial: depende só de parte da PK)
- *Solução:*
  - `produtos(id [PK], nome_produto, preco_produto)`
  - `itens_pedido(pedido_id [FK], produto_id [FK], quantidade, PRIMARY KEY(pedido_id, produto_id))`

---

### 4.3. Terceira Forma Normal (3FN)
- **Regra:** Estar na 2FN e **eliminar dependências transitivas**. Nenhum atributo não-chave pode determinar outro atributo não-chave.
- *Problema (Dependência transitiva):*
  - `funcionarios(id [PK], nome, departamento_id, nome_departamento, localizacao_departamento)`
  - `id -> departamento_id`
  - `departamento_id -> nome_departamento, localizacao_departamento`
- *Solução:*
  - `departamentos(id [PK], nome_departamento, localizacao)`
  - `funcionarios(id [PK], nome, departamento_id [FK])`

---

### 4.4. Forma Normal de Boyce-Codd (BCNF / FNBC)
- **Regra:** Versão rigorosa da 3FN. Para toda dependência funcional não-trivial $X \to Y$, o determinante **$X$ deve ser obrigatoriamente uma Superchave**.
- Na 3FN existia uma tolerância: se $Y$ fosse um atributo primo (fizesse parte de alguma chave candidata), a tabela era considerada na 3FN mesmo se $X$ não fosse superchave. A BCNF proíbe isso quando há múltiplas chaves candidatas compostas sobrepostas.

#### Cenário Prático de Violação da BCNF:
- Tabela de consultoria acadêmica: `consultorias(aluno_id, materia, professor)`
- Regras de negócio:
  1. Cada aluno tem apenas um professor para cada matéria: `(aluno_id, materia) -> professor`.
  2. Cada professor leciona somente uma única matéria: `professor -> materia`.
- Chaves candidatas: `(aluno_id, materia)` e `(aluno_id, professor)`.
- Atributos primos: `aluno_id`, `materia`, `professor`.
- Análise de `professor -> materia`:
  - Na 3FN: `materia` é atributo primo, então passa na 3FN.
  - Na BCNF: `professor` sozinho NÃO é superchave da tabela inteira. Logo, viola a BCNF.
- Anomalia gerada: Não é possível cadastrar um professor e sua respectiva matéria antes que algum aluno contrate uma consultoria com ele.
- Decomposição em BCNF:
  1. `professores(professor [PK], materia)` -> onde `professor -> materia` e `professor` é superchave.
  2. `orientacoes(aluno_id, professor [FK], PRIMARY KEY(aluno_id, professor))`.
