from flask import Flask, request, jsonify

app = Flask(__name__)

portfolio = []

@app.route("/")
def home():
    return jsonify({"status": "Backend Verdent AI rodando!"})

@app.route("/portfolio", methods=["GET"])
def get_portfolio():
    total = sum(asset["price"] * asset["quantity"] for asset in portfolio)

    return jsonify({
        "total_value": total,
        "assets": portfolio
    })

@app.route("/assets", methods=["POST"])
def add_asset():
    try:
        data = request.get_json()

        ticker = data.get("ticker")
        quantity = int(data.get("quantity", 1))

        if not ticker:
            return jsonify({"error": "Ticker obrigatório"}), 400

        asset = {
            "ticker": ticker.upper(),
            "price": 100.0,
            "quantity": quantity
        }

        portfolio.append(asset)

        return jsonify({
            "message": "Ativo adicionado com sucesso",
            "asset": asset
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/assets/batch", methods=["POST"])
def add_batch():
    try:
        data = request.get_json()
        tickers = data.get("tickers", [])

        added = []

        for item in tickers:
            if isinstance(item, dict):
                ticker = item.get("ticker")
                quantity = int(item.get("quantity", 1))
            else:
                ticker = item
                quantity = 1

            asset = {
                "ticker": ticker.upper(),
                "price": 100.0,
                "quantity": quantity
            }

            portfolio.append(asset)
            added.append(asset)

        return jsonify({
            "message": "Ativos adicionados com sucesso",
            "assets": added
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/allocation", methods=["GET"])
def allocation():
    return jsonify({"stocks": 60, "fiis": 40})

@app.route("/signals", methods=["GET"])
def signals():
    return jsonify({"signal": "BUY", "confidence": 87})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)