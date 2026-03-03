import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'asset_detail_screen.dart';
import 'add_asset_screen.dart';

class PortfolioScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const PortfolioScreen({super.key, required this.themeProvider});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<dynamic>? assets;
  bool loading = true;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getAssets();
      setState(() {
        assets = data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _syncB3() async {
    setState(() => syncing = true);
    try {
      final res = await ApiService.syncAssets();
      final updated = (res["atualizados"] as List).length;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$updated ativo(s) atualizado(s) com dados da B3"),
            backgroundColor: Colors.green,
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao sincronizar: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => syncing = false);
    }
  }

  Future<void> _deleteAsset(String ticker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remover ativo"),
        content: Text("Deseja remover $ticker da carteira?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Remover")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteAsset(ticker);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$ticker removido"), backgroundColor: Colors.green),
      );
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carteira"),
        actions: [
          IconButton(
            icon: syncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurface),
                  )
                : const Icon(Icons.sync),
            tooltip: "Sincronizar com B3",
            onPressed: syncing ? null : _syncB3,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAssetScreen()),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assets == null || assets!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance, size: 64, color: cs.onSurfaceVariant),
                      const SizedBox(height: 16),
                      const Text("Nenhum ativo na carteira"),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddAssetScreen()),
                          );
                          _load();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Ativo"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: assets!.length,
                    itemBuilder: (context, i) {
                      final a = assets![i];
                      final score = a['score'] as num;
                      return Dismissible(
                        key: Key(a['ticker']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteAsset(a['ticker']);
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssetDetailScreen(asset: a),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: score >= 70
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              child: Text("${score.toInt()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: score >= 70 ? Colors.green : Colors.orange)),
                            ),
                            title: Text(a['ticker'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "${a['setor']} - ${a['tipo'].toString().toUpperCase()}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("R\$ ${a['preco']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  a['valor_intrinseco'] > a['preco']
                                      ? "Subvalorizado"
                                      : "Sobrevalorizado",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: a['valor_intrinseco'] > a['preco']
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
