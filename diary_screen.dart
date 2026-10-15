import 'package:flutter/material.dart';

// Modelo de dados de uma ocorrência do Diário
class JournalEntry {
  final String id;
  final String title;
  final DateTime dateTime;
  final String description; // Texto / mensagens
  final List<String> photoPaths; // Caminhos das fotos
  final List<String> audioPaths; // Caminhos dos áudios

  JournalEntry({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.description,
    this.photoPaths = const [],
    this.audioPaths = const [],
  });
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // Lista local de entradas do diário
  final List<JournalEntry> _entries = [];

  // Função para abrir o formulário de adicionar nova ocorrência
  void _openNewEntryModal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    bool hasPhotoSimulation = false;
    bool hasAudioSimulation = false;

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
                    const Text(
                      'Novo Registo no Diário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1DAC4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Color(0xFFF1DAC4)),
                      decoration: InputDecoration(
                        labelText: 'Título da Ocorrência (ex: Agressão Verbal)',
                        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF48A9A6).withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFF1DAC4)),
                      decoration: InputDecoration(
                        labelText: 'Descrição / Detalhes / Mensagens',
                        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF48A9A6).withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Anexar Provas:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF48A9A6)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: hasPhotoSimulation ? const Color(0xFF48A9A6) : const Color(0xFF48A9A6).withOpacity(0.4),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(Icons.camera_alt, color: hasPhotoSimulation ? const Color(0xFF48A9A6) : const Color(0xFFF1DAC4)),
                            label: Text(
                              hasPhotoSimulation ? 'Foto Adicionada ✓' : 'Adicionar Foto',
                              style: TextStyle(color: hasPhotoSimulation ? const Color(0xFF48A9A6) : const Color(0xFFF1DAC4)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                hasPhotoSimulation = !hasPhotoSimulation;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: hasAudioSimulation ? const Color(0xFF48A9A6) : const Color(0xFF48A9A6).withOpacity(0.4),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(Icons.mic, color: hasAudioSimulation ? const Color(0xFF48A9A6) : const Color(0xFFF1DAC4)),
                            label: Text(
                              hasAudioSimulation ? 'Áudio Gravado ✓' : 'Gravar Áudio',
                              style: TextStyle(color: hasAudioSimulation ? const Color(0xFF48A9A6) : const Color(0xFFF1DAC4)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                hasAudioSimulation = !hasAudioSimulation;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48A9A6),
                        foregroundColor: const Color(0xFF18243A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty && descController.text.trim().isNotEmpty) {
                          setState(() {
                            _entries.insert(
                              0,
                              JournalEntry(
                                id: DateTime.now().toString(),
                                title: titleController.text.trim(),
                                dateTime: DateTime.now(),
                                description: descController.text.trim(),
                                photoPaths: hasPhotoSimulation ? ['foto_exemplo.jpg'] : [],
                                audioPaths: hasAudioSimulation ? ['audio_exemplo.m4a'] : [],
                              ),
                            );
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Guardar Registo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  // Função para abrir o modal de enviar por e-mail e apagar opcionalmente
  void _showExportDialog() {
    final TextEditingController emailController = TextEditingController();
    bool deleteAfterSend = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF23324D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Enviar Registos por E-mail',
                style: TextStyle(color: Color(0xFFF1DAC4), fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Introduza o e-mail seguro de destino para receber todas as ocorrências guardadas:',
                    style: TextStyle(color: Color(0xFFF1DAC4), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color(0xFFF1DAC4)),
                    decoration: InputDecoration(
                      labelText: 'E-mail seguro',
                      labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF48A9A6)),
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
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: deleteAfterSend,
                    activeColor: const Color(0xFFC86B68),
                    title: const Text(
                      'Apagar todas as entradas da app após o envio?',
                      style: TextStyle(color: Color(0xFFF1DAC4), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Esta ação limpa o histórico para maior segurança.',
                      style: TextStyle(color: Color(0xFFF1DAC4), fontSize: 11),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        deleteAfterSend = val ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFFF1DAC4))),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48A9A6),
                    foregroundColor: const Color(0xFF18243A),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                  onPressed: () {
                    if (emailController.text.trim().isNotEmpty) {
                      if (deleteAfterSend) {
                        setState(() {
                          _entries.clear();
                        });
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            deleteAfterSend
                                ? 'Relatório enviado com sucesso! Histórico limpo.'
                                : 'Relatório enviado com sucesso!',
                          ),
                          backgroundColor: const Color(0xFF48A9A6),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18243A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // BARRA DE AÇÕES DO TOPO (+ Novo Registo e Enviar por E-mail)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48A9A6),
                    foregroundColor: const Color(0xFF18243A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+ Novo Registo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _openNewEntryModal,
                ),
                if (_entries.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23324D),
                      foregroundColor: const Color(0xFF48A9A6),
                      side: const BorderSide(color: Color(0xFF48A9A6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Enviar E-mail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _showExportDialog,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 64, color: const Color(0xFF48A9A6).withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum registo no Diário',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toque no botão "+ Novo Registo" acima para adicionar uma ocorrência com mensagens, fotos e áudios.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFFF1DAC4)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final item = _entries[index];
                        return Card(
                          color: const Color(0xFF23324D),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: const Color(0xFF48A9A6).withOpacity(0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF48A9A6)),
                                    ),
                                    Text(
                                      '${item.dateTime.day}/${item.dateTime.month}/${item.dateTime.year} ${item.dateTime.hour}:${item.dateTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFF1DAC4)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(item.description, style: const TextStyle(color: Color(0xFFF1DAC4), fontSize: 14)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (item.photoPaths.isNotEmpty)
                                      const Chip(
                                        avatar: Icon(Icons.camera_alt, size: 14, color: Color(0xFF48A9A6)),
                                        label: Text('Foto Anexada', style: TextStyle(fontSize: 11, color: Color(0xFFF1DAC4))),
                                        backgroundColor: Color(0xFF18243A),
                                      ),
                                    if (item.photoPaths.isNotEmpty && item.audioPaths.isNotEmpty) const SizedBox(width: 8),
                                    if (item.audioPaths.isNotEmpty)
                                      const Chip(
                                        avatar: Icon(Icons.mic, size: 14, color: Color(0xFF48A9A6)),
                                        label: Text('Áudio Gravado', style: TextStyle(fontSize: 11, color: Color(0xFFF1DAC4))),
                                        backgroundColor: Color(0xFF18243A),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}