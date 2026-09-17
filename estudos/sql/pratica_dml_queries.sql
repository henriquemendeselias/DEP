-- ============================================================================
-- SCRIPT PRÁTICO 02: DML & Consultas Analíticas (DQL)
-- Autor: Henrique Mendes Elias
-- Objetivo: Demonstrar manipulação de dados e consultas de ponta a ponta
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. DML: INSERÇÃO DE DADOS DE TESTE (INSERT INTO)
-- ----------------------------------------------------------------------------

-- Inserindo departamentos
INSERT INTO departamentos (sigla, nome, orcamento) VALUES 
('ENG', 'Engenharia de Dados', 180000.00),
('DEV', 'Desenvolvimento de Software', 220000.00),
('RH', 'Recursos Humanos', 75000.00),
('MKT', 'Marketing e Vendas', 90000.00),
('DIR', 'Diretoria Executiva', 300000.00);

-- Inserindo funcionários (incluindo hierarquia com gestores e alguns com status variados)
INSERT INTO funcionarios (cpf, nome, email, salario, status, gestor_id, departamento_id, admitido_em) VALUES 
('11122233301', 'Alice Santos', 'alice@empresa.com', 18500.00, 'ativo', NULL, 5, '2022-01-10'),
('11122233302', 'Bruno Carvalho', 'bruno@empresa.com', 12000.00, 'ativo', 1, 1, '2022-03-15'),
('11122233303', 'Carla Dias', 'carla@empresa.com', 9500.00, 'ativo', 2, 1, '2023-05-01'),
('11122233304', 'Daniel Souza', 'daniel@empresa.com', 8200.00, 'ativo', 2, 1, '2023-08-20'),
('11122233305', 'Eduardo Lima', 'eduardo@empresa.com', 11000.00, 'ativo', 1, 2, '2022-06-01'),
('11122233306', 'Fernanda Rocha', 'fernanda@empresa.com', 7500.00, 'ativo', 5, 2, '2024-01-15'),
('11122233307', 'Gustavo Nogueira', 'gustavo@empresa.com', 5200.00, 'afastado', 1, 3, '2023-11-10'),
('11122233308', 'Helena Ramos', 'helena@empresa.com', 6400.00, 'ativo', 1, 4, '2024-02-01'),
('11122233309', 'Igor Martins', 'igor@empresa.com', 4800.00, 'desligado', 2, 1, '2022-10-01');

-- Inserindo projetos
INSERT INTO projetos (codigo, nome, data_inicio, data_fim_prevista, status) VALUES 
('PRJ-001', 'Data Lakehouse AWS', '2024-01-01', '2024-12-31', 'em_andamento'),
('PRJ-002', 'Novo Portal do Cliente', '2024-02-01', '2024-08-30', 'em_andamento'),
('PRJ-003', 'Automação Onboarding RH', '2024-03-01', '2024-06-30', 'concluido'),
('PRJ-004', 'Migração ERP Legado', '2024-07-01', NULL, 'planejado');

-- Inserindo alocações (N:M)
INSERT INTO alocacoes_projeto (funcionario_id, projeto_id, horas_semanais, papel) VALUES 
(2, 1, 25, 'Tech Lead de Dados'),
(3, 1, 30, 'Engenheira de Dados Pleno'),
(4, 1, 20, 'Engenheiro de Analytics'),
(5, 2, 20, 'Tech Lead Frontend'),
(6, 2, 35, 'Desenvolvedora Full Stack'),
(7, 3, 15, 'Analista de RH');

-- ----------------------------------------------------------------------------
-- 2. DML: ATUALIZAÇÕES E EXCLUSÕES (UPDATE e DELETE)
-- ----------------------------------------------------------------------------

-- UPDATE com condição específica e cálculo
UPDATE funcionarios
SET salario = ROUND(salario * 1.08, 2)
WHERE departamento_id = 1 AND status = 'ativo';

-- DELETE com filtro
DELETE FROM funcionarios
WHERE status = 'desligado' AND admitido_em < '2023-01-01';

-- ----------------------------------------------------------------------------
-- 3. DQL: FILTROS E OPERADORES CONDICIONAIS
-- ----------------------------------------------------------------------------

-- SELECT com WHERE, AND, OR, BETWEEN, IN, LIKE/ILIKE e IS NOT NULL
SELECT 
    nome,
    email,
    salario,
    status
FROM funcionarios
WHERE (salario BETWEEN 6000 AND 13000)
  AND status IN ('ativo', 'afastado')
  AND email LIKE '%@empresa.com'
  AND gestor_id IS NOT NULL;

-- ----------------------------------------------------------------------------
-- 4. DQL: DISTINCT, COUNT DISTINCT, ORDENAÇÃO E PAGINAÇÃO
-- ----------------------------------------------------------------------------

-- Obter cargos/status distintos e contagem única de departamentos ocupados
SELECT DISTINCT status FROM funcionarios;

SELECT COUNT(DISTINCT departamento_id) AS total_departamentos_com_funcionarios
FROM funcionarios;

-- ORDER BY múltiplo (salário desc, nome asc) com LIMIT e OFFSET para paginação
SELECT id, nome, salario, admitido_em
FROM funcionarios
WHERE status = 'ativo'
ORDER BY salario DESC, nome ASC
LIMIT 3 OFFSET 0; -- Primeira página com 3 registros mais bem pagos

-- ----------------------------------------------------------------------------
-- 5. DQL: FUNÇÕES DE AGREGAÇÃO, GROUP BY E HAVING
-- ----------------------------------------------------------------------------

-- Relatório analítico por departamento usando SUM, AVG, MAX, MIN e COUNT
SELECT 
    departamento_id,
    COUNT(*) AS total_colaboradores,
    SUM(salario) AS folha_salarial_total,
    ROUND(AVG(salario), 2) AS salario_medio,
    MIN(salario) AS menor_salario,
    MAX(salario) AS maior_salario
FROM funcionarios
WHERE status = 'ativo'
GROUP BY departamento_id
HAVING COUNT(*) >= 2 AND AVG(salario) > 7000.00
ORDER BY folha_salarial_total DESC;

-- ----------------------------------------------------------------------------
-- 6. DQL: TIPOS DE JOINS (CRUZAMENTO DE TABELAS)
-- ----------------------------------------------------------------------------

-- 6.1. INNER JOIN: apenas funcionários com departamento cadastrado e vice-versa
SELECT 
    f.nome AS funcionario,
    f.salario,
    d.nome AS departamento,
    d.sigla
FROM funcionarios f
INNER JOIN departamentos d ON f.departamento_id = d.id;

-- 6.2. LEFT JOIN: todos os departamentos, mesmo os que ainda NÃO possuem funcionários
SELECT 
    d.nome AS departamento,
    COUNT(f.id) AS qtd_funcionarios,
    COALESCE(SUM(f.salario), 0.00) AS folha_salarial
FROM departamentos d
LEFT JOIN funcionarios f ON d.id = f.departamento_id
GROUP BY d.nome
ORDER BY qtd_funcionarios DESC;

-- 6.3. RIGHT JOIN: exemplo didático (equivalente ao inverso do left)
SELECT 
    f.nome AS funcionario,
    d.nome AS departamento
FROM departamentos d
RIGHT JOIN funcionarios f ON d.id = f.departamento_id;

-- 6.4. FULL OUTER JOIN: lista tudo de ambos os lados, mostrando onde há dados faltantes
SELECT 
    p.codigo AS codigo_projeto,
    p.nome AS projeto,
    f.nome AS funcionario_alocado,
    a.papel
FROM projetos p
FULL OUTER JOIN alocacoes_projeto a ON p.id = a.projeto_id
FULL OUTER JOIN funcionarios f ON a.funcionario_id = f.id;

-- 6.5. SELF JOIN: relacionando uma tabela consigo mesma (Funcionário e seu Gestor)
SELECT 
    colab.nome AS funcionario,
    COALESCE(gestor.nome, 'Sem Gestor Direto (Alta Liderança)') AS gestor_direto
FROM funcionarios colab
LEFT JOIN funcionarios gestor ON colab.gestor_id = gestor.id;

-- 6.6. CROSS JOIN: matriz de combinações possíveis (ex: cada departamento x status de projeto)
SELECT 
    d.sigla AS dept,
    p.status AS status_possivel
FROM departamentos d
CROSS JOIN (SELECT DISTINCT status FROM projetos) p;

-- ----------------------------------------------------------------------------
-- 7. DQL: CTE (COMMON TABLE EXPRESSION) E SUBCONSULTAS
-- ----------------------------------------------------------------------------

-- Descobrir quem ganha acima da média do seu próprio departamento
WITH media_por_departamento AS (
    SELECT 
        departamento_id,
        AVG(salario) AS media_salario_dept
    FROM funcionarios
    WHERE status = 'ativo'
    GROUP BY departamento_id
)
SELECT 
    f.nome,
    f.salario,
    ROUND(m.media_salario_dept, 2) AS media_do_departamento,
    ROUND(f.salario - m.media_salario_dept, 2) AS diferenca
FROM funcionarios f
INNER JOIN media_por_departamento m ON f.departamento_id = m.departamento_id
WHERE f.salario > m.media_salario_dept;
