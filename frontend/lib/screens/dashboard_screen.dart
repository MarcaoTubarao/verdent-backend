import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../theme.dart';
import 'portfolio_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const DashboardScreen({super.key, required this.themeProvider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(themeProvider: widget.themeProvider),
      PortfolioScreen(themeProvider: widget.themeProvider),
      SettingsScreen(themeProvider: widget.themeProvider),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: "Carteira",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Config",
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  const _DashboardPage({required this.themeProvider});

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  Map<String, dynamic>? portfolio;
  Map<String, dynamic>? allocation;
  List<dynamic>? assets;
  List<dynamic>? signals;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getPortfolio(),
        ApiService.getAllocation(),
        ApiService.getAssets(),
        ApiService.getSignals(),
      ]);
      setState(() {
        portfolio = results[0] as Map<String, dynamic>;
        allocation = results[1] as Map<String, dynamic>;
        assets = results[2] as List<dynamic>;
        signals = results[3] as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BolsaBBB"),
        actions: [
          IconButton(
            icon: Icon(widget.themeProvider.isDark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => widget.themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: cs.error),
                      const SizedBox(height: 16),
                      Text("Erro ao carregar dados",
                          style: TextStyle(color: cs.error, fontSize: 18)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          _loadData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Tentar novamente"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPortfolioCard(cs),
                      const SizedBox(height: 16),
                      PieChartWidget(allocation: allocation!),
                      const SizedBox(height: 16),
                      LineChartWidget(assets: assets!),
                      const SizedBox(height: 16),
                      _buildSignalsCard(cs),
                      const SizedBox(height: 16),
                      _buildAssetsTable(cs),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPortfolioCard(ColorScheme cs) {
    final rent = (portfolio!['rentabilidade'] as num).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: cs.primary),
                const SizedBox(width: 8),
                Text("Carteira",
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total",
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    Text("R\$ ${portfolio!['total'].toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Rentabilidade",
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    Row(
                      children: [
                        Icon(
                          rent >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: rent >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text("${rent}%",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color:
                                    rent >= 0 ? Colors.green : Colors.red)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalsCard(ColorScheme cs) {
    if (signals == null || signals!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.notifications_none, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              const Text("Nenhum sinal no momento"),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: cs.primary),
                const SizedBox(width: 8),
                Text("Sinais", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            ...signals!.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: s['tipo'] == 'compra'
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s['tipo'] == 'compra' ? "COMPRA" : "VENDA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: s['tipo'] == 'compra'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(s['ticker'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(s['mensagem'],
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsTable(ColorScheme cs) {
    if (assets == null || assets!.isEmpty) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: cs.primary),
                const SizedBox(width: 8),
                Text("Ativos Monitorados",
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Ticker")),
                  DataColumn(label: Text("Tipo")),
                  DataColumn(label: Text("Preco"), numeric: true),
                  DataColumn(label: Text("V. Intrinseco"), numeric: true),
                  DataColumn(label: Text("ROE"), numeric: true),
                  DataColumn(label: Text("P/L"), numeric: true),
                  DataColumn(label: Text("Score"), numeric: true),
                ],
                rows: assets!
                    .map((a) => DataRow(cells: [
                          DataCell(Text(a['ticker'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: a['tipo'] == 'acao'
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(a['tipo'].toString().toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: a['tipo'] == 'acao'
                                        ? Colors.blue
                                        : Colors.amber.shade800)),
                          )),
                          DataCell(Text("R\$ ${a['preco']}")),
                          DataCell(Text("R\$ ${a['valor_intrinseco']}")),
                          DataCell(Text(
                              "${(a['roe'] * 100).toStringAsFixed(1)}%")),
                          DataCell(Text("${a['pl']}")),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: a['score'] >= 70
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("${a['score']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: a['score'] >= 70
                                        ? Colors.green
                                        : Colors.orange)),
                          )),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
