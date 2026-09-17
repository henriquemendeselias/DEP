-- ============================================================================
-- SCRIPT PRÁTICO 03: Transações (TCL), Controle (DCL), Views, Triggers e Performance
-- Autor: Henrique Mendes Elias
-- Objetivo: Demonstrar recursos avançados de banco de dados relacional
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TCL: TRANSAÇÕES E PROPRIEDADES ACID (BEGIN, COMMIT, ROLLBACK, SAVEPOINT)
-- ----------------------------------------------------------------------------

-- Simulação de transação atômica: remanejamento de orçamento entre departamentos
BEGIN TRANSACTION;

-- Deduz R$ 20.000 da Diretoria
UPDATE departamentos 
SET orcamento = orcamento - 20000.00 
WHERE sigla = 'DIR';

-- Cria ponto de restauração intermediário
SAVEPOINT orcamento_reduzido;

-- Adiciona R$ 20.000 para Engenharia de Dados
UPDATE departamentos 
SET orcamento = orcamento + 20000.00 
WHERE sigla = 'ENG';

-- Caso alguma validação falhasse:
-- ROLLBACK TO SAVEPOINT orcamento_reduzido;
-- ROLLBACK;

-- Confirmando a transação definitiva no disco
COMMIT;

-- ----------------------------------------------------------------------------
-- 2. DCL: CONTROLE DE ACESSO E SEGURANÇA (GRANT e REVOKE)
-- ----------------------------------------------------------------------------

-- Criação de perfis de acesso
CREATE ROLE analista_bi;
CREATE ROLE engenheiro_dados;

-- Analista de BI só pode ler tabelas e visões analíticas
GRANT SELECT ON departamentos, funcionarios, projetos, alocacoes_projeto TO analista_bi;

-- Engenheiro de Dados tem permissão de leitura, escrita e atualização
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO engenheiro_dados;

-- Conceder o perfil ao usuário Henrique
-- GRANT engenheiro_dados TO henrique;

-- Revogando privilégios em caso de necessidade
REVOKE DELETE ON funcionarios FROM analista_bi;

-- ----------------------------------------------------------------------------
-- 3. VIEWS (TABELAS VIRTUAIS ANALÍTICAS)
-- ----------------------------------------------------------------------------

-- Visão consolidada para consumo em ferramentas de BI (Power BI, Metabase)
CREATE VIEW vw_dashboard_projetos AS
SELECT 
    p.id AS projeto_id,
    p.codigo AS projeto_codigo,
    p.nome AS projeto_nome,
    p.status AS projeto_status,
    COUNT(DISTINCT a.funcionario_id) AS total_profissionais_alocados,
    COALESCE(SUM(a.horas_semanais), 0) AS total_horas_semanais,
    ROUND(COALESCE(AVG(f.salario), 0), 2) AS custo_medio_salario_equipe
FROM projetos p
LEFT JOIN alocacoes_projeto a ON p.id = a.projeto_id
LEFT JOIN funcionarios f ON a.funcionario_id = f.id
GROUP BY p.id, p.codigo, p.nome, p.status;

-- Consultando a View como se fosse uma tabela física:
SELECT * FROM vw_dashboard_projetos WHERE total_profissionais_alocados > 0;

-- ----------------------------------------------------------------------------
-- 4. TRIGGERS E FUNÇÃO DE AUDITORIA (POSTGRESQL)
-- ----------------------------------------------------------------------------

-- Tabela para armazenar o histórico de alterações salariais
CREATE TABLE IF NOT EXISTS auditoria_salarios (
    id SERIAL PRIMARY KEY,
    funcionario_id INT NOT NULL,
    salario_anterior NUMERIC(10, 2) NOT NULL,
    salario_novo NUMERIC(10, 2) NOT NULL,
    motivo VARCHAR(100) DEFAULT 'Reajuste/Promoção',
    alterado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    alterado_por VARCHAR(50) DEFAULT CURRENT_USER
);

-- Função executada pelo Trigger
CREATE OR REPLACE FUNCTION fn_auditar_reajuste_salario()
RETURNS TRIGGER AS $$
BEGIN
    -- Só grava na auditoria se o salário realmente tiver mudado de valor
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO auditoria_salarios (funcionario_id, salario_anterior, salario_novo)
        VALUES (OLD.id, OLD.salario, NEW.salario);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do Trigger associado à tabela funcionarios
DROP TRIGGER IF EXISTS trg_audita_salario ON funcionarios;

CREATE TRIGGER trg_audita_salario
AFTER UPDATE OF salario ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_reajuste_salario();

-- ----------------------------------------------------------------------------
-- 5. ÍNDICES E OTIMIZAÇÃO DE CONSULTAS
-- ----------------------------------------------------------------------------

-- 5.1. Criação de Índices B-Tree
-- Índice em coluna com busca frequente por igualdade exata
CREATE INDEX idx_funcionarios_email ON funcionarios(email);

-- Índice Composto: ideal para consultas que filtram departamento E status juntos
CREATE INDEX idx_funcionarios_dept_status ON funcionarios(departamento_id, status);

-- Índice na FK de alocações para otimizar os JOINs
CREATE INDEX idx_alocacoes_projeto ON alocacoes_projeto(projeto_id);

-- 5.2. Análise de Plano de Execução (EXPLAIN / EXPLAIN ANALYZE)
-- Permite verificar se o banco fez Seq Scan (varredura completa) ou Index Scan

-- Consulta Sargable (aproveita índice)
EXPLAIN ANALYZE
SELECT id, nome, salario 
FROM funcionarios 
WHERE departamento_id = 1 AND status = 'ativo';

-- Exemplo Não-Sargable (ruim: aplicação de função impede uso direto de índice comum)
-- EXPLAIN ANALYZE SELECT * FROM funcionarios WHERE LOWER(nome) = 'alice santos';

-- Correção: criar Índice Baseado em Expressão se a busca case-insensitive for regra de negócio:
CREATE INDEX idx_funcionarios_nome_lower ON funcionarios(LOWER(nome));
