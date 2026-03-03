from firebase_functions import https_fn
from firebase_admin import initialize_app
import requests

initialize_app()

TELEGRAM_TOKEN = "8660578382:AAFWrG8ttPF3xW7rMF0fLoC2C4SV68F_n08"
TELEGRAM_CHAT_ID = "-1003853368032"


class Asset:
    def __init__(self, ticker, tipo, preco, roe, pl,
                 div_ebitda, liquidez, valor_intrinseco, setor):
        self.ticker = ticker
        self.tipo = tipo
        self.preco = preco
        self.roe = roe
        self.pl = pl
        self.div_ebitda = div_ebitda
        self.liquidez = liquidez
        self.valor_intrinseco = valor_intrinseco
        self.setor = setor


ASSETS_DATA = [
    Asset("WEGE3", "acao", 35.50, 0.25, 8.5, 1.2, 5000000, 42.00, "Industria"),
    Asset("ITUB4", "acao", 28.30, 0.18, 7.2, 2.5, 8000000, 33.00, "Financeiro"),
    Asset("VALE3", "acao", 68.90, 0.22, 5.1, 1.8, 12000000, 75.00, "Mineracao"),
    Asset("HGLG11", "fii", 162.00, 0.10, 15.0, 0.5, 3000000, 170.00, "Logistica"),
    Asset("XPML11", "fii", 98.50, 0.08, 12.0, 1.0, 2000000, 105.00, "Shopping"),
]


def score_acao(asset):
    score = 0
    if asset.roe > 0.15:
        score += 30
    if asset.div_ebitda < 3:
        score += 20
    if asset.pl < 10:
        score += 20
    if asset.valor_intrinseco > asset.preco:
        score += 30
    return score


def sinal_compra(asset, score):
    return score >= 70


def sinal_venda(asset):
    return asset.preco >= asset.valor_intrinseco * 1.2


def enviar_alerta(mensagem):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    try:
        resp = requests.post(url, json={
            "chat_id": TELEGRAM_CHAT_ID,
            "text": mensagem
        }, timeout=15)
        return resp.json()
    except Exception as e:
        return {"error": str(e)}


@https_fn.on_request(region="southamerica-east1")
def monitorAtivos(req: https_fn.Request) -> https_fn.Response:
    sinais = []
    for a in ASSETS_DATA:
        s = score_acao(a)
        if sinal_compra(a, s):
            sinais.append(f"COMPRA {a.ticker} - Score {s}")
        elif sinal_venda(a):
            sinais.append(f"VENDA {a.ticker} - Preco acima do intrinseco")

    if sinais:
        msg = "BolsaBBB - Sinais detectados:\n" + "\n".join(sinais)
        enviar_alerta(msg)

    return https_fn.Response(
        response=f'{{"status":"OK","sinais":{len(sinais)}}}',
        content_type="application/json"
    )


@https_fn.on_request(region="southamerica-east1")
def portfolio(req: https_fn.Request) -> https_fn.Response:
    import json
    total = sum(a.preco for a in ASSETS_DATA)
    return https_fn.Response(
        response=json.dumps({"total": total, "rentabilidade": 12.4}),
        content_type="application/json"
    )


@https_fn.on_request(region="southamerica-east1")
def allocation(req: https_fn.Request) -> https_fn.Response:
    import json
    acoes = sum(a.preco for a in ASSETS_DATA if a.tipo == "acao")
    fiis = sum(a.preco for a in ASSETS_DATA if a.tipo == "fii")
    total = acoes + fiis
    return https_fn.Response(
        response=json.dumps({
            "Acoes": round(acoes / total * 100, 1),
            "FIIs": round(fiis / total * 100, 1)
        }),
        content_type="application/json"
    )


@https_fn.on_request(region="southamerica-east1")
def assets(req: https_fn.Request) -> https_fn.Response:
    import json
    result = []
    for a in ASSETS_DATA:
        s = score_acao(a)
        result.append({
            "ticker": a.ticker,
            "tipo": a.tipo,
            "preco": a.preco,
            "roe": a.roe,
            "pl": a.pl,
            "div_ebitda": a.div_ebitda,
            "liquidez": a.liquidez,
            "valor_intrinseco": a.valor_intrinseco,
            "setor": a.setor,
            "score": s
        })
    return https_fn.Response(
        response=json.dumps(result),
        content_type="application/json"
    )


@https_fn.on_request(region="southamerica-east1")
def signals(req: https_fn.Request) -> https_fn.Response:
    import json
    result = []
    for a in ASSETS_DATA:
        s = score_acao(a)
        if sinal_compra(a, s):
            result.append({
                "ticker": a.ticker,
                "tipo": "compra",
                "mensagem": f"Score {s} - Ativo subvalorizado"
            })
        elif sinal_venda(a):
            result.append({
                "ticker": a.ticker,
                "tipo": "venda",
                "mensagem": "Preco acima de 120% do valor intrinseco"
            })
    return https_fn.Response(
        response=json.dumps(result),
        content_type="application/json"
    )
