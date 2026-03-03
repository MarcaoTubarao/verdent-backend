from flask import Flask
import requests
import time
import threading

app = Flask(__name__)

def monitorar():
    while True:
        print("Monitorando ativos...")
        time.sleep(600)  # 10 minutos

@app.route("/")
def home():
    return "Backend Verdent AI rodando!"

if __name__ == "__main__":
    thread = threading.Thread(target=monitorar)
    thread.start()
    app.run(host="0.0.0.0", port=5000)