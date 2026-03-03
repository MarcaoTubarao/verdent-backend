def regras_fiis(asset):
    score = 0
    if asset.div_ebitda < 2:
        score += 30
    if asset.liquidez > 500_000:
        score += 20
    return score
