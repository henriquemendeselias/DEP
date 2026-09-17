-- ============================================================================
-- SCRIPT PRÁTICO 01: DDL (Data Definition Language) & Constraints
-- Autor: Henrique Mendes Elias
-- Objetivo: Demonstrar criação de tabelas, tipos de dados, chaves e restrições
-- ============================================================================

-- 1. Limpeza prévia para garantir idempotência do script
DROP TABLE IF EXISTS alocacoes_projeto CASCADE;
DROP TABLE IF EXISTS projetos CASCADE;
DROP TABLE IF EXISTS funcionarios CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;

-- 2. Tabela com PK simples, UNIQUE e DEFAULT
CREATE TABLE departamentos (
    id SERIAL,
    sigla VARCHAR(10) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    orcamento NUMERIC(14, 2) NOT NULL DEFAULT 50000.00,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_departamentos PRIMARY KEY (id),
    CONSTRAINT uq_departamentos_sigla UNIQUE (sigla),
    CONSTRAINT chk_departamentos_orcamento CHECK (orcamento >= 0)
);

-- 3. Tabela com FK, restrições CHECK múltiplas e valores DEFAULT
CREATE TABLE funcionarios (
    id SERIAL,
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    salario NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'ativo',
    gestor_id INT,
    departamento_id INT NOT NULL,
    admitido_em DATE DEFAULT CURRENT_DATE,

    CONSTRAINT pk_funcionarios PRIMARY KEY (id),
    CONSTRAINT uq_funcionarios_cpf UNIQUE (cpf),
    CONSTRAINT uq_funcionarios_email UNIQUE (email),
    CONSTRAINT chk_funcionarios_salario CHECK (salario >= 1412.00),
    CONSTRAINT chk_funcionarios_status CHECK (status IN ('ativo', 'afastado', 'desligado', 'ferias')),
    
    -- Auto-relacionamento (Self Join): gestor também é funcionário
    CONSTRAINT fk_funcionarios_gestor 
        FOREIGN KEY (gestor_id) 
        REFERENCES funcionarios(id) 
        ON DELETE SET NULL,

    -- Relacionamento 1:N com Departamentos
    CONSTRAINT fk_funcionarios_departamento 
        FOREIGN KEY (departamento_id) 
        REFERENCES departamentos(id) 
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 4. Tabela de Projetos com validação temporal entre datas
CREATE TABLE projetos (
    id SERIAL,
    codigo VARCHAR(20) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim_prevista DATE,
    status VARCHAR(20) DEFAULT 'planejado',

    CONSTRAINT pk_projetos PRIMARY KEY (id),
    CONSTRAINT uq_projetos_codigo UNIQUE (codigo),
    CONSTRAINT chk_projetos_status CHECK (status IN ('planejado', 'em_andamento', 'concluido', 'cancelado')),
    CONSTRAINT chk_projetos_datas CHECK (data_fim_prevista IS NULL OR data_fim_prevista >= data_inicio)
);

-- 5. Tabela Associativa N:M (Alocações) com PK Composta
CREATE TABLE alocacoes_projeto (
    funcionario_id INT NOT NULL,
    projeto_id INT NOT NULL,
    horas_semanais INT NOT NULL DEFAULT 20,
    papel VARCHAR(50) NOT NULL,
    data_alocacao DATE DEFAULT CURRENT_DATE,

    -- Chave primária composta garantindo que o mesmo funcionário não seja duplicado no mesmo projeto
    CONSTRAINT pk_alocacoes PRIMARY KEY (funcionario_id, projeto_id),
    
    CONSTRAINT fk_alocacoes_funcionario 
        FOREIGN KEY (funcionario_id) 
        REFERENCES funcionarios(id) 
        ON DELETE CASCADE,

    CONSTRAINT fk_alocacoes_projeto 
        FOREIGN KEY (projeto_id) 
        REFERENCES projetos(id) 
        ON DELETE CASCADE,

    CONSTRAINT chk_alocacoes_horas CHECK (horas_semanais > 0 AND horas_semanais <= 44)
);

-- 6. Exemplos de ALTER TABLE (Modificações estruturais)

-- Adicionando nova coluna
ALTER TABLE funcionarios ADD COLUMN telefone VARCHAR(20);

-- Modificando o tipo da coluna
ALTER TABLE funcionarios ALTER COLUMN telefone TYPE VARCHAR(25);

-- Adicionando constraint após a criação da tabela
ALTER TABLE funcionarios ADD CONSTRAINT chk_telefone_formato 
    CHECK (telefone IS NULL OR LENGTH(telefone) >= 10);

-- Renomeando coluna
ALTER TABLE funcionarios RENAME COLUMN telefone TO celular;

-- Removendo coluna
ALTER TABLE funcionarios DROP COLUMN celular;
