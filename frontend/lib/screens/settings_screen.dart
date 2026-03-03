import 'package:flutter/material.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  const SettingsScreen({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Configuracoes")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Modo Escuro"),
              subtitle: Text(
                  themeProvider.isDark ? "Dark Mode ativo" : "Light Mode ativo"),
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                color: cs.primary,
              ),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: cs.primary),
              title: const Text("Versao"),
              subtitle: const Text("BolsaBBB v1.0.0"),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.send, color: cs.primary),
              title: const Text("Telegram"),
              subtitle: const Text("Alertas de compra/venda ativos"),
              trailing: Icon(Icons.check_circle, color: Colors.green.shade600),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.cloud, color: cs.primary),
              title: const Text("Backend"),
              subtitle: const Text("Railway (online)"),
              trailing: Icon(Icons.check_circle, color: Colors.green.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
