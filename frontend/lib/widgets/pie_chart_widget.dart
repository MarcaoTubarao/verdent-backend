import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, dynamic> allocation;
  const PieChartWidget({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final acoes = (allocation['Acoes'] as num).toDouble();
    final fiis = (allocation['FIIs'] as num).toDouble();
    final total = acoes + fiis;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.donut_large, color: cs.primary),
                const SizedBox(width: 8),
                Text("Alocacao",
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 130,
                    child: CustomPaint(
                      painter: _PieChartPainter(acoes / total, fiis / total),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(Colors.blue.shade600, "Acoes", acoes),
                    const SizedBox(height: 12),
                    _legendItem(Colors.amber.shade600, "FIIs", fiis),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, double value) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text("$label: ${value.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double acoesRatio;
  final double fiisRatio;
  _PieChartPainter(this.acoesRatio, this.fiisRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -3.14159 / 2;

    final acoesSweep = acoesRatio * 2 * 3.14159;
    final fiisSweep = fiisRatio * 2 * 3.14159;

    final paintAcoes = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;
    final paintFiis = Paint()
      ..color = Colors.amber.shade600
      ..style = PaintingStyle.fill;

    canvas.drawArc(rect, startAngle, acoesSweep, true, paintAcoes);
    canvas.drawArc(rect, startAngle + acoesSweep, fiisSweep, true, paintFiis);

    final innerPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
