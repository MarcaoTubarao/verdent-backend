import requests

HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json",
}


def buscar_dados_ativo(ticker):
    ticker = ticker.upper().strip()
    is_fii = ticker.endswith("11") and len(ticker) >= 6

    if is_fii:
        url = "https://statusinvest.com.br/fii/tickerprice"
    else:
        url = "https://statusinvest.com.br/acoes/tickerprice"

    try:
        resp = requests.get(
            url,
            params={"ticker": ticker, "type": "4" if not is_fii else "2"},
            headers=HEADERS,
            timeout=10,
        )
        data = resp.json()
        if not data or len(data) == 0:
            return None
        item = data[0] if isinstance(data, list) else data
        preco = item.get("price", 0)
    except Exception:
        preco = 0

    fundamentos = _buscar_fundamentos(ticker, is_fii)

    tipo = "fii" if is_fii else "acao"
    setor = fundamentos.get("setor", "N/A")
    roe = fundamentos.get("roe", 0)
    pl = fundamentos.get("pl", 0)
    div_ebitda = fundamentos.get("div_ebitda", 0)
    liquidez = fundamentos.get("liquidez", 0)
    lpa = fundamentos.get("lpa", 0)
    vpa = fundamentos.get("vpa", 0)

    if vpa > 0 and lpa > 0:
        valor_intrinseco = (22.5 * lpa * vpa) ** 0.5
    elif preco > 0 and pl > 0:
        valor_intrinseco = preco / pl * 15
    else:
        valor_intrinseco = preco

    return {
        "ticker": ticker,
        "tipo": tipo,
        "preco": preco,
        "roe": roe,
        "pl": pl,
        "div_ebitda": div_ebitda,
        "liquidez": liquidez,
        "valor_intrinseco": round(valor_intrinseco, 2),
        "setor": setor,
    }


def _buscar_fundamentos(ticker, is_fii=False):
    try:
        if is_fii:
            url = f"https://statusinvest.com.br/fii/{ticker.lower()}"
        else:
            url = f"https://statusinvest.com.br/acoes/{ticker.lower()}"

        resp = requests.get(url, headers=HEADERS, timeout=10)
        html = resp.text

        roe = _extrair_indicador(html, "ROE")
        pl = _extrair_indicador(html, "P/L")
        div_ebitda = _extrair_indicador(html, "D")
        lpa = _extrair_indicador(html, "LPA")
        vpa = _extrair_indicador(html, "VPA")

        return {
            "roe": roe / 100 if roe != 0 else 0,
            "pl": pl,
            "div_ebitda": div_ebitda,
            "liquidez": 1_000_000,
            "lpa": lpa,
            "vpa": vpa,
            "setor": "N/A",
        }
    except Exception:
        return {
            "roe": 0, "pl": 0, "div_ebitda": 0,
            "liquidez": 0, "lpa": 0, "vpa": 0, "setor": "N/A",
        }


def _extrair_indicador(html, nome):
    try:
        import re
        patterns = [
            rf'title="{nome}"[^>]*>.*?<strong[^>]*>([^<]+)</strong>',
            rf'{nome}.*?<strong[^>]*>\s*([\d,.\-]+)\s*</strong>',
        ]
        for pattern in patterns:
            match = re.search(pattern, html, re.DOTALL | re.IGNORECASE)
            if match:
                val = match.group(1).strip().replace(".", "").replace(",", ".")
                return float(val)
    except Exception:
        pass
    return 0


def get_preco_e_volume(ticker):
    dados = buscar_dados_ativo(ticker)
    if dados:
        return {"preco": dados["preco"], "volume": dados["liquidez"]}
    return {"preco": 0, "volume": 0}
