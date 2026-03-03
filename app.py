import time
import threading
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
def home():
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