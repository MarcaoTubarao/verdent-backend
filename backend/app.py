from flask import Flask, request, jsonify
import yfinance as yf

app = Flask(__name__)

portfolio = []


def get_stock_data(ticker):

    try:

        symbol = ticker + ".SA"

        stock = yf.Ticker(symbol)

        info = stock.info

        return {
            "price": info.get("currentPrice", 0),
            "roe": info.get("returnOnEquity", 0),
            "pl": info.get("trailingPE", 0),
            "pvp": info.get("priceToBook", 0),
            "dy": info.get("dividendYield", 0)
        }

    except:

        return {
            "price": 0,
            "roe": 0,
            "pl": 0,
            "pvp": 0,
            "dy": 0
        }


@app.route("/")
def home():
    return jsonify({"status": "Backend Verdent AI rodando!"})


@app.route("/portfolio", methods=["GET"])
def get_portfolio():

    updated_assets = []

    total = 0

    for asset in portfolio:

        data = get_stock_data(asset["ticker"])

        price = data["price"]

        quantity = asset["quantity"]

        value = price * quantity

        total += value

        updated_assets.append({
            "ticker": asset["ticker"],
            "price": price,
            "quantity": quantity,
            "roe": data["roe"],
            "pl": data["pl"],
            "pvp": data["pvp"],
            "dy": data["dy"],
            "value": value
        })

    return jsonify({
        "total_value": total,
        "assets": updated_assets
    })


@app.route("/assets", methods=["POST"])
def add_asset():

    try:

        data = request.get_json()

        ticker = data.get("ticker")
        quantity = int(data.get("quantity", 1))

        portfolio.append({
            "ticker": ticker.upper(),
            "quantity": quantity
        })

        return jsonify({
            "message": "Ativo adicionado",
            "ticker": ticker
        })

    except Exception as e:

        return jsonify({"error": str(e)}), 400


@app.route("/assets/batch", methods=["POST"])
def add_batch():

    try:

        data = request.get_json()

        tickers = data.get("tickers", [])

        for item in tickers:

            ticker = item["ticker"]
            quantity = item.get("quantity", 1)

            portfolio.append({
                "ticker": ticker.upper(),
                "quantity": quantity
            })

        return jsonify({"message": "Ativos adicionados"})

    except Exception as e:

        return jsonify({"error": str(e)}), 400


@app.route("/allocation")
def allocation():

    return jsonify({
        "stocks": 100,
        "fiis": 0
    })


@app.route("/signals")
def signals():

    return jsonify({
        "signal": "BUY",
        "confidence": 80
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)