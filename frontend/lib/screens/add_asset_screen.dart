import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _controller = TextEditingController();
  final _bulkController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _isError = false;

  Future<void> _addSingle() async {
    final ticker = _controller.text.trim().toUpperCase();
    if (ticker.isEmpty) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final res = await ApiService.addAsset(ticker);
      if (res.containsKey("error")) {
        setState(() {
          _message = res["error"];
          _isError = true;
        });
      } else {
        setState(() {
          _message = "${res['ticker']} adicionado com sucesso! Score: ${res['score']}";
          _isError = false;
        });
        _controller.clear();
      }
    } catch (e) {
      setState(() {
        _message = "Erro de conexao: $e";
        _isError = true;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addBulk() async {
    final text = _bulkController.text.trim();
    if (text.isEmpty) return;

    final tickers = text
        .split(RegExp(r'[,;\s\n]+'))
        .map((t) => t.trim().toUpperCase())
        .where((t) => t.isNotEmpty)
        .toList();

    if (tickers.isEmpty) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final res = await ApiService.bulkAddAssets(tickers);
      final added = (res["adicionados"] as List).length;
      final errors = res["erros"] as List;
      String msg = "$added ativo(s) adicionado(s)";
      if (errors.isNotEmpty) {
        msg += "\nNao encontrados: ${errors.join(', ')}";
      }
      setState(() {
        _message = msg;
        _isError = errors.isNotEmpty && added == 0;
      });
      if (added > 0) _bulkController.clear();
    } catch (e) {
      setState(() {
        _message = "Erro de conexao: $e";
        _isError = true;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Ativos")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: cs.primary),
                      const SizedBox(width: 8),
                      Text("Adicionar Ativo",
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Busca automatica de preco e fundamentos via B3",
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: "Ticker",
                      hintText: "Ex: PETR4, BBAS3, KNRI11",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child:
                                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addSingle,
                            ),
                    ),
                    onSubmitted: (_) => _addSingle(),
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
                  Row(
                    children: [
                      Icon(Icons.playlist_add, color: cs.primary),
                      const SizedBox(width: 8),
                      Text("Adicionar em Lote",
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Cole os tickers separados por virgula ou espaco",
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bulkController,
                    textCapitalization: TextCapitalization.characters,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "PETR4, BBAS3, ITSA4, MXRF11",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _addBulk,
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text("Adicionar Todos"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _isError
                  ? cs.errorContainer
                  : Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isError ? Icons.error_outline : Icons.check_circle,
                      color: _isError ? cs.error : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_message!,
                            style: TextStyle(
                                color: _isError
                                    ? cs.onErrorContainer
                                    : Colors.green.shade800))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bulkController.dispose();
    super.dispose();
  }
}
