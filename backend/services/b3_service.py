import yfinance as yf

def get_stock_data(ticker):
    try:
        if ".SA" not in ticker:
            ticker = ticker + ".SA"

        stock = yf.Ticker(ticker)

        info = stock.info
        hist = stock.history(period="1d")

        if hist.empty:
            return None

        preco = hist["Close"].iloc[-1]

        roe = info.get("returnOnEquity")
        pl = info.get("trailingPE")

        # Tratamento correto de None
        roe_value = round(roe * 100, 2) if roe is not None else None
        pl_value = round(pl, 2) if pl is not None else None

        # Valuation simples exemplo
        valor_intrinseco = None
        if roe_value and pl_value:
            valor_intrinseco = round(preco * (roe_value / 15), 2)

        return {
            "ticker": ticker,
            "preco": round(preco, 2),
            "roe": roe_value,
            "pl": pl_value,
            "valor_intrinseco": valor_intrinseco
        }

    except Exception as e:
        print("Erro:", e)
        return None