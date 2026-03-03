def score_acao(asset):
    score = 0
    if asset.roe > 0.15:
        score += 30
    if asset.div_ebitda < 3:
        score += 20
    if asset.pl < 10:
        score += 20
    if asset.valor_intrinseco > asset.preco:
        score += 30
    return score
