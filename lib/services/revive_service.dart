/// Serviço para validação do código de renascimento REVIVE.
/// Permite ao jogador continuar a partida após perder.
class ReviveService {
  static const String code = 'revive';

  /// Valida se o código inserido é o código de reviver (case-insensitive: 'revive' ou 'REVIVE')
  static bool isReviveCode(String input) {
    return input.trim().toLowerCase() == code;
  }
}
