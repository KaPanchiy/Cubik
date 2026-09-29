import 'package:flutter/material.dart';

enum PieceType { single, line2, line3, square2x2, lShape }

class Piece {
  final PieceType type;
  final Color color;
  final List<List<int>> shape; // Representa a forma da peça (1 para bloco, 0 para vazio)

  Piece({
    required this.type,
    required this.color,
    required this.shape,
  });

  // Peças pré-definidas para o jogo
  static List<Piece> get samplePieces => [
        // Bloco único (1x1)
        Piece(
          type: PieceType.single,
          color: const Color.fromARGB(255, 190, 116, 18),
          shape: [
            [1]
          ],
        ),
        // Linha de 3 blocos
        Piece(
          type: PieceType.line3,
          color: Colors.blue,
          shape: [
            [1, 1, 1]
          ],
        ),
        // Quadrado 2x2
        Piece(
          type: PieceType.square2x2,
          color: Colors.purple,
          shape: [
            [1, 1],
            [1, 1],
          ],
        ),
        // Formato em L
        Piece(
          type: PieceType.lShape,
          color: Colors.orange,
          shape: [
            [1, 0],
            [1, 0],
            [1, 1],
          ],
        ),
      ];
}