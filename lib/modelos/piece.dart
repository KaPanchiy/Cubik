import 'package:flutter/material.dart';

enum PieceType {
  single,
  line2H,
  line2V,
  line3H,
  line3V,
  line4H,
  line4V,
  square2x2,
  square3x3,
  lShape,
  lShapeRotated,
  tShape,
  zShape,
  corner2x2,
}

class Piece {
  final String id;
  final PieceType type;
  final Color color;
  final List<List<int>> shape; // 1 para bloco, 0 para espaço em branco

  Piece({
    required this.id,
    required this.type,
    required this.color,
    required this.shape,
  });

  int get rows => shape.length;
  int get columns => shape.isEmpty ? 0 : shape[0].length;

  /// Retorna uma lista variada de peças no estilo vibrante do Block Blast!
  static List<Piece> getRandomPieces(int count) {
    final all = samplePieces;
    all.shuffle();
    return all.take(count).toList();
  }

  static List<Piece> get samplePieces => [
        // 1x1 Single
        Piece(
          id: 'single_1',
          type: PieceType.single,
          color: const Color(0xFFFF4D4D), // Coral Vibrant Red
          shape: [
            [1]
          ],
        ),
        // 1x2 Horiz & Vert
        Piece(
          id: 'line2h_1',
          type: PieceType.line2H,
          color: const Color(0xFFFFB703), // Amber Gold
          shape: [
            [1, 1]
          ],
        ),
        Piece(
          id: 'line2v_1',
          type: PieceType.line2V,
          color: const Color(0xFFFFB703),
          shape: [
            [1],
            [1]
          ],
        ),
        // 1x3 Horiz & Vert
        Piece(
          id: 'line3h_1',
          type: PieceType.line3H,
          color: const Color(0xFF2196F3), // Bright Electric Blue
          shape: [
            [1, 1, 1]
          ],
        ),
        Piece(
          id: 'line3v_1',
          type: PieceType.line3V,
          color: const Color(0xFF2196F3),
          shape: [
            [1],
            [1],
            [1]
          ],
        ),
        // 1x4 Line
        Piece(
          id: 'line4h_1',
          type: PieceType.line4H,
          color: const Color(0xFF00E676), // Emerald Green
          shape: [
            [1, 1, 1, 1]
          ],
        ),
        // 2x2 Square
        Piece(
          id: 'sq2_1',
          type: PieceType.square2x2,
          color: const Color(0xFFAB47BC), // Purple Neon
          shape: [
            [1, 1],
            [1, 1],
          ],
        ),
        // 3x3 Square
        Piece(
          id: 'sq3_1',
          type: PieceType.square3x3,
          color: const Color(0xFFFF9100), // Bright Orange
          shape: [
            [1, 1, 1],
            [1, 1, 1],
            [1, 1, 1],
          ],
        ),
        // Formato em L
        Piece(
          id: 'l_shape_1',
          type: PieceType.lShape,
          color: const Color(0xFFFF9100),
          shape: [
            [1, 0],
            [1, 0],
            [1, 1],
          ],
        ),
        Piece(
          id: 'l_shape_2',
          type: PieceType.lShapeRotated,
          color: const Color(0xFF00E676),
          shape: [
            [1, 1, 1],
            [1, 0, 0],
          ],
        ),
        // Formato em T
        Piece(
          id: 't_shape_1',
          type: PieceType.tShape,
          color: const Color(0xFFE91E63), // Pink Violet
          shape: [
            [1, 1, 1],
            [0, 1, 0],
          ],
        ),
        // Formato Z
        Piece(
          id: 'z_shape_1',
          type: PieceType.zShape,
          color: const Color(0xFF00BCD4), // Cyan Blue
          shape: [
            [1, 1, 0],
            [0, 1, 1],
          ],
        ),
        // Canto 2x2
        Piece(
          id: 'corner_1',
          type: PieceType.corner2x2,
          color: const Color(0xFFFFD600), // Bright Yellow
          shape: [
            [1, 1],
            [1, 0],
          ],
        ),
      ];
}