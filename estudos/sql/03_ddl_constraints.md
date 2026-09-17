# DDL (Data Definition Language) e Constraints

A DDL reúne os comandos responsáveis por criar, modificar e remover a estrutura de objetos no banco de dados (tabelas, esquemas, restrições e colunas).

---

## 1. Comandos Estruturais

### 1.1. CREATE TABLE
Define o nome da tabela, colunas, tipos de dados e restrições de integridade (constraints).

```sql
CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    orcamento NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

### 1.2. Constraints (Restrições de Integridade)

| Constraint | Finalidade | Exemplo de Sintaxe |
| :--- | :--- | :--- |
| **PRIMARY KEY** | Identificador unívoco da tupla (combina NOT NULL e UNIQUE). | `id INT PRIMARY KEY` |
| **FOREIGN KEY** | Garante integridade referencial com a tabela mãe. | `departamento_id INT REFERENCES departamentos(id)` |
| **NOT NULL** | Impede valores nulos/ausentes na coluna. | `nome VARCHAR(100) NOT NULL` |
| **UNIQUE** | Impede duplicidade de valores na coluna (permite NULL). | `email VARCHAR(150) UNIQUE` |
| **CHECK** | Valida regras e condições lógicas booleanas customizadas. | `CHECK (salario > 0 AND idade >= 18)` |
| **DEFAULT** | Define valor padrão automático quando a inserção omitir o campo. | `status VARCHAR(20) DEFAULT 'ativo'` |

#### Exemplo Completo com Constraints Nomeadas:
```sql
CREATE TABLE funcionarios (
    id SERIAL,
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    salario NUMERIC(10, 2) NOT NULL,
    status VARCHAR(15) DEFAULT 'ativo',
    departamento_id INT NOT NULL,
    admitido_em DATE DEFAULT CURRENT_DATE,
    
    CONSTRAINT pk_funcionarios PRIMARY KEY (id),
    CONSTRAINT uq_funcionarios_cpf UNIQUE (cpf),
    CONSTRAINT uq_funcionarios_email UNIQUE (email),
    CONSTRAINT chk_funcionarios_salario CHECK (salario >= 1412.00),
    CONSTRAINT chk_funcionarios_status CHECK (status IN ('ativo', 'afastado', 'desligado')),
    CONSTRAINT fk_funcionarios_departamento 
        FOREIGN KEY (departamento_id) 
        REFERENCES departamentos(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
```

---

### 1.3. Ações Referenciais em Chaves Estrangeiras (ON DELETE / ON UPDATE)

Quando o registro pai é alterado ou excluído:
- **ON DELETE RESTRICT (Padrão):** Bloqueia a exclusão do pai se houver filhos amarrados a ele.
- **ON DELETE CASCADE:** Exclui automaticamente todos os filhos associados ao pai deletado.
- **ON DELETE SET NULL:** Altera a FK dos filhos para `NULL` (exige que a coluna permita nulos).
- **ON UPDATE CASCADE:** Se o valor da PK pai mudar, atualiza automaticamente as FKs filhas.

---

### 1.4. ALTER TABLE
Modifica a estrutura de tabelas já existentes sem perder os dados existentes:

```sql
-- Adicionar coluna
ALTER TABLE funcionarios ADD COLUMN telefone VARCHAR(20);

-- Modificar tipo de dado da coluna
ALTER TABLE funcionarios ALTER COLUMN telefone TYPE VARCHAR(25);

-- Adicionar constraint NOT NULL
ALTER TABLE funcionarios ALTER COLUMN telefone SET NOT NULL;

-- Adicionar restrição CHECK nomeada
ALTER TABLE funcionarios ADD CONSTRAINT chk_telefone_valido CHECK (LENGTH(telefone) >= 10);

-- Renomear coluna
ALTER TABLE funcionarios RENAME COLUMN telefone TO celular;

-- Remover coluna
ALTER TABLE funcionarios DROP COLUMN celular;
```

---

### 1.5. Diferença entre DROP TABLE, TRUNCATE TABLE e DELETE

| Operação | Categoria | Mecanismo | Rollback em Transação | Reseta Sequences / Auto-Increment |
| :--- | :---: | :--- | :---: | :---: |
| **DROP TABLE** | DDL | Destrói a estrutura e os dados do banco definitivamente. | Depende do SGBD | Sim (tabela deixa de existir) |
| **TRUNCATE TABLE** | DDL | Esvazia a tabela rapidamente desvinculando páginas de disco. Muito mais veloz que DELETE. | Sim (no PostgreSQL) | Sim (`RESTART IDENTITY`) |
| **DELETE FROM** | DML | Remove linha a linha, disparando triggers e gravando log individual. | Sim | Não |

```sql
-- Esvaziar tabela rapidamente reiniciando IDs
TRUNCATE TABLE logs_acesso RESTART IDENTITY;

-- Deletar tabela com verificação de existência
DROP TABLE IF EXISTS relatorios_antigos CASCADE;
```
