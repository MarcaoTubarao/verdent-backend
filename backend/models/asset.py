class Asset:
    def __init__(self, ticker, tipo, preco, roe, pl,
                 div_ebitda, liquidez, valor_intrinseco, setor):
        self.ticker = ticker
        self.tipo = tipo
        self.preco = preco
        self.roe = roe
        self.pl = pl
        self.div_ebitda = div_ebitda
        self.liquidez = liquidez
        self.valor_intrinseco = valor_intrinseco
        self.setor = setor
