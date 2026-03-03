import requests
from config import TELEGRAM_TOKEN, TELEGRAM_CHAT_ID


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
