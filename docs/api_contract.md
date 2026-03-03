# BolsaBBB - Contrato de API

**Base URL:** `http://localhost:5000`  
**Content-Type:** `application/json`

---

## GET /portfolio

Retorna o resumo da carteira do usuário.

**Response 200:**

```json
{
  "total": 12480,
  "rentabilidade": 12.4
}
```

| Campo           | Tipo   | Descrição                        |
|-----------------|--------|----------------------------------|
| total           | number | Valor total da carteira (R$)     |
| rentabilidade   | number | Rentabilidade acumulada (%)      |

---

## GET /allocation

Retorna a alocação percentual dos ativos por tipo.

**Response 200:**

```json
{
  "Acoes": 65,
  "FIIs": 35
}
```

| Campo  | Tipo   | Descrição                          |
|--------|--------|------------------------------------|
| Acoes  | number | Percentual alocado em ações (%)    |
| FIIs   | number | Percentual alocado em FIIs (%)     |

---

## Endpoints Futuros

### GET /assets

Lista todos os ativos monitorados.

**Response 200:**

```json
[
  {
    "ticker": "WEGE3",
    "tipo": "acao",
    "preco": 35.50,
    "roe": 0.25,
    "pl": 8.5,
    "div_ebitda": 1.2,
    "liquidez": 5000000,
    "valor_intrinseco": 42.00,
    "setor": "Industria",
    "score": 80
  }
]
```

| Campo            | Tipo   | Descrição                          |
|------------------|--------|------------------------------------|
| ticker           | string | Código do ativo na B3              |
| tipo             | string | `acao` ou `fii`                    |
| preco            | number | Preço atual (R$)                   |
| roe              | number | Return on Equity (decimal)         |
| pl               | number | Preço/Lucro                        |
| div_ebitda       | number | Dívida Líquida/EBITDA              |
| liquidez         | number | Volume médio diário                |
| valor_intrinseco | number | Valuation calculado (R$)           |
| setor            | string | Setor de atuação                   |
| score            | number | Score de 0 a 100                   |

---

### GET /signals

Lista os sinais de compra/venda gerados.

**Response 200:**

```json
[
  {
    "ticker": "WEGE3",
    "tipo": "compra",
    "mensagem": "Score 80 - Ativo subvalorizado"
  }
]
```

| Campo    | Tipo   | Descrição                            |
|----------|--------|--------------------------------------|
| ticker   | string | Código do ativo                      |
| tipo     | string | `compra` ou `venda`                  |
| mensagem | string | Justificativa do sinal               |

---

## Códigos de Erro

| Código | Descrição             |
|--------|-----------------------|
| 200    | Sucesso               |
| 404    | Recurso não encontrado|
| 500    | Erro interno          |
