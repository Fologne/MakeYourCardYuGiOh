import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Confirmar Saida',
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Deseja realmente encerrar sua sessao?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1493),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _openFeature(BuildContext context, String title, String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: modulo em preparacao nas proximas etapas.'),
        backgroundColor: const Color(0xFFFFD700),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    final displayName = user?.username.isNotEmpty == true
        ? user!.username
        : 'Duelista';
    final accountId = user?.accountId ?? 'MYC-000000';
    final pronoun = user?.preferredPronoun ?? 'Duelista';
    final plan = user?.plan ?? 'Gratuito';
    final origin = user?.gameOrigin ?? 'TCG';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'MAKE YOUR CARD',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          // Icone de engrenagem no canto para acessar a aba de configuracoes
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFFFD700)),
            tooltip: 'Configuracoes',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          // Botao para sair da conta
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF1493)),
            tooltip: 'Encerrar Sessao',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner com dados do usuario logado
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1493).withValues(alpha: 0.15),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      color: const Color(0xFF222222),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFFF1493),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ola, $pronoun $displayName',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $accountId',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildBadge('Origem: $origin', const Color(0xFFFF1493)),
                            _buildBadge('Plano: $plan', const Color(0xFFFFD700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Titulo da secao de navegacao
            const Text(
              'PAINEL DE CONTROLE',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Grade de navegacao adaptativa
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.05,
                  children: [
                    _buildNavCard(
                      context,
                      title: 'Criar Carta',
                      subtitle: 'Monstros, Magias e Armadilhas',
                      icon: Icons.add_photo_alternate,
                      route: '/create_card',
                      accentColor: const Color(0xFFFFD700),
                    ),
                    _buildNavCard(
                      context,
                      title: 'Gerenciar Deck',
                      subtitle: 'Montagem e organizacao',
                      icon: Icons.view_carousel,
                      route: '/deckbuilder',
                      accentColor: const Color(0xFFFF1493),
                    ),
                    _buildNavCard(
                      context,
                      title: 'Arquetipos (IA)',
                      subtitle: 'Criacao assistida e combos',
                      icon: Icons.auto_awesome,
                      route: '/archetypes',
                      accentColor: const Color(0xFFFFD700),
                    ),
                    _buildNavCard(
                      context,
                      title: 'Simulador',
                      subtitle: 'Duelos manuais interativos',
                      icon: Icons.sports_esports,
                      route: '/simulator',
                      accentColor: const Color(0xFFFF1493),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFeature(context, title, route),
        borderRadius: BorderRadius.circular(12),
        hoverColor: accentColor.withValues(alpha: 0.08),
        splashColor: accentColor.withValues(alpha: 0.18),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            border: Border.all(color: accentColor, width: 1.2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 36, color: accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
