-- ============================================================
--  Sistema de Gestão de Projetos e Equipes
--  Conceitos: Entidade Fraca, Autorelacionamento, Agregação
-- ============================================================

-- ---------------------------------------------------------------
-- 1. FUNCIONARIO — com Autorelacionamento (id_gerente -> própria tabela)
-- ---------------------------------------------------------------
CREATE TABLE funcionario (
    id_funcionario SERIAL PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    cpf            VARCHAR(11)  UNIQUE NOT NULL,
    id_gerente     INTEGER REFERENCES funcionario(id_funcionario)
    -- id_gerente NULL = funcionário sem supervisor (topo da hierarquia)
);

-- ---------------------------------------------------------------
-- 2. DEPENDENTE — Entidade Fraca (depende de FUNCIONARIO para existir)
-- ---------------------------------------------------------------
CREATE TABLE dependente (
    id_dependente  INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    nome_dependente VARCHAR(100) NOT NULL,
    parentesco      VARCHAR(50),
    data_nascimento DATE,
    -- Chave primária COMPOSTA: dependente só existe dentro do contexto do funcionário
    PRIMARY KEY (id_dependente, id_funcionario),
    CONSTRAINT fk_dependente_funcionario
        FOREIGN KEY (id_funcionario)
        REFERENCES funcionario(id_funcionario)
        ON DELETE CASCADE  -- Se o funcionário for deletado, dependentes somem junto
);

-- ---------------------------------------------------------------
-- 3. PROJETO
-- ---------------------------------------------------------------
CREATE TABLE projeto (
    id_projeto   SERIAL PRIMARY KEY,
    nome_projeto VARCHAR(100) NOT NULL,
    descricao    TEXT
);

-- ---------------------------------------------------------------
-- 4. ALOCACAO — representa o relacionamento Funcionario <-> Projeto
--    Esta tabela será usada como base da AGREGAÇÃO
-- ---------------------------------------------------------------
CREATE TABLE alocacao (
    id_alocacao    SERIAL PRIMARY KEY,
    id_funcionario INTEGER NOT NULL REFERENCES funcionario(id_funcionario),
    id_projeto     INTEGER NOT NULL REFERENCES projeto(id_projeto),
    data_inicio    DATE NOT NULL
);

-- ---------------------------------------------------------------
-- 5. EQUIPAMENTO
-- ---------------------------------------------------------------
CREATE TABLE equipamento (
    id_equipamento SERIAL PRIMARY KEY,
    descricao      VARCHAR(100) NOT NULL,
    tipo           VARCHAR(50)
);

-- ---------------------------------------------------------------
-- 6. ALOCACAO_EQUIPAMENTO — AGREGAÇÃO
--    Equipamento se liga à ALOCACAO (par funcionário+projeto), não a um deles isoladamente
-- ---------------------------------------------------------------
CREATE TABLE alocacao_equipamento (
    id_alocacao    INTEGER NOT NULL REFERENCES alocacao(id_alocacao),
    id_equipamento INTEGER NOT NULL REFERENCES equipamento(id_equipamento),
    quantidade     INTEGER DEFAULT 1,
    PRIMARY KEY (id_alocacao, id_equipamento)
);


-- ============================================================
--  DADOS DE EXEMPLO
-- ============================================================

-- Funcionários (Carlos = gerente geral, sem supervisor)
INSERT INTO funcionario (nome, cpf, id_gerente) VALUES
    ('Carlos Silva',  '11111111111', NULL),   -- id 1, sem gerente
    ('Ana Souza',     '22222222222', 1),       -- id 2, gerenciada por Carlos
    ('Bruno Lima',    '33333333333', 1),       -- id 3, gerenciado por Carlos
    ('Diana Rocha',   '44444444444', 2);       -- id 4, gerenciada por Ana

-- Dependentes de Ana (entidade fraca)
INSERT INTO dependente (id_dependente, id_funcionario, nome_dependente, parentesco, data_nascimento) VALUES
    (1, 2, 'Pedro Souza',  'Filho',    '2015-03-10'),
    (2, 2, 'Lucia Souza',  'Cônjuge',  '1990-07-22');

-- Dependente de Bruno
INSERT INTO dependente (id_dependente, id_funcionario, nome_dependente, parentesco, data_nascimento) VALUES
    (1, 3, 'Carla Lima', 'Filha', '2018-11-05');

-- Projetos
INSERT INTO projeto (nome_projeto, descricao) VALUES
    ('Sistema ERP',      'Implementação de sistema integrado de gestão'),
    ('App Mobile',       'Desenvolvimento de aplicativo para clientes'),
    ('Migração Cloud',   'Migração da infraestrutura para nuvem');

-- Alocações (quem trabalha em qual projeto)
INSERT INTO alocacao (id_funcionario, id_projeto, data_inicio) VALUES
    (2, 1, '2024-01-10'),  -- Ana no ERP       -> id_alocacao = 1
    (3, 1, '2024-01-10'),  -- Bruno no ERP      -> id_alocacao = 2
    (4, 2, '2024-03-01'),  -- Diana no App      -> id_alocacao = 3
    (2, 3, '2024-06-01');  -- Ana na Cloud      -> id_alocacao = 4

-- Equipamentos
INSERT INTO equipamento (descricao, tipo) VALUES
    ('Notebook Dell XPS',   'Computador'),
    ('Monitor LG 27"',      'Periférico'),
    ('Headset Sony',        'Periférico'),
    ('iPad Pro',            'Tablet');

-- Agregação: equipamentos por alocação (funcionário+projeto)
INSERT INTO alocacao_equipamento (id_alocacao, id_equipamento, quantidade) VALUES
    (1, 1, 1),  -- Ana no ERP usa Notebook
    (1, 2, 2),  -- Ana no ERP usa 2 Monitores
    (2, 1, 1),  -- Bruno no ERP usa Notebook
    (3, 4, 1),  -- Diana no App usa iPad
    (4, 3, 1);  -- Ana na Cloud usa Headset


-- ============================================================
--  CONSULTAS PARA A APRESENTAÇÃO
-- ============================================================

-- 1. Autorelacionamento: funcionário ao lado do seu supervisor (dica do professor)
SELECT
    f.nome        AS funcionario,
    g.nome        AS supervisor
FROM funcionario f
LEFT JOIN funcionario g ON f.id_gerente = g.id_funcionario;

-- 2. Entidade fraca: deletar funcionário e ver CASCADE nos dependentes
-- DELETE FROM funcionario WHERE id_funcionario = 2;
-- SELECT * FROM dependente; -- dependentes de Ana somem automaticamente

-- 3. Agregação: quem usa qual equipamento em qual projeto
SELECT
    f.nome           AS funcionario,
    p.nome_projeto   AS projeto,
    e.descricao      AS equipamento,
    ae.quantidade
FROM alocacao_equipamento ae
JOIN alocacao    a  ON ae.id_alocacao    = a.id_alocacao
JOIN funcionario f  ON a.id_funcionario  = f.id_funcionario
JOIN projeto     p  ON a.id_projeto      = p.id_projeto
JOIN equipamento e  ON ae.id_equipamento = e.id_equipamento
ORDER BY f.nome, p.nome_projeto;
