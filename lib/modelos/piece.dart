import 'dart:math';
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
  diagSlash,
  diagBackslash
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

  /// Paleta de cores vibrantes pré-definidas no estilo Block Blast!
  static const List<Color> blockBlastPalette = [
    Color(0xFFFF4D4D), // Red Coral
    Color(0xFFFFB703), // Amber Gold
    Color(0xFF2196F3), // Electric Blue
    Color(0xFF00E676), // Emerald Green
    Color(0xFFAB47BC), // Neon Purple
    Color(0xFFFF9100), // Bright Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink Violet
  ];

  static Color getRandomColor() {
    final rand = Random();
    return blockBlastPalette[rand.nextInt(blockBlastPalette.length)];
  }

  /// Retorna uma lista variada de peças com cores aleatórias da paleta pré-definida
  static List<Piece> getRandomPieces(int count) {
    final rand = Random();
    final allTemplates = samplePieces;
    allTemplates.shuffle();
    
    final List<Piece> selected = [];
    for (int i = 0; i < count && i < allTemplates.length; i++) {
      final template = allTemplates[i];
      final randomColor = blockBlastPalette[rand.nextInt(blockBlastPalette.length)];
      selected.add(
        Piece(
          id: '${template.id}_${DateTime.now().microsecondsSinceEpoch}_$i',
          type: template.type,
          color: randomColor,
          shape: template.shape,
        ),
      );
    }
    return selected;
  }

  static List<Piece> get samplePieces => [
        // 1x1 Single
        Piece(
          id: 'single',
          type: PieceType.single,
          color: const Color(0xFFFF4D4D),
          shape: [
            [1]
          ],
        ),
        // 1x2 Horiz & Vert
        Piece(
          id: 'line2h',
          type: PieceType.line2H,
          color: const Color(0xFFFFB703),
          shape: [
            [1, 1]
          ],
        ),
        Piece(
          id: 'line2v',
          type: PieceType.line2V,
          color: const Color(0xFFFFB703),
          shape: [
            [1],
            [1]
          ],
        ),
        // 1x3 Horiz & Vert
        Piece(
          id: 'line3h',
          type: PieceType.line3H,
          color: const Color(0xFF2196F3),
          shape: [
            [1, 1, 1]
          ],
        ),
        Piece(
          id: 'line3v',
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
          id: 'line4h',
          type: PieceType.line4H,
          color: const Color(0xFF00E676),
          shape: [
            [1, 1, 1, 1]
          ],
        ),
        // 2x2 Square
        Piece(
          id: 'sq2',
          type: PieceType.square2x2,
          color: const Color(0xFFAB47BC),
          shape: [
            [1, 1],
            [1, 1],
          ],
        ),
        // 3x3 Square
        Piece(
          id: 'sq3',
          type: PieceType.square3x3,
          color: const Color(0xFFFF9100),
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
          color: const Color(0xFFE91E63),
          shape: [
            [1, 1, 1],
            [0, 1, 0],
          ],
        ),
        // Formato Z
        Piece(
          id: 'z_shape_1',
          type: PieceType.zShape,
          color: const Color(0xFF00BCD4),
          shape: [
            [1, 1, 0],
            [0, 1, 1],
          ],
        ),
        // Canto 2x2
        Piece(
          id: 'corner_1',
          type: PieceType.corner2x2,
          color: const Color(0xFFFFD600),
          shape: [
            [1, 1],
            [1, 0],
          ],
        ),
        Piece(
          id: 'diagSlash',
          type: PieceType.diagSlash,
          color: const Color(0xFF00E676),
          shape: [
            [0, 0, 1],
            [0, 1, 0],
            [1, 0, 0],
          ],
        ),
        Piece(
          id: 'diag_backslash',
          type: PieceType.diagBackslash,
          color: const Color(0xFFE91E63),
          shape: [
            [1, 0, 0],
            [0, 1, 0],
            [0, 0, 1],
          ],
        ),
      ];
}
