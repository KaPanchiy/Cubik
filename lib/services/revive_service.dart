import 'game_codes.dart';

/// Serviço para validação do código de renascimento REVIVE.
/// Permite ao jogador continuar a partida após perder.
class ReviveService {
  /// Valida se o código inserido é o código de reviver (case-insensitive)
  static bool isReviveCode(String input) {
    return input.trim().toLowerCase() == GameCodes.reviveCode.toLowerCase();
  }
}
