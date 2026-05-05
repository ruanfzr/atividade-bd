# Sistema de Gestão de Projetos e Equipes

Atividade de Banco de Dados — implementação em PostgreSQL utilizando os conceitos de:

- Entidade Fraca  
- Autorelacionamento  
- Agregação  

---

## Diagrama

```mermaid
erDiagram
    FUNCIONARIO ||--o{ FUNCIONARIO : "gerencia"
    FUNCIONARIO ||--o{ DEPENDENTE : "possui (entidade fraca)"
    FUNCIONARIO }|--|{ ALOCACAO : "participa"
    PROJETO     }|--|{ ALOCACAO : "recebe"
    ALOCACAO    }|--|{ ALOCACAO_EQUIPAMENTO : "agrega (AGREGAÇÃO)"
    EQUIPAMENTO }|--|{ ALOCACAO_EQUIPAMENTO : "usado em"

    FUNCIONARIO {
        int    id_funcionario PK
        string nome
        string cpf
        int    id_gerente     FK
    }

    DEPENDENTE {
        int    id_dependente  PK
        int    id_funcionario FK
        string nome_dependente
        string parentesco
        date   data_nascimento
    }

    PROJETO {
        int    id_projeto   PK
        string nome_projeto
        text   descricao
    }

    ALOCACAO {
        int  id_alocacao    PK
        int  id_funcionario FK
        int  id_projeto     FK
        date data_inicio
    }

    EQUIPAMENTO {
        int    id_equipamento PK
        string descricao
        string tipo
    }

    ALOCACAO_EQUIPAMENTO {
        int id_alocacao    FK
        int id_equipamento FK
        int quantidade
    }
````

O diagrama representa:

* O **autorelacionamento** em FUNCIONARIO (hierarquia de gerência)
* A **entidade fraca DEPENDENTE**
* A **agregação** entre FUNCIONARIO e PROJETO através de ALOCACAO

---

## 📌 Autorelacionamento em FUNCIONARIO

A tabela `FUNCIONARIO` possui a coluna `id_gerente`, que é uma chave estrangeira que referencia a própria tabela. Isso permite modelar hierarquias organizacionais.

* Funcionários no topo possuem `id_gerente = NULL`
* Os demais apontam para seu supervisor direto

### 🔍 Consulta demonstrativa

```sql
SELECT
    f.nome AS funcionario,
    g.nome AS supervisor
FROM funcionario f
LEFT JOIN funcionario g 
    ON f.id_gerente = g.id_funcionario;
```

✔ O `LEFT JOIN` garante que funcionários sem supervisor também apareçam.

---

## 📌 Agregação: Uso de Equipamentos

Problema:

> Um equipamento não pertence apenas a um funcionário ou a um projeto, mas sim ao contexto de um funcionário em um projeto.

### 💡 Solução

O relacionamento entre `FUNCIONARIO` e `PROJETO` foi transformado na entidade `ALOCACAO`.

A tabela `ALOCACAO_EQUIPAMENTO` referencia essa relação, ligando o equipamento ao par:

 **(Funcionário + Projeto)**

## Estrutura

```
FUNCIONARIO ──┐
              ├──> ALOCACAO ──> ALOCACAO_EQUIPAMENTO <── EQUIPAMENTO
PROJETO    ──┘
```

✔ Isso garante que o equipamento esteja associado corretamente ao contexto de uso.

---

## Entidade Fraca — DEPENDENTE

A entidade `DEPENDENTE` não possui identidade própria e depende diretamente de `FUNCIONARIO`.

* Chave primária composta: `(id_dependente, id_funcionario)`
* Sua existência depende do funcionário

---

## Uso de ON DELETE CASCADE

O `ON DELETE CASCADE` foi utilizado na relação entre `FUNCIONARIO` e `DEPENDENTE`.

### 💡 Justificativa

Quando um funcionário é removido, seus dependentes também devem ser removidos automaticamente.

```sql
FOREIGN KEY (id_funcionario)
REFERENCES funcionario(id_funcionario)
ON DELETE CASCADE
```

 Garante:

* Integridade referencial
* Evita registros órfãos
* Automatiza manutenção do banco

---

## Demonstração de Execução SQL

### Inserção de dados

```sql
INSERT INTO funcionario (id_funcionario, nome) VALUES (1, 'Carlos');

INSERT INTO dependente (id_dependente, id_funcionario, nome_dependente)
VALUES (1, 1, 'Ana');
```

### Consulta

```sql
SELECT * FROM dependente;
```

### Resultado esperado

```
id_dependente | id_funcionario | nome_dependente
--------------|----------------|----------------
1             | 1              | Ana
```

---

### Teste do CASCADE

```sql
DELETE FROM funcionario WHERE id_funcionario = 1;
```

Após isso:

```sql
SELECT * FROM dependente;
```

Resultado:

```
(0 registros)
```
