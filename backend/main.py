from fastapi import FastAPI
from services.b3_service import get_stock_data

app = FastAPI()

@app.get("/")
def home():
    return {"status": "Backend Verdent rodando 🚀"}

@app.get("/stock/{ticker}")
def stock(ticker: str):
    data = get_stock_data(ticker)

    if not data:
        return {"error": "Ativo não encontrado"}

    return data