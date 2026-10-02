import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<DashboardModel>(
      create: (_) => DashboardModel(),
      child: const MyApp(),
    ),
  );
}

class DashboardModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.help_outline, 'title': 'Será violência doméstica?', 'screen': const QuizScreen()},
    {'icon': Icons.list_alt, 'title': 'Tipos de Violência', 'screen': const TypesScreen()},
    {'icon': Icons.info_outline, 'title': 'Aconselhamento e Apoio', 'screen': const SupportScreen()},
    {'icon': Icons.menu_book, 'title': 'Guia de segurança digital', 'screen': const DigitalSafetyScreen()},
    {'icon': Icons.grid_view, 'title': 'Recursos Úteis', 'screen': const ResourcesScreen()},
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Painel de Apoio',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA0522D),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      home: const HiddenDashboard(),
    );
  }
}

class HiddenDashboard extends StatelessWidget {
  const HiddenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);

    // Ecrãs do menu inferior (removida a Ajuda/HelpLocationScreen, mantidos os outros 3)
    final List<Widget> bottomScreens = [
      const HomeGridViewContent(), 
      const DiaryScreen(),         
      const EmergencyScreen(),      
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Não está sozinho(a)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: bottomScreens[model.currentIndex],
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Sair Rápido', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          debugPrint('Sair rápido acionado!');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: model.currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey[600],
        onTap: (index) => model.setIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Diário'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: '112'),
        ],
      ),
    );
  }
}

class HomeGridViewContent extends StatelessWidget {
  const HomeGridViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: model.menuItems.length,
      itemBuilder: (context, index) {
        final item = model.menuItems[index];
        return MenuCard(
          icon: item['icon'],
          title: item['title'],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['screen']),
          ),
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: const Color(0xFF1565C0)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// 1. ECRÃ DE TIPOS DE VIOLÊNCIA
// =====================================================================
class TypesScreen extends StatelessWidget {
  const TypesScreen({super.key});

  final List<Map<String, dynamic>> _violenceTypes = const [
    {
      'title': 'Violência Física',
      'icon': Icons.personal_injury,
      'description': 'Envolve o uso da força corporal com intenção de ferir ou intimidar: empurrões, chapadas, pontapés, queimaduras ou estrangulamento.',
      'help': 'Procure atendimento médico imediato se estiver ferida(o) para registo de lesões. Contacte o 112 em caso de perigo iminente ou a Linha de Apoio à Vítima (800 202 148).'
    },
    {
      'title': 'Violência Psicológica e Controlo Coercivo',
      'icon': Icons.psychology,
      'description': 'Humilhações diárias, insultos, chantagem emocional, isolamento forçado e micro-gestão das suas decisões quotidianas.',
      'help': 'Registe episódios num diário seguro (pode usar a aba Diário desta app). Fale com amigos de confiança ou familiares e contacte a linha 800 202 148 para aconselhamento psicológico.'
    },
    {
      'title': 'Violência Financeira e Económica',
      'icon': Icons.account_balance_wallet,
      'description': 'Proibição de trabalhar, apropriação do seu salário, recusa em fornecer dinheiro para despesas básicas e criação de dívidas em seu nome.',
      'help': 'Tente guardar documentos importantes e extratos bancários num local seguro ou digital. Procure apoio jurídico gratuito através da APAV (116 006) ou Segurança Social.'
    },
    {
      'title': 'Violência Sexual',
      'icon': Icons.block,
      'description': 'Imposição de qualquer ato ou contacto sexual sem o seu consentimento livre e consciente, mesmo em contexto de casamento ou união de facto.',
      'help': 'Não tome banho nem mude de roupa se o ato foi muito recente, para preservação de provas. Dirija-se a uma urgência hospitalar ou ligue para a Linha SOS Mulher (808 200 175).'
    },
    {
      'title': 'Perseguição (Stalking) e Ciberassédio',
      'icon': Icons.security,
      'description': 'Monitorização do telemóvel, instalação de apps de localização, mensagens ininterruptas ou ameaça de divulgação de conteúdos íntimos.',
      'help': 'Guarde todas as provas (capturas de ecrã de mensagens, chamadas). Consulte o Guia de Segurança Digital desta app para verificar se o seu telemóvel está comprometido.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de Violência')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _violenceTypes.length,
        itemBuilder: (context, index) {
          final item = _violenceTypes[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TypeDetailScreen(
                      title: item['title'],
                      description: item['description'],
                      help: item['help'],
                      icon: item['icon'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], size: 32, color: const Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toque para ver detalhes e como pedir ajuda',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TypeDetailScreen extends StatelessWidget {
  const TypeDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.help,
    required this.icon,
  });

  final String title;
  final String description;
  final String help;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(icon, size: 64, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'O que é?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA0522D)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                description,
                style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Como pedir ajuda?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
              ),
              child: Text(
                help,
                style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 2. QUESTIONÁRIO INTERATIVO ("Será violência doméstica?")
// =====================================================================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  
  final List<String> _questions = [
    'Sente medo ou apreensão constante perante a reação ou comportamento do(a) seu(sua) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) controla com quem fala, para onde vai, as suas redes sociais ou como se veste?',
    'Sente-se isolado(a) da sua família, amigos ou colegas devido à pressão do(a) seu(sua) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) já ameaçou fazer-lhe mal, às suas crianças ou aos seus animais de estimação?',
    'O(A) seu(sua) parceiro(a) controla o seu dinheiro, nega-lhe acesso a fundos ou impede-o(a) de trabalhar?',
    'Recebe chamadas, mensagens ou perseguição constante para prestar contas de onde está a cada momento?',
    'Já existiu alguma tentativa de estrangulamento, esganamento, sufoco ou agressão física direta?',
    'Houve uma separação recente ou manifestou intenção de terminar a relação?',
  ];

  final List<bool?> _answers = List.filled(8, null);

  void _answerQuestion(bool answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.fillRange(0, _answers.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _answers.every((element) => element != null);

    return Scaffold(
      appBar: AppBar(title: const Text('Será violência doméstica?')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !isCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _questions[_currentQuestionIndex],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _answerQuestion(true),
                    child: const Text('SIM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                    ),
                    onPressed: () => _answerQuestion(false),
                    child: const Text('NÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  ),
                  const SizedBox(height: 12),
                  if (_currentQuestionIndex > 0)
                    TextButton(
                      onPressed: _previousQuestion,
                      child: const Text('Pergunta Anterior'),
                    ),
                  const Spacer(),
                ],
              )
            : QuizResultView(answers: _answers, onRestart: _resetQuiz),
      ),
    );
  }
}

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key, required this.answers, required this.onRestart});
  
  final List<bool?> answers;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    int simCount = answers.where((element) => element == true).length;
    bool hasHighRiskTriggers = (answers.length > 3 && answers[3] == true) || 
                               (answers.length > 6 && answers[6] == true);

    String title;
    String description;
    Color headerColor;
    IconData headerIcon;

    if (simCount >= 9 || hasHighRiskTriggers) {
      title = 'Indicadores Elevados (Risco Alto)';
      description = 'Sua situação apresenta risco elevado para a sua segurança. Entre em contacto imediato com uma linha de apoio ou autoridades.';
      headerColor = Colors.red.shade700;
      headerIcon = Icons.warning_amber_rounded;
    } else if (simCount >= 4) {
      title = 'Indicadores Médios';
      description = 'Existem sinais claros de controlo coercivo e risco comportamental. Aconselhamos a falar com um especialista de apoio.';
      headerColor = Colors.orange.shade800;
      headerIcon = Icons.info_outline;
    } else {
      title = 'Indicadores Baixos';
      description = 'Apesar de alguns comportamentos de alerta, continue atento(a) aos sinais de controlo e consulte o nosso guia de prevenção.';
      headerColor = Colors.green.shade700;
      headerIcon = Icons.check_circle_outline;
    }

    return ListView(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(headerIcon, size: 56, color: headerColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total de respostas "Sim": $simCount',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const Divider(height: 24),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.phone),
          label: const Text('Ligar para a Linha de Apoio (800 202 148)', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            debugPrint('Ação de ligar para a linha acionada');
          },
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onRestart,
          child: const Text('Refazer Questionário'),
        ),
      ],
    );
  }
}

// Demais Ecrãs do Menu
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Apoio')), body: const Center(child: Text('Ecrã de Aconselhamento')));
}

class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Segurança Digital')), body: const Center(child: Text('Ecrã de Segurança Digital')));
}

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resources = [
      {
        'title': '1. Linha LGBT',
        'hours': 'Disponível de quinta a sábado, das 20:00 às 23:00',
        'phone': '218873922',
        'description': 'A Linha LGBT da associação ILGA Portugal, é uma linha telefónica de apoio e informação sobre questões LGBT...'
      },
      {
        'title': '2. SMS Segurança',
        'hours': '24 horas por dia',
        'phone': '961010200',
        'description': 'Permite às pessoas surdas enviar um SMS, sendo este comunicado verbalmente pelos operadores da GNR...'
      },
      {
        'title': '3. Linha Nacional de Emergência Social',
        'hours': '24 horas por dia (Gratuita)',
        'phone': '144',
        'description': 'Garante resposta imediata a situações de atuação emergente e urgente no âmbito da proteção social.'
      },
      {
        'title': '4. Serviço de Informação às Vítimas de Violência Doméstica',
        'hours': '24 horas por dia (Gratuita)',
        'phone': '800202148',
        'description': 'Linha telefónica com profissionais especializados no atendimento a vítimas de violência doméstica.'
      },
      {
        'title': '5. Linha de Apoio à Vítima (LAV)',
        'hours': 'Segunda a sexta-feira, das 9:00 às 21:00',
        'phone': '116006',
        'description': 'Serviço de atendimento telefónico prestado pela APAV, gratuito e confidencial.'
      },
      {
        'title': '6. Linha SMS 3060: Segurança em isolamento',
        'hours': '24 horas por dia (Gratuita)',
        'phone': '800202148 / SMS: 3060',
        'description': 'Permite o envio de mensagens de texto rápidas (SMS) pelas vítimas de violência doméstica.'
      },
      {
        'title': '7. Linha SOS Mulher',
        'hours': '24 horas por dia',
        'phone': '808200175',
        'description': 'Presta apoio anónimo e confidencial a mulheres vítimas de violência conjugal.'
      },
      {
        'title': '8. 112 - Número Europeu de Emergência',
        'hours': '24 horas por dia (Gratuito)',
        'phone': '112',
        'description': 'Número de Telefone Europeu de Emergência, disponível gratuitamente.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Recursos Úteis')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final item = resources[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('Telefone: ${item['phone']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Horário: ${item['hours']}', style: const TextStyle(fontSize: 13, color: Colors.black87))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(item['description']!, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Ecrãs restantes da BottomNavigationBar
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Ecrã do Diário', style: TextStyle(fontSize: 18)));
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Ecrã de Emergência (112)', style: TextStyle(fontSize: 18)));
}