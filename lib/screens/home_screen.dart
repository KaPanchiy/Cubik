import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../widgets/redeem_code_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161228),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161228),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Block Blast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.orange, size: 26),
            tooltip: 'Resgatar Código Promo',
            onPressed: () => RedeemCodeDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logótipo Estilo Block Blast
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231B40),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF3B2E68), width: 3),
                  ),
                  child: const Icon(Icons.grid_on_rounded, size: 72, color: Colors.amber),
                ),
                const SizedBox(height: 24),
                const Text(
                  'BLOCK BLAST',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Puzzle de Blocos Divertido',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 50),

                // Botão de Jogar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 32),
                    label: const Text(
                      'JOGAR',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Botão de Resgatar Código Promo
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    icon: const Icon(Icons.card_giftcard, color: Colors.orange, size: 24),
                    label: const Text(
                      'Resgatar Código Promo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => RedeemCodeDialog.show(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}