from flask import Flask, request, jsonify
import yfinance as yf

app = Flask(__name__)

portfolio = []

# --------------------------------
# LISTA DE AÇÕES DA B3
# --------------------------------

b3_tickers = [
    "PETR4","VALE3","ITUB4","BBDC4","BBAS3",
    "WEGE3","EGIE3","TAEE11","TRPL4","CPLE6",
    "EQTL3","HYPE3","VIVT3","LREN3","MGLU3"
]

# --------------------------------
# BUSCAR DADOS DO ATIVO
# --------------------------------

def get_stock(ticker):

    try:

        stock = yf.Ticker(ticker + ".SA")
        info = stock.info

        roe = info.get("returnOnEquity")
        dy = info.get("dividendYield")
        pl = info.get("trailingPE")
        pvp = info.get("priceToBook")

        score = 0

        if roe and roe > 0.15:
            score += 2

        if dy and dy > 0.06:
            score += 2

        if pl and pl < 12:
            score += 1

        if pvp and pvp < 2:
            score += 1

        if score >= 5:
            rec = "BUY"
        elif score >= 3:
            rec = "HOLD"
        else:
            rec = "SELL"

        return {

            "ticker": ticker,
            "price": info.get("currentPrice"),
            "roe": roe,
            "pl": pl,
            "pvp": pvp,
            "dy": dy,
            "sector": info.get("sector"),
            "score": score,
            "recommendation": rec

        }

    except:

        return None


# --------------------------------
# HOME
# --------------------------------

@app.route("/")
def home():

    return jsonify({
        "status": "Verdent AI 3.0 online"
    })


# --------------------------------
# SCANNER B3
# --------------------------------

@app.route("/scanner")
def scanner():

    result = []

    for t in b3_tickers:

        data = get_stock(t)

        if data:
            result.append(data)

    result = sorted(
        result,
        key=lambda x: x["score"],
        reverse=True
    )

    return jsonify(result)


# --------------------------------
# PORTFOLIO
# --------------------------------

@app.route("/portfolio")
def get_portfolio():

    total = 0

    for a in portfolio:
        total += a["price"] * a["quantity"]

    return jsonify({

        "total_value": total,
        "assets": portfolio

    })


# --------------------------------
# ADD ASSET
# --------------------------------

@app.route("/assets", methods=["POST"])
def add_asset():

    data = request.get_json()

    ticker = data.get("ticker")
    quantity = int(data.get("quantity",1))

    stock = get_stock(ticker)

    if not stock:
        return jsonify({"error":"ticker inválido"}),400

    stock["quantity"] = quantity

    portfolio.append(stock)

    return jsonify({
        "asset":stock
    })


# --------------------------------
# IA RECOMENDAÇÃO
# --------------------------------

@app.route("/ai")
def ai():

    recommendations = []

    for t in b3_tickers:

        data = get_stock(t)

        if data and data["recommendation"] == "BUY":
            recommendations.append(data)

    return jsonify(recommendations)


# --------------------------------
# ALOCAÇÃO
# --------------------------------

@app.route("/allocation")
def allocation():

    stocks = len(portfolio)

    return jsonify({
        "stocks": stocks,
        "fiis": 0
    })


# --------------------------------
# SIGNALS
# --------------------------------

@app.route("/signals")
def signals():

    return jsonify({
        "signal":"BUY",
        "confidence":82
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0",port=8080)