import 'dart:async';
import 'package:flutter/material.dart';
import '../modelos/board.dart';
import '../modelos/piece.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/redeem_code_dialog.dart';
import '../services/score_service.dart';

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

  // ── Boost 2x & Combos ──────────────────────────────────────────────────────
  static const int _codeBoostDurationSecs = 120; // 2 minutos (Código BLOCK2026)
  static const int _comboBoostDurationSecs = 90; // 1 minuto e 30 segundos (5 Combos)
  int _boostSecsLeft = 0;
  int _comboStreak = 0;
  Timer? _boostTimer;

  // ── Sistema de Vidas & Renascimento (REVIVE) ───────────────────────────────
  bool _hasUsedReviveThisMatch = false;

  void _executeRevive() {
    setState(() {
      _hasUsedReviveThisMatch = true;
      isGameOver = false;
      board.clearForRevive();
      availablePieces = Piece.getRandomPieces(3);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE91E63),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💖 RENASCIDO COM SUCESSO!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'A tua pontuação de ${board.score} foi mantida. Continua a jogar!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  bool get _isBoostActive => _boostSecsLeft > 0;

  void _startBoostCountdown() {
    _boostTimer?.cancel();
    _boostTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _boostSecsLeft--;
        if (_boostSecsLeft <= 0) {
          _boostSecsLeft = 0;
          t.cancel();
        }
      });
    });
  }

  void _activateBoost(int remainingUsesAfter) {
    setState(() => _boostSecsLeft = _codeBoostDurationSecs);
    _startBoostCountdown();

    // Snackbar de confirmação do código promocional
    if (mounted) {
      final usosStr = remainingUsesAfter == 0
          ? 'Último uso de hoje!'
          : '$remainingUsesAfter uso${remainingUsesAfter == 1 ? '' : 's'} restante${remainingUsesAfter == 1 ? '' : 's'} hoje';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚡ Código BLOCK2026: Boost 2x por 2 min! ($usosStr)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _awardComboBoost() {
    setState(() {
      _boostSecsLeft = (_boostSecsLeft > 0)
          ? _boostSecsLeft + _comboBoostDurationSecs
          : _comboBoostDurationSecs;
    });
    _startBoostCountdown();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF6D00),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.yellow, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 COMBO x$_comboStreak CONQUISTADO!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Recebeste 2x de pontuação por 1m 30s grátis! ⚡',
                      style: TextStyle(
                        color: Colors.yellow.shade100,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _spawnNewPieces();
  }

  @override
  void dispose() {
    _boostTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final score = await ScoreService.getHighScore(
      onRemoteUpdated: (remoteScore) {
        if (mounted) setState(() => highScore = remoteScore);
      },
    );
    if (mounted) {
      setState(() {
        highScore = score;
      });
    }
  }

  Future<void> _updateHighScoreIfNeeded() async {
    if (board.score > highScore) {
      setState(() {
        highScore = board.score;
      });
      await ScoreService.saveHighScore(highScore);
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
      final scoreBefore = board.score;
      final clearedLines = board.placePiece(piece, row, col);

      // Aplicar multiplicador 2x se boost ativo
      if (_isBoostActive) {
        final earned = board.score - scoreBefore;
        board.score += earned; // duplica os pontos ganhos
      }

      // Verificação de combos seguidos:
      // Se limpou pelo menos 1 linha/coluna, incrementa a sequência de combos
      if (clearedLines > 0) {
        _comboStreak++;
        if (_comboStreak % 5 == 0) {
          _awardComboBoost();
        }
      } else {
        _comboStreak = 0;
      }

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
      _comboStreak = 0;
      _hasUsedReviveThisMatch = false; // Reset da vida para a nova partida
      availablePieces = Piece.getRandomPieces(3);
    });
  }

  void _openRedeemDialog() {
    RedeemCodeDialog.show(
      context,
      onBoostActivated: _activateBoost,
      onReviveActivated: () {
        if (!_hasUsedReviveThisMatch) {
          _executeRevive();
        }
      },
    );
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
                _openRedeemDialog();
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
    final TextEditingController reviveController = TextEditingController();
    String? localError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool canRevive = !_hasUsedReviveThisMatch;

          return AlertDialog(
            backgroundColor: const Color(0xFF231B40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (canRevive) ...[
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 4),
                      Icon(Icons.heart_broken, color: Colors.grey.shade600, size: 28),
                    ] else ...[
                      Icon(Icons.heart_broken, color: Colors.grey.shade600, size: 28),
                      const SizedBox(width: 4),
                      Icon(Icons.heart_broken, color: Colors.grey.shade600, size: 28),
                      const SizedBox(width: 4),
                      Icon(Icons.heart_broken, color: Colors.grey.shade600, size: 28),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  canRevive ? 'Perdeste 1 Vida!' : 'Game Over Final!',
                  style: TextStyle(
                    color: canRevive ? Colors.orangeAccent : Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canRevive
                      ? 'Restam-te 2 vidas! Podes reviver e continuar!'
                      : '0 vidas restantes nesta partida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: canRevive ? Colors.amber.shade200 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161228),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Pontuação', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              '${board.score}',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.white24),
                        Column(
                          children: [
                            const Text('Recorde', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              '$highScore',
                              style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (canRevive) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1A47),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.vpn_key, color: Colors.pinkAccent, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Código de Renascimento',
                                style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Insere REVIVE para continuar esta partida com a tua pontuação (1 uso por partida):',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: reviveController,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Digita: REVIVE',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                              filled: true,
                              fillColor: const Color(0xFF161228),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.pinkAccent),
                              ),
                            ),
                            onSubmitted: (_) {
                              final text = reviveController.text.trim().toLowerCase();
                              if (text == 'revive') {
                                Navigator.pop(dialogContext);
                                _executeRevive();
                              } else {
                                setDialogState(() => localError = 'Código incorreto. Usa REVIVE!');
                              }
                            },
                          ),
                          if (localError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              localError!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.favorite, size: 18),
                            label: const Text('Reviver Agora', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              final text = reviveController.text.trim().toLowerCase();
                              if (text == 'revive') {
                                Navigator.pop(dialogContext);
                                _executeRevive();
                              } else {
                                setDialogState(() => localError = 'Código incorreto. Usa REVIVE!');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Já utilizaste o código REVIVE nesta partida. Na próxima partida poderás usá-lo novamente!',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _restartGame();
                },
                child: const Text('Jogar De Novo', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatBoostTime() {
    final m = (_boostSecsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_boostSecsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
            onPressed: _openRedeemDialog,
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
            // ── HUD (Recorde, Pontuação, Boost) ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // High Score
                  _hudBox(
                    icon: Icons.emoji_events,
                    iconColor: Colors.amber,
                    borderColor: Colors.amber,
                    text: '$highScore',
                    textColor: Colors.amber,
                  ),

                  // Boost indicator (visível apenas quando ativo) OU Indicador de Vidas
                  if (_isBoostActive)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '2x  ${_formatBoostTime()}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF231B40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hasUsedReviveThisMatch
                              ? Colors.grey.shade700
                              : Colors.pinkAccent.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hasUsedReviveThisMatch ? Icons.heart_broken : Icons.favorite,
                            color: _hasUsedReviveThisMatch ? Colors.grey : Colors.pinkAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _hasUsedReviveThisMatch ? '1 Vida' : '2 Vidas',
                            style: TextStyle(
                              color: _hasUsedReviveThisMatch ? Colors.grey : Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Current Score
                  _hudBox(
                    icon: _isBoostActive ? Icons.bolt : Icons.stars,
                    iconColor: _isBoostActive ? Colors.orange : Colors.blue,
                    borderColor: _isBoostActive ? Colors.orange : Colors.blue,
                    text: '${board.score}',
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),

            // ── Tabuleiro 8x8 ─────────────────────────────────────────────
            Center(
              child: GameBoardWidget(
                board: board,
                onPiecePlaced: _handlePiecePlaced,
                boostSecsLeft: _boostSecsLeft,
                comboStreak: _comboStreak,
              ),
            ),

            // ── Bandeja de 3 Peças Arrastáveis ────────────────────────────
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

  Widget _hudBox({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String text,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF231B40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
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
