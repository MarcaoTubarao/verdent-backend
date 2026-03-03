import 'package:flutter/material.dart';

class AssetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final score = (asset['score'] as num).toInt();
    final preco = asset['preco'];
    final vi = asset['valor_intrinseco'];
    final upside = ((vi - preco) / preco * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: Text(asset['ticker'])),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: score >= 70
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    child: Text("$score",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:
                                score >= 70 ? Colors.green : Colors.orange)),
                  ),
                  const SizedBox(height: 12),
                  Text(asset['ticker'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("${asset['setor']} - ${asset['tipo'].toString().toUpperCase()}",
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Valuation",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _row("Preco Atual", "R\$ $preco"),
                  _row("Valor Intrinseco", "R\$ $vi"),
                  _divider(),
                  _row(
                    "Upside",
                    "$upside%",
                    valueColor: vi > preco ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Indicadores",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _row("ROE",
                      "${(asset['roe'] * 100).toStringAsFixed(1)}%"),
                  _row("P/L", "${asset['pl']}"),
                  _row("Div/EBITDA", "${asset['div_ebitda']}"),
                  _row("Liquidez",
                      "${(asset['liquidez'] / 1000000).toStringAsFixed(1)}M"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(),
    );
  }
}
