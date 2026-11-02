import 'package:flutter/material.dart';
import '../modelos/incident_model.dart';
import 'diary_repository.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<IncidentEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await DiaryRepository.getEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntry(IncidentEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18243A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Ocorrência', style: TextStyle(color: Color(0xFFF1DAC4))),
        content: const Text(
          'Tem a certeza de que deseja eliminar este registo? Esta ação apagará o registo local e da nuvem.',
          style: TextStyle(color: Color(0xFFF1DAC4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF48A9A6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC86B68)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DiaryRepository.deleteEntry(entry.id);
      _loadEntries();
    }
  }

  void _openNewEntryModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Outro';
    String selectedSeverity = 'Baixa';
    DateTime selectedDate = DateTime.now();

    final categories = [
      'Agressão Verbal',
      'Agressão Física',
      'Ameaça',
      'Controlo Financeiro',
      'Isolamento Social',
      'Perseguição',
      'Outro',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18243A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Novo Registo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1DAC4),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFF1DAC4)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(primary: Color(0xFF48A9A6)),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) setModalState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF23324D),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF48A9A6), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                              style: const TextStyle(color: Color(0xFFF1DAC4), fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Color(0xFFF1DAC4)),
                      decoration: InputDecoration(
                        labelText: 'Título da Ocorrência',
                        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                        ),
                        prefixIcon: const Icon(Icons.title, color: Color(0xFF48A9A6)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: const Color(0xFF23324D),
                      style: const TextStyle(color: Color(0xFFF1DAC4)),
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                        ),
                        prefixIcon: const Icon(Icons.category, color: Color(0xFF48A9A6)),
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val ?? 'Outro'),
                    ),
                    const SizedBox(height: 16),

                    // Gravidade
                    const Text('Gravidade', style: TextStyle(color: Color(0xFF48A9A6), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _severityChip(setModalState, 'Baixa', const Color(0xFF48A9A6), selectedSeverity, (v) => selectedSeverity = v),
                        const SizedBox(width: 8),
                        _severityChip(setModalState, 'Média', Colors.orange, selectedSeverity, (v) => selectedSeverity = v),
                        const SizedBox(width: 8),
                        _severityChip(setModalState, 'Alta', const Color(0xFFC86B68), selectedSeverity, (v) => selectedSeverity = v),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFF1DAC4)),
                      decoration: InputDecoration(
                        labelText: 'Descrição do incidente (cifrada no envio)',
                        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48A9A6),
                        foregroundColor: const Color(0xFF18243A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Registo Cifrado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final entry = IncidentEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          date: selectedDate,
                          description: descController.text.trim(),
                          category: selectedCategory,
                          severity: selectedSeverity,
                        );

                        Navigator.pop(context);
                        await DiaryRepository.saveEntry(entry);
                        _loadEntries();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _severityChip(
    StateSetter setModalState,
    String value,
    Color color,
    String selected,
    Function(String) onSelected,
  ) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => onSelected(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF23324D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3), width: isSelected ? 2 : 1),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFFF1DAC4),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
      case 'elevado':
        return const Color(0xFFC86B68);
      case 'média':
      case 'medio':
        return Colors.orange;
      default:
        return const Color(0xFF48A9A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF48A9A6)))
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 72, color: const Color(0xFF48A9A6).withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum registo ainda',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no botão + para registar uma ocorrência segura',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFFF1DAC4)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final color = _severityColor(entry.severity);
                    return Card(
                      color: const Color(0xFF23324D),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.severity,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFC86B68)),
                                  tooltip: 'Eliminar registo',
                                  onPressed: () => _deleteEntry(entry),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 13, color: const Color(0xFF48A9A6).withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}',
                                  style: TextStyle(fontSize: 12, color: const Color(0xFFF1DAC4).withValues(alpha: 0.7)),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.label_outline, size: 13, color: const Color(0xFF48A9A6).withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  entry.category,
                                  style: TextStyle(fontSize: 12, color: const Color(0xFFF1DAC4).withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                            if (entry.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                entry.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, height: 1.4, color: const Color(0xFFF1DAC4).withValues(alpha: 0.85)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF48A9A6),
        foregroundColor: const Color(0xFF18243A),
        icon: const Icon(Icons.add),
        label: const Text('Registar Ocorrência', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _openNewEntryModal,
      ),
    );
  }
}
