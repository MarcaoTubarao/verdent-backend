import threading
import time

from flask import Flask, jsonify

app = Flask(__name__)

# ==============================
# MONITORAMENTO EM BACKGROUND
# ==============================

def monitorar():
    while True:
        print("Monitorando ativos...")
        time.sleep(600)

# ==============================
# ROTAS
# ==============================

@app.route("/")
def home(): pass

app = Flask(__name__)

portfolio = []

@app.route("/")
def home():
    return "Backend Verdent AI rodando!"

@app.route("/portfolio", methods=["GET"])
def get_portfolio():
    return jsonify({
        "total_value": 10000,
        "assets": portfolio
    })

@app.route("/assets", methods=["POST"])
def add_asset():
    data = request.json

    if not data or "ticker" not in data:
        return jsonify({"error": "Ticker obrigatório"}), 400

    asset = {
        "ticker": data["ticker"],
        "price": 100,
        "quantity": 1
    }

    portfolio.append(asset)

    return jsonify({"message": "Ativo adicionado", "asset": asset})

@app.route("/assets/batch", methods=["POST"])
def add_batch():
    data = request.json

    if not data or "tickers" not in data:
        return jsonify({"error": "Lista de tickers obrigatória"}), 400

    added = []

    for ticker in data["tickers"]:
        asset = {
            "ticker": ticker.strip(),
            "price": 100,
            "quantity": 1
        }
        portfolio.append(asset)
        added.append(asset)

    return jsonify({"message": "Ativos adicionados", "assets": added})

@app.route("/allocation", methods=["GET"])
def allocation():
    return jsonify({"stocks": 60, "fiis": 40})

@app.route("/signals", methods=["GET"])
def signals():
    return jsonify({"signal": "BUY", "confidence": 87})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
    return jsonify({
        "status": "online",
        "message": "Backend Verdent AI rodando 🚀"
    })

@app.route("/portfolio")
def portfolio():
    return jsonify({
        "total_value": 10000,
        "assets": []
    })

@app.route("/allocation")
def allocation():
    return jsonify({
        "stocks": 50,
        "crypto": 30,
        "cash": 20
    })

@app.route("/signals")
def signals():
    return jsonify({
        "signals": []
    })

@app.route("/assets")
def assets():
    return jsonify({
        "assets": []
    })

# ==============================
# EXECUÇÃO LOCAL
# ==============================

if __name__ == "__main__":
    thread = threading.Thread(target=monitorar)
    thread.daemon = True
    thread.start()

    app.run(host="0.0.0.0", port=5000)