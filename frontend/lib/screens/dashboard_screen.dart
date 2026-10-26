import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF1493)),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildNavCard(context, 'Criar Carta', Icons.add_photo_alternate, '/create_card'),
          _buildNavCard(context, 'Gerenciar Deck', Icons.view_carousel, '/deckbuilder'),
          _buildNavCard(context, 'Arquétipos (IA)', Icons.auto_awesome, '/archetypes'),
          _buildNavCard(context, 'Simulador', Icons.sports_esports, '/simulator'),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () {
        // Navegação futura
      },
      child: Card(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFFF1493)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}