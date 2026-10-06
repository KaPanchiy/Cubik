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

class _GameBoardWidgetState extends State<GameBoardWidget> {
  int? _hoverRow;
  int? _hoverCol;
  Piece? _hoverPiece;

  @override
  Widget build(BuildContext context) {
    const double boardSize = 320.0;
    const double cellSize = (boardSize - 16) / 8; // 8x8 grid with padding

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

          // Verifica se esta célula deve mostrar pré-visualização ao arrastar
          bool isHovered = false;
          Color? previewColor;

          if (_hoverPiece != null && _hoverRow != null && _hoverCol != null) {
            int rOffset = row - _hoverRow!;
            int cOffset = col - _hoverCol!;
            if (rOffset >= 0 &&
                rOffset < _hoverPiece!.rows &&
                cOffset >= 0 &&
                cOffset < _hoverPiece!.columns) {
              if (_hoverPiece!.shape[rOffset][cOffset] == 1) {
                if (widget.board.canPlacePiece(_hoverPiece!, _hoverRow!, _hoverCol!)) {
                  isHovered = true;
                  previewColor = _hoverPiece!.color.withValues(alpha: 0.45);
                }
              }
            }
          }

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
              setState(() {
                _hoverRow = null;
                _hoverCol = null;
                _hoverPiece = null;
              });
              widget.onPiecePlaced(details.data, row, col);
            },
            builder: (context, candidateData, rejectedData) {
              return _buildCell(
                color: cellColor,
                isHovered: isHovered,
                previewColor: previewColor,
                size: cellSize,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCell({
    required Color? color,
    required bool isHovered,
    required Color? previewColor,
    required double size,
  }) {
    if (color != null) {
      // Bloco preenchido estilo Block Blast (3D brilhante com gradiente)
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

    if (isHovered && previewColor != null) {
      // Célula destacada na pré-visualização
      return Container(
        decoration: BoxDecoration(
          color: previewColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }

    // Célula vazia (ranhura escura 3D)
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
