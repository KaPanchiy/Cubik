import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/board.dart';
import '../modelos/piece.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/redeem_code_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Board board = Board();
  List<Piece> availablePieces = [];
  int highScore = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _spawnNewPieces();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        highScore = prefs.getInt('block_blast_high_score') ?? 0;
      });
    }
  }

  Future<void> _updateHighScoreIfNeeded() async {
    if (board.score > highScore) {
      setState(() {
        highScore = board.score;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('block_blast_high_score', highScore);
    }
  }

  void _spawnNewPieces() {
    setState(() {
      availablePieces = Piece.getRandomPieces(3);
    });
    _checkGameOver();
  }

  void _handlePiecePlaced(Piece piece, int row, int col) {
    setState(() {
      board.placePiece(piece, row, col);
      availablePieces.removeWhere((p) => p.id == piece.id);

      _updateHighScoreIfNeeded();

      // Se todas as 3 peças da bandeja foram colocadas, gera 3 novas
      if (availablePieces.isEmpty) {
        availablePieces = Piece.getRandomPieces(3);
      }

      _checkGameOver();
    });
  }

  void _checkGameOver() {
    if (isGameOver) return;

    if (!board.canPlaceAnyPiece(availablePieces)) {
      setState(() {
        isGameOver = true;
      });
      _showGameOverDialog();
    }
  }

  void _restartGame() {
    setState(() {
      board.reset();
      isGameOver = false;
      availablePieces = Piece.getRandomPieces(3);
    });
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF231B40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pause_circle_filled, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text('Jogo Pausado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Continuar a Jogar', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Reiniciar Jogo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _restartGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.orange),
              title: const Text('Resgatar Código Promo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                RedeemCodeDialog.show(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.grey),
              title: const Text('Menu Inicial', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF231B40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Game Over!',
            style: TextStyle(color: Colors.redAccent, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 54, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Pontuação Final: ${board.score}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Recorde: $highScore',
              style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              RedeemCodeDialog.show(context);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, color: Colors.orange, size: 18),
                SizedBox(width: 4),
                Text('Resgatar Código', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('Jogar De Novo', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.card_giftcard, color: Colors.orange),
            tooltip: 'Resgatar Código Promo',
            onPressed: () => RedeemCodeDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            tooltip: 'Pausa',
            onPressed: _showPauseDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Painéis HUD (Recorde & Pontuação Atual)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // High Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231B40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$highScore',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  // Current Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231B40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${board.score}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabuleiro 8x8
            Center(
              child: GameBoardWidget(
                board: board,
                onPiecePlaced: _handlePiecePlaced,
              ),
            ),

            // Bandeja de 3 Peças Arrastáveis (Draggable)
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availablePieces.map((piece) {
                  return Draggable<Piece>(
                    data: piece,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.1,
                        child: _buildPieceWidget(piece, isFeedback: true),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.2,
                      child: _buildPieceWidget(piece),
                    ),
                    child: _buildPieceWidget(piece),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceWidget(Piece piece, {bool isFeedback = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isFeedback
          ? null
          : BoxDecoration(
              color: const Color(0xFF231B40).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B2E68), width: 1),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: piece.shape.map((row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((block) {
              if (block == 0) {
                return const SizedBox(width: 18, height: 18);
              }
              return Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      piece.color.withValues(alpha: 0.9),
                      piece.color,
                      Color.lerp(piece.color, Colors.black, 0.3)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Color.lerp(piece.color, Colors.white, 0.4)!,
                    width: 1,
                  ),
                  boxShadow: isFeedback
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
