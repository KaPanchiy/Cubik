import 'package:flutter/material.dart';
import 'piece.dart';

class Board {
  static const int rows = 8;
  static const int columns = 8;

  // Grelha 8x8: guarda a cor do bloco ou null se estiver vazio
  List<List<Color?>> grid = List.generate(
    rows,
    (_) => List.generate(columns, (_) => null),
  );

  int score = 0;

  void reset() {
    grid = List.generate(
      rows,
      (_) => List.generate(columns, (_) => null),
    );
    score = 0;
  }

  // Verifica se a peça pode ser colocada numa determinada posição (row, col)
  bool canPlacePiece(Piece piece, int startRow, int startCol) {
    if (startRow < 0 || startCol < 0) return false;
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 1) {
          int targetRow = startRow + r;
          int targetCol = startCol + c;

          // Fora dos limites do tabuleiro
          if (targetRow >= rows || targetCol >= columns) return false;

          // Posição já ocupada por outro bloco
          if (grid[targetRow][targetCol] != null) return false;
        }
      }
    }
    return true;
  }

  // Verifica se uma determinada peça cabe em QUALQUER posição do tabuleiro 8x8
  bool canPlaceSomewhere(Piece piece) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (canPlacePiece(piece, r, c)) {
          return true;
        }
      }
    }
    return false;
  }

  // Verifica se pelo menos UMA das peças disponíveis cabe no tabuleiro
  bool canPlaceAnyPiece(List<Piece> availablePieces) {
    if (availablePieces.isEmpty) return true;
    for (var piece in availablePieces) {
      if (canPlaceSomewhere(piece)) {
        return true;
      }
    }
    return false;
  }

  // Coloca a peça na grelha e verifica se há linhas/colunas para eliminar
  int placePiece(Piece piece, int startRow, int startCol) {
    if (!canPlacePiece(piece, startRow, startCol)) return 0;

    int blocksPlaced = 0;
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 1) {
          grid[startRow + r][startCol + c] = piece.color;
          blocksPlaced++;
        }
      }
    }

    // Pontos base pela colocação de blocos
    score += blocksPlaced;

    int clearedLines = _clearLinesAndColumns();
    return clearedLines;
  }

  // Limpa as linhas e colunas completamente cheias e atualiza a pontuação com combo
  int _clearLinesAndColumns() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    // Verificar linhas cheias
    for (int r = 0; r < rows; r++) {
      if (grid[r].every((cell) => cell != null)) {
        rowsToClear.add(r);
      }
    }

    // Verificar colunas cheias
    for (int c = 0; c < columns; c++) {
      bool isFull = true;
      for (int r = 0; r < rows; r++) {
        if (grid[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) colsToClear.add(c);
    }

    // Eliminar blocos das linhas cheias
    for (int r in rowsToClear) {
      for (int c = 0; c < columns; c++) {
        grid[r][c] = null;
      }
    }

    // Eliminar blocos das colunas cheias
    for (int c in colsToClear) {
      for (int r = 0; r < rows; r++) {
        grid[r][c] = null;
      }
    }

    int clearedCount = rowsToClear.length + colsToClear.length;
    if (clearedCount > 0) {
      // Bónus de Combo (1 linha = 10, 2 linhas = 30, 3 linhas = 60, etc.)
      int pointsEarned = clearedCount * 10 + (clearedCount - 1) * 10;
      score += pointsEarned;
    }

    return clearedCount;
  }
}