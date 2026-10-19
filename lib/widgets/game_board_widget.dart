import 'package:flutter/material.dart';
import '../modelos/board.dart';
import '../modelos/piece.dart';

class GameBoardWidget extends StatefulWidget {
  final Board board;
  final Function(Piece piece, int row, int col) onPiecePlaced;

  const GameBoardWidget({
    super.key,
    required this.board,
    required this.onPiecePlaced,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget>
    with TickerProviderStateMixin {
  int? _hoverRow;
  int? _hoverCol;
  Piece? _hoverPiece;

  // Animação para colocar peça (Placement Pop)
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  Set<int> _recentlyPlacedIndices = {};

  // Animação para eliminação de linha (Line Clear Flash)
  late AnimationController _clearController;
  late Animation<double> _clearAnimation;
  Set<int> _clearingIndices = {};

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _popAnimation = Tween<double>(begin: 1.18, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOutBack),
    );

    _clearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _clearAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _clearController, curve: Curves.easeInBack),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    _clearController.dispose();
    super.dispose();
  }

  void _triggerPlacementPop(Set<int> indices) {
    setState(() {
      _recentlyPlacedIndices = indices;
    });
    _popController.forward(from: 0.0);
  }

  void triggerLineClearAnimation(Set<int> indices, VoidCallback onComplete) {
    setState(() {
      _clearingIndices = indices;
    });
    _clearController.forward(from: 0.0).then((_) {
      setState(() {
        _clearingIndices = {};
      });
      onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double boardSize = 320.0;

    // Calcular se o hover atual vai completar alguma linha ou coluna inteira
    List<int> completableRows = [];
    List<int> completableCols = [];

    if (_hoverPiece != null && _hoverRow != null && _hoverCol != null) {
      final res = widget.board.getCompletableLines(
        _hoverPiece!,
        _hoverRow!,
        _hoverCol!,
      );
      completableRows = res.rows;
      completableCols = res.cols;
    }

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF231B40), // Dark Block Blast purple
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFF3B2E68), width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: Board.rows * Board.columns,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Board.columns,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ Board.columns;
          int col = index % Board.columns;
          Color? cellColor = widget.board.grid[row][col];

          bool isPieceHoverSlot = false;
          Color? hoverPieceColor;

          if (_hoverPiece != null && _hoverRow != null && _hoverCol != null) {
            int rOffset = row - _hoverRow!;
            int cOffset = col - _hoverCol!;
            if (rOffset >= 0 &&
                rOffset < _hoverPiece!.rows &&
                cOffset >= 0 &&
                cOffset < _hoverPiece!.columns) {
              if (_hoverPiece!.shape[rOffset][cOffset] == 1) {
                if (widget.board.canPlacePiece(_hoverPiece!, _hoverRow!, _hoverCol!)) {
                  isPieceHoverSlot = true;
                  hoverPieceColor = _hoverPiece!.color;
                }
              }
            }
          }

          // Verifica se a célula faz parte de uma LINHA ou COLUNA COMPLETADA pelo hover
          bool isLineCompletionHighlight = (completableRows.contains(row) ||
                  completableCols.contains(col)) &&
              (_hoverPiece != null);

          // Verifica se a célula está em animação de eliminação ou colocação
          bool isClearing = _clearingIndices.contains(index);
          bool isPop = _recentlyPlacedIndices.contains(index);

          return DragTarget<Piece>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _hoverRow = row;
                _hoverCol = col;
                _hoverPiece = details.data;
              });
              return widget.board.canPlacePiece(details.data, row, col);
            },
            onLeave: (data) {
              setState(() {
                _hoverRow = null;
                _hoverCol = null;
                _hoverPiece = null;
              });
            },
            onAcceptWithDetails: (details) {
              // 1. Calcular índices da peça colocada (para o efeito Pop)
              final placedIndices = <int>{};
              for (int r = 0; r < details.data.rows; r++) {
                for (int c = 0; c < details.data.columns; c++) {
                  if (details.data.shape[r][c] == 1) {
                    placedIndices.add((row + r) * Board.columns + (col + c));
                  }
                }
              }

              // 2. Verificar se esta colocação vai LIMPAR linhas/colunas
              final completable = widget.board.getCompletableLines(details.data, row, col);
              final clearIndices = <int>{};

              for (int r in completable.rows) {
                for (int c = 0; c < Board.columns; c++) {
                  clearIndices.add(r * Board.columns + c);
                }
              }
              for (int c in completable.cols) {
                for (int r = 0; r < Board.rows; r++) {
                  clearIndices.add(r * Board.columns + c);
                }
              }

              setState(() {
                _hoverRow = null;
                _hoverCol = null;
                _hoverPiece = null;
              });

              _triggerPlacementPop(placedIndices);

              if (clearIndices.isNotEmpty) {
                // Ativar animação de explosão antes de esvaziar as linhas
                triggerLineClearAnimation(clearIndices, () {
                  widget.onPiecePlaced(details.data, row, col);
                });
              } else {
                widget.onPiecePlaced(details.data, row, col);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedBuilder(
                animation: Listenable.merge([_popAnimation, _clearAnimation]),
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;

                  if (isPop) {
                    scale = _popAnimation.value;
                  }
                  if (isClearing) {
                    scale = _clearAnimation.value.clamp(0.0, 1.0);
                    opacity = _clearAnimation.value.clamp(0.0, 1.0);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: _buildCell(
                        color: cellColor,
                        isPieceHoverSlot: isPieceHoverSlot,
                        isLineCompletionHighlight: isLineCompletionHighlight,
                        hoverPieceColor: hoverPieceColor ?? _hoverPiece?.color,
                        isClearing: isClearing,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCell({
    required Color? color,
    required bool isPieceHoverSlot,
    required bool isLineCompletionHighlight,
    required Color? hoverPieceColor,
    required bool isClearing,
  }) {
    // 1. Célula a ser eliminada (Efeito de Explosão/Flash)
    if (isClearing) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Colors.white, blurRadius: 12, spreadRadius: 3),
          ],
        ),
      );
    }

    // 2. Célula pertencente a uma LINHA/COLUNA QUE SERÁ COMPLETADA no Hover
    if (isLineCompletionHighlight && hoverPieceColor != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [
              hoverPieceColor.withValues(alpha: 0.95),
              hoverPieceColor,
              Color.lerp(hoverPieceColor, Colors.white, 0.4)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: hoverPieceColor.withValues(alpha: 0.85),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    // 3. Pré-visualização da Peça a Encaixar (Hover translúcido)
    if (isPieceHoverSlot && hoverPieceColor != null) {
      return Container(
        decoration: BoxDecoration(
          color: hoverPieceColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        ),
      );
    }

    // 4. Bloco Preenchido na Grelha (Visual 3D Block Blast)
    if (color != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.95),
              color,
              Color.lerp(color, Colors.black, 0.25)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Color.lerp(color, Colors.white, 0.4)!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    // 5. Célula Vazia (Ranhura escura 3D)
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E2452),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF1E1738),
          width: 1,
        ),
      ),
    );
  }
}
