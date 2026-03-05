from flask import Flask, request, jsonify
import yfinance as yf
import pandas as pd

app = Flask(__name__)

portfolio = []

# --------------------------------
# BUSCAR DADOS DO ATIVO
# --------------------------------
def get_stock_data(ticker):

    try:
        ticker_b3 = ticker + ".SA"
        stock = yf.Ticker(ticker_b3)

        info = stock.info

        return {
            "ticker": ticker.upper(),
            "name": info.get("shortName"),
            "sector": info.get("sector"),
            "price": info.get("currentPrice"),
            "pl": info.get("trailingPE"),
            "pvp": info.get("priceToBook"),
            "roe": info.get("returnOnEquity"),
            "dy": info.get("dividendYield"),
            "marketcap": info.get("marketCap")
        }

    except:
        return None


# --------------------------------
# HOME
# --------------------------------
@app.route("/")
def home():
    return jsonify({"status": "Verdent AI Backend 2.0 rodando"})


# --------------------------------
# PORTFOLIO
# --------------------------------
@app.route("/portfolio", methods=["GET"])
def get_portfolio():

    total = 0

    for asset in portfolio:
        total += asset["price"] * asset["quantity"]

    return jsonify({
        "total_value": total,
        "assets": portfolio
    })


# --------------------------------
# ADICIONAR ATIVO
# --------------------------------
@app.route("/assets", methods=["POST"])
def add_asset():

    data = request.get_json()

    ticker = data.get("ticker")
    quantity = int(data.get("quantity", 1))

    stock = get_stock_data(ticker)

    if not stock:
        return jsonify({"error": "Ticker inválido"}), 400

    stock["quantity"] = quantity

    portfolio.append(stock)

    return jsonify({
        "message": "Ativo adicionado",
        "asset": stock
    })


# --------------------------------
# RANKING DIVIDENDOS
# --------------------------------
@app.route("/top-dividendos", methods=["GET"])
def top_dividendos():

    tickers = [
        "PETR4","VALE3","BBAS3","ITUB4",
        "TAEE11","TRPL4","EGIE3","CPLE6"
    ]

    stocks = []

    for t in tickers:

        data = get_stock_data(t)

        if data:
            stocks.append(data)

    ranked = sorted(
        stocks,
        key=lambda x: x["dy"] if x["dy"] else 0,
        reverse=True
    )

    return jsonify(ranked)


# --------------------------------
# RANKING ROE
# --------------------------------
@app.route("/top-roe", methods=["GET"])
def top_roe():

    tickers = [
        "WEGE3","ITUB4","BBAS3","VALE3",
        "PETR4","EQTL3","RAIL3"
    ]

    stocks = []

    for t in tickers:

        data = get_stock_data(t)

        if data:
            stocks.append(data)

    ranked = sorted(
        stocks,
        key=lambda x: x["roe"] if x["roe"] else 0,
        reverse=True
    )

    return jsonify(ranked)


# --------------------------------
# IA SIMPLES DE RECOMENDAÇÃO
# --------------------------------
@app.route("/ai-recommendation", methods=["GET"])
def ai_recommendation():

    tickers = [
        "WEGE3","ITUB4","BBAS3",
        "VALE3","PETR4","EGIE3"
    ]

    recommendations = []

    for t in tickers:

        data = get_stock_data(t)

        if not data:
            continue

        score = 0

        if data["roe"] and data["roe"] > 0.15:
            score += 2

        if data["dy"] and data["dy"] > 0.06:
            score += 2

        if data["pl"] and data["pl"] < 10:
            score += 1

        data["score"] = score

        recommendations.append(data)

    ranked = sorted(
        recommendations,
        key=lambda x: x["score"],
        reverse=True
    )

    return jsonify(ranked)


# --------------------------------
# ALOCAÇÃO
# --------------------------------
@app.route("/allocation")
def allocation():
    return jsonify({"stocks": 70, "fiis": 30})


# --------------------------------
# SIGNALS
# --------------------------------
@app.route("/signals")
def signals():
    return jsonify({"signal": "BUY", "confidence": 87})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)