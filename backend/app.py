from flask import Flask, request, jsonify

app = Flask(__name__)

portfolio = []

@app.route("/")
def home():
    return jsonify({"status": "Backend Verdent AI rodando!"})


# ==============================
# PORTFOLIO
# ==============================
@app.route("/portfolio", methods=["GET"])
def get_portfolio():
    total = sum(asset["price"] * asset["quantity"] for asset in portfolio)

    return jsonify({
        "total_value": total,
        "assets": portfolio
    })


# ==============================
# ADD ASSET
# ==============================
@app.route("/assets", methods=["GET", "POST"])
def add_asset():

    if request.method == "GET":
        return jsonify({"message": "Use POST para adicionar ativos"})

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


# =================