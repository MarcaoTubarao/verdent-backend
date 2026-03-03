def sinal_compra(asset, score):
    return score >= 70


def sinal_venda(asset):
    return asset.preco >= asset.valor_intrinseco * 1.2
