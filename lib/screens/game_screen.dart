import 'package:flutter/material.dart';
import '../modelos/board.dart';
import '../modelos/piece.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Board board = Board();
  List<Piece> availablePieces = Piece.samplePieces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Blast'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                board.grid = List.generate(
                  Board.rows,
                  (_) => List.generate(Board.columns, (_) => null),
                );
                board.score = 0;
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Painel de Pontuação
          Text(
            'Pontuação: ${board.score}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          // Tabuleiro 8x8
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 320,
                height: 320,
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
                    Color? cellColor = board.grid[row][col];

                    return GestureDetector(
                      onTap: () {
                        // Teste: coloca a primeira peça disponível ao clicar no tabuleiro
                        if (availablePieces.isNotEmpty) {
                          setState(() {
                            board.placePiece(availablePieces[0], row, col);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cellColor ?? Colors.grey[900],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Área com as peças disponíveis para jogar
          Column(
            children: [
              const Text(
                'Peças Disponíveis:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availablePieces.map((piece) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: piece.shape.map((row) {
                        return Row(
                          children: row.map((block) {
                            return Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: block == 1 ? piece.color : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}