class Portfolio {
  final double total;
  final double rentabilidade;

  Portfolio({required this.total, required this.rentabilidade});

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      total: (json['total'] as num).toDouble(),
      rentabilidade: (json['rentabilidade'] as num).toDouble(),
    );
  }
}
