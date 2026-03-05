from flask import Flask, request, jsonify
import yfinance as yf

app = Flask(__name__)

portfolio = []


# ---------------------------
# FUNÇÃO PARA BUSCAR DADOS
# ---------------------------
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
            "dy": info.get("dividendYield")
        }

    except:
        return None


# ---------------------------
# HOME
# ---------------------------
@app.route("/")
def home():
    return jsonify({"status": "Backend Verdent AI rodando!"})


# ---------------------------
# VER PORTFOLIO
# ---------------------------
@app.route("/portfolio", methods=["GET"])
def get_portfolio():

    total = 0

    for asset in portfolio:
        total += asset["price"] * asset["quantity"]

    return jsonify({
        "total_value": total,
        "assets": portfolio
    })


# ---------------------------
# ADICIONAR ATIVO
# ---------------------------
@app.route("/assets", methods=["POST"])
def add_asset():

    data = request.get_json()

    ticker = data.get("ticker")
    quantity = int(data.get("quantity", 1))

    stock_data = get_stock_data(ticker)

    if not stock_data:
        return jsonify({"error": "Ticker inválido"}), 400

    asset = {
        "ticker": stock_data["ticker"],
        "name": stock_data["name"],
        "sector": stock_data["sector"],
        "price": stock_data["price"],
        "pl": stock_data["pl"],
        "pvp": stock_data["pvp"],
        "roe": stock_data["roe"],
        "dy": stock_data["dy"],
        "quantity": quantity
    }

    portfolio.append(asset)

    return jsonify({
        "message": "Ativo adicionado",
        "asset": asset
    })


# ---------------------------
# ADICIONAR EM LOTE
# ---------------------------
@app.route("/assets/batch", methods=["POST"])
def add_batch():

    data = request.get_json()
    tickers = data.get("tickers", [])

    added = []

    for item in tickers:

        if isinstance(item, dict):
            ticker = item