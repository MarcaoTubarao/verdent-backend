import requests


def get_fundamentos(ticker):
    url = f"https://api.statusinvest.com.br/asset/{ticker}"
    return requests.get(url, timeout=10).json()
