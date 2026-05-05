CREATE TABLE funcionario (
    id_funcionario SERIAL PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    cpf            VARCHAR(11)  UNIQUE NOT NULL,
    id_gerente     INTEGER REFERENCES funcionario(id_funcionario)
);

CREATE TABLE dependente (
    id_dependente  INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    nome_dependente VARCHAR(100) NOT NULL,
    parentesco      VARCHAR(50),
    data_nascimento DATE,
    PRIMARY KEY (id_dependente, id_funcionario),
    CONSTRAINT fk_dependente_funcionario
        FOREIGN KEY (id_funcionario)
        REFERENCES funcionario(id_funcionario)
        ON DELETE CASCADE 
);

CREATE TABLE projeto (
    id_projeto   SERIAL PRIMARY KEY,
    nome_projeto VARCHAR(100) NOT NULL,
    descricao    TEXT
);

CREATE TABLE alocacao (
    id_alocacao    SERIAL PRIMARY KEY,
    id_funcionario INTEGER NOT NULL REFERENCES funcionario(id_funcionario),
    id_projeto     INTEGER NOT NULL REFERENCES projeto(id_projeto),
    data_inicio    DATE NOT NULL
);

CREATE TABLE equipamento (
    id_equipamento SERIAL PRIMARY KEY,
    descricao      VARCHAR(100) NOT NULL,
    tipo           VARCHAR(50)
);

CREATE TABLE alocacao_equipamento (
    id_alocacao    INTEGER NOT NULL REFERENCES alocacao(id_alocacao),
    id_equipamento INTEGER NOT NULL REFERENCES equipamento(id_equipamento),
    quantidade     INTEGER DEFAULT 1,
    PRIMARY KEY (id_alocacao, id_equipamento)
);


INSERT INTO funcionario (nome, cpf, id_gerente) VALUES
    ('Carlos Silva',  '11111111111', NULL),
    ('Ana Souza',     '22222222222', 1),
    ('Bruno Lima',    '33333333333', 1),
    ('Diana Rocha',   '44444444444', 2);

INSERT INTO dependente (id_dependente, id_funcionario, nome_dependente, parentesco, data_nascimento) VALUES
    (1, 2, 'Pedro Souza',  'Filho',    '2015-03-10'),
    (2, 2, 'Lucia Souza',  'Cônjuge',  '1990-07-22');

INSERT INTO dependente (id_dependente, id_funcionario, nome_dependente, parentesco, data_nascimento) VALUES
    (1, 3, 'Carla Lima', 'Filha', '2018-11-05');

INSERT INTO projeto (nome_projeto, descricao) VALUES
    ('Sistema ERP',      'Implementação de sistema integrado de gestão'),
    ('App Mobile',       'Desenvolvimento de aplicativo para clientes'),
    ('Migração Cloud',   'Migração da infraestrutura para nuvem');

INSERT INTO alocacao (id_funcionario, id_projeto, data_inicio) VALUES
    (2, 1, '2024-01-10'), 
    (3, 1, '2024-01-10'), 
    (4, 2, '2024-03-01'), 
    (2, 3, '2024-06-01');  

INSERT INTO equipamento (descricao, tipo) VALUES
    ('Notebook Dell XPS',   'Computador'),
    ('Monitor LG 27"',      'Periférico'),
    ('Headset Sony',        'Periférico'),
    ('iPad Pro',            'Tablet');

INSERT INTO alocacao_equipamento (id_alocacao, id_equipamento, quantidade) VALUES
    (1, 1, 1), 
    (1, 2, 2),  
    (2, 1, 1),  
    (3, 4, 1), 
    (4, 3, 1);  

SELECT
    f.nome        AS funcionario,
    g.nome        AS supervisor
FROM funcionario f
LEFT JOIN funcionario g ON f.id_gerente = g.id_funcionario;

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
