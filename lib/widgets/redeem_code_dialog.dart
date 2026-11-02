import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hidden_dashboard.dart';
import '../services/secret_code_service.dart';
import '../services/boost_service.dart';
import '../services/revive_service.dart';

class RedeemCodeDialog extends StatefulWidget {
  const RedeemCodeDialog({
    super.key,
    this.onBoostActivated,
    this.onReviveActivated,
  });

  /// Callback chamado quando o boost BLOCK2026 é ativado com sucesso.
  /// Recebe os usos restantes do dia.
  final void Function(int remainingUses)? onBoostActivated;

  /// Callback chamado quando o código REVIVE é acionado numa partida perdida.
  final VoidCallback? onReviveActivated;

  static void show(
    BuildContext context, {
    void Function(int)? onBoostActivated,
    VoidCallback? onReviveActivated,
  }) {
    showDialog(
      context: context,
      builder: (context) => RedeemCodeDialog(
        onBoostActivated: onBoostActivated,
        onReviveActivated: onReviveActivated,
      ),
    );
  }

  @override
  State<RedeemCodeDialog> createState() => _RedeemCodeDialogState();
}

class _RedeemCodeDialogState extends State<RedeemCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 1. Verificar se é o código de boost BLOCK2026
    if (BoostService.isBoostCode(code)) {
      final remaining = await BoostService.activateBoost();
      if (!mounted) return;

      if (remaining == -1) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Já usaste o boost 3 vezes hoje. Volta amanhã!';
        });
        return;
      }

      // Boost ativado com sucesso
      Navigator.of(context).pop();
      widget.onBoostActivated?.call(remaining);
      return;
    }

    // 2. Verificar se é o código de renascimento REVIVE
    if (ReviveService.isReviveCode(code)) {
      if (widget.onReviveActivated != null) {
        Navigator.of(context).pop();
        widget.onReviveActivated!();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'O código REVIVE só pode ser usado quando perderes uma partida!';
        });
      }
      return;
    }

    // 3. Verificar se é o código secreto do painel oculto
    final isValidSecret = await SecretCodeService.validateCode(code);
    if (!mounted) return;

    if (isValidSecret) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Theme(
            data: dashboardTheme,
            child: ChangeNotifierProvider<DashboardModel>(
              create: (_) => DashboardModel(),
              child: const HiddenDashboard(),
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Código inválido ou expirado. Verifica e tenta novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.orange, size: 28),
          SizedBox(width: 10),
          Text(
            'Resgatar Código',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insere o teu código promocional para resgatar bónus e recompensas do jogo!',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Ex: BLOCK2026',
                labelText: 'Código Promo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              onSubmitted: (_) => _submitCode(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : _submitCode,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Resgatar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
