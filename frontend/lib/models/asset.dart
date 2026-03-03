class Asset {
  final String ticker;
  final String tipo;
  final double preco;
  final double roe;
  final double pl;
  final double divEbitda;
  final double liquidez;
  final double valorIntrinseco;
  final String setor;

  Asset({
    required this.ticker,
    required this.tipo,
    required this.preco,
    required this.roe,
    required this.pl,
    required this.divEbitda,
    required this.liquidez,
    required this.valorIntrinseco,
    required this.setor,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      ticker: json['ticker'],
      tipo: json['tipo'],
      preco: (json['preco'] as num).toDouble(),
      roe: (json['roe'] as num).toDouble(),
      pl: (json['pl'] as num).toDouble(),
      divEbitda: (json['div_ebitda'] as num).toDouble(),
      liquidez: (json['liquidez'] as num).toDouble(),
      valorIntrinseco: (json['valor_intrinseco'] as num).toDouble(),
      setor: json['setor'],
    );
  }
}
