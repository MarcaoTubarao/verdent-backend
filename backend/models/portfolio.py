class Portfolio:
    def __init__(self, assets=None):
        self.assets = assets or []
        self.total = sum(a.preco for a in self.assets)
