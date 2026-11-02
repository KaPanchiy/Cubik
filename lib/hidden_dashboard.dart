import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/diary_screen.dart';
import 'services/secret_code_service.dart';

// Abre o discador nativo com o número indicado.
Future<void> _launchPhone(String number) async {
  final uri = Uri.parse('tel:$number');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

final ThemeData dashboardTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF18243A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF18243A),
    foregroundColor: Color(0xFFF1DAC4),
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFF1DAC4)),
    titleMedium: TextStyle(color: Color(0xFFF1DAC4)),
  ),
);

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
    {'icon': Icons.grid_view, 'title': 'Linhas de Apoio', 'screen': const ResourcesScreen()},
    {'icon': Icons.lock_outline, 'title': 'Alterar Código Secreto', 'screen': const ChangePinScreen()},
  ];
}

class HiddenDashboard extends StatelessWidget {
  const HiddenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardModel>(context);

    final List<Widget> bottomScreens = [
      const HomeGridViewContent(),
      const DiaryScreen(),
      const EmergencyScreen(),
    ];

    return Theme(
      data: dashboardTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Não está sozinho(a)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4))),
        ),
        body: bottomScreens[model.currentIndex],
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFC86B68),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Sair Rápido', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: model.currentIndex,
          backgroundColor: const Color(0xFF18243A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF48A9A6),
          unselectedItemColor: const Color(0xFFF1DAC4).withValues(alpha: 0.6),
          onTap: (index) => model.setIndex(index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Diário'),
            BottomNavigationBarItem(icon: Icon(Icons.phone), label: '112'),
          ],
        ),
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
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
      ),
      itemCount: model.menuItems.length,
      itemBuilder: (context, index) {
        final item = model.menuItems[index];
        return MenuCard(
          icon: item['icon'],
          title: item['title'],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Theme(
                data: dashboardTheme,
                child: item['screen'],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Cartão com Design Aprimorado (Gradiente e Sombra Suave)
class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: const LinearGradient(
          colors: [Color(0xFF23324D), Color(0xFF1C2A42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF48A9A6).withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF48A9A6).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: const Color(0xFF48A9A6)),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFFF1DAC4),
                    height: 1.2,
                  ),
                ),
              ],
            ),
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
      'description': 'A violência física é qualquer conduta que envolve o uso direto da força contra outra pessoa, atingindo a sua integridade corporal ou a sua saúde. Como uma das formas mais evidentes de agressão, pode manifestar-se de diversas maneiras, como agressões, espancamentos e socos, podendo ser também acompanhada por outras formas de violência, tais como a psicológica e a sexual.\n\nAs suas consequências vão muito além das lesões corporais, incluindo sérios danos emocionais e psicológicos que podem durar por toda a vida da vítima. Além disso, esse tipo de conduta gera importantes desdobramentos legais, podendo resultar em responsabilidades penais, civis e na concessão de medidas protetivas.',
      'help': 'Procure atendimento médico imediato se estiver ferida(o) para registo de lesões. Contacte o 112 em caso de perigo iminente ou a Linha de Apoio à Vítima (800 202 148).'
    },
    {
      'title': 'Violência Psicológica e Controlo Coercivo',
      'icon': Icons.psychology,
      'isRichDescription': true,
      'intro': 'A violência psicológica consiste em agressões sem contacto físico — como humilhações, desvalorizações e menosprezos verbais — que causam danos emocionais profundos. Embora invisível, afeta a autoestima, a razão e a capacidade de reação da vítima.',
      'bulletPoints': [
        {'title': 'Humilhações:', 'text': ' Piadas e críticas que rebaixam a vítima, mesmo quando camufladas em tom de brincadeira.'},
        {'title': 'Isolamento Social:', 'text': ' Impedir ou encorajar a vítima de se conectar com amigos, familiares ou colegas.'},
      ],
      'help': 'Registe episódios num diário seguro. Fale com pessoas de confiança e contacte a linha 800 202 148.'
    },
    {
      'title': 'Violência Financeira e Económica',
      'icon': Icons.account_balance_wallet,
      'isRichDescription': true,
      'intro': 'A violência económica consiste em qualquer comportamento que busca dominar ou subjugar a vítima, manipulando o seu acesso a recursos financeiros.',
      'bulletPoints': [
        {'title': 'Proibição de trabalhar:', 'text': ' Impedir que a vítima procure emprego, estude ou mantenha atividade profissional.'},
      ],
      'help': 'Tente guardar documentos importantes e extratos num local seguro ou digital. Procure apoio jurídico gratuito através da APAV (116 006).'
    },
    {
      'title': 'Violência Sexual',
      'icon': Icons.block,
      'isRichDescription': true,
      'intro': 'A violência sexual manifesta-se através de diferentes condutas graves que violam a liberdade e autodeterminação sexual.',
      'bulletPoints': [
        {'title': 'Coação Sexual:', 'text': 'Ocorre ao constranger a vítima a praticar atos sexuais não consentidos mediante violência ou grave ameaça.'},
      ],
      'help': 'Não tome banho nem mude de roupa se o ato foi muito recente. Dirija-se a uma urgência hospitalar.'
    },
    {
      'title': 'Stalking (Perseguição Persistente)',
      'icon': Icons.security,
      'isRichDescription': true,
      'intro': 'O stalking caracteriza-se por um padrão de comportamentos repetidos e indesejados dirigidos a uma pessoa.',
      'bulletPoints': [
        {'title': 'Presencial e Digital:', 'text': 'Vigilância constante, rondas à residência e monitorização obsessiva nas redes sociais.'},
      ],
      'help': 'Guarde todas as provas (capturas de ecrã) e reporte imediatamente às autoridades.'
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
            elevation: 2,
            color: const Color(0xFF23324D),
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: const Color(0xFF48A9A6).withValues(alpha: 0.3), width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TypeDetailScreen(
                      title: item['title'],
                      description: item['description'] ?? '',
                      isRichDescription: item['isRichDescription'] ?? false,
                      intro: item['intro'] ?? '',
                      bulletPoints: List<Map<String, String>>.from(
                        (item['bulletPoints'] ?? []).map((e) => Map<String, String>.from(e))
                      ),
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
                        color: const Color(0xFF48A9A6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], size: 32, color: const Color(0xFF48A9A6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4))),
                          const SizedBox(height: 4),
                          const Text('Toque para ver detalhes e como pedir ajuda', style: TextStyle(fontSize: 12, color: Color(0xFFF1DAC4))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF48A9A6)),
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
    required this.isRichDescription,
    required this.intro,
    required this.bulletPoints,
    required this.help,
    required this.icon,
  });

  final String title;
  final String description;
  final bool isRichDescription;
  final String intro;
  final List<Map<String, String>> bulletPoints;
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
            Center(child: Icon(icon, size: 64, color: const Color(0xFF48A9A6))),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text('O que é?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23324D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF48A9A6).withValues(alpha: 0.3)),
              ),
              child: isRichDescription
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (intro.isNotEmpty) Text(intro, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
                        if (bulletPoints.isNotEmpty) ...[
                          if (intro.isNotEmpty) const SizedBox(height: 12),
                          ...bulletPoints.map((bp) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4)),
                                    children: [
                                      const TextSpan(text: '• ', style: TextStyle(color: Color(0xFF48A9A6))),
                                      TextSpan(text: bp['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
                                      TextSpan(text: bp['text']),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ],
                    )
                  : Text(description, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ),
            const SizedBox(height: 20),
            const Text('Como pedir ajuda?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23324D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF48A9A6)),
              ),
              child: Text(help, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 2. QUESTIONÁRIO INTERATIVO (Dual: Próprio ou Amigo)
// =====================================================================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  bool? _isForMe;

  final List<String> _questionsForMe = [
    'Sente medo ou apreensão constante perante a reação ou comportamento do(a) seu(sua) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) controla com quem fala, para onde vai, as suas redes sociais ou como se veste?',
    'Sente-se isolado(a) da sua família, amigos ou colegas devido à pressão do(a) seu(sua) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) já ameaçou fazer-lhe mal, às suas crianças ou aos seus animais de estimação?',
    'O(A) seu(sua) parceiro(a) controla o seu dinheiro, nega-lhe acesso a fundos ou impede-o(a) de trabalhar?',
    'Recebe chamadas, mensagens ou perseguição constante para prestar contas de onde está a cada momento?',
    'Já existiu alguma tentativa de estrangulamento, esganamento, sufoco ou agressão física direta?',
    'Houve uma separação recente ou manifestou intenção de terminar a relação?',
  ];

  final List<String> _questionsForFriend = [
    'Nota que o(a) seu(sua) amigo(a) demonstra medo ou ansiedade constante em relação ao(à) parceiro(a)?',
    'O(A) parceiro(a) controla excessivamente os horários, as saídas, as redes sociais ou a roupa do(a) seu(sua) amigo(a)?',
    'Repara que o(a) seu(sua) amigo(a) se tem afastado progressivamente da família, amigos e do convívio social habitual?',
    'Já ouviu ou suspeita que o(a) parceiro(a) tenha feito ameaças físicas ou psicológicas ao(à) seu(sua) amigo(a)?',
    'O(A) seu(sua) amigo(a) aparenta não ter autonomia financeira ou depende totalmente do(a) parceiro(a) para despesas básicas?',
    'O(A) parceiro(a) liga ou envia mensagens obsessivamente para saber onde e com quem o(a) seu(sua) amigo(a) está?',
    'Notou marcas físicas inexplicáveis, hematomas ou alteração drástica e repentina na integridade física do(a) amigo(a)?',
    'Sabe se o(a) seu(sua) amigo(a) tentou recentemente terminar a relação e enfrentou forte resistência ou retaliação?',
  ];

  final List<bool?> _answers = List.filled(8, null);

  void _selectTarget(bool isForMe) {
    setState(() {
      _isForMe = isForMe;
      _currentQuestionIndex = 0;
      _answers.fillRange(0, _answers.length, null);
    });
  }

  void _answerQuestion(bool answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
      List<String> activeQuestions = _isForMe! ? _questionsForMe : _questionsForFriend;
      if (_currentQuestionIndex < activeQuestions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    } else {
      setState(() {
        _isForMe = null;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _isForMe = null;
      _currentQuestionIndex = 0;
      _answers.fillRange(0, _answers.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isForMe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Será violência doméstica?')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.help_outline, size: 64, color: Color(0xFF48A9A6)),
              const SizedBox(height: 24),
              const Text(
                'Para quem está a responder a este questionário?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escolha uma das opções abaixo para personalizarmos as perguntas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFFF1DAC4)),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48A9A6),
                  foregroundColor: const Color(0xFF18243A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person),
                label: const Text('A situação é comigo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => _selectTarget(true),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFF48A9A6), width: 2),
                ),
                icon: const Icon(Icons.people, color: Color(0xFF48A9A6)),
                label: const Text('É com um(a) amigo(a) / conhecido(a)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
                onPressed: () => _selectTarget(false),
              ),
            ],
          ),
        ),
      );
    }

    List<String> activeQuestions = _isForMe! ? _questionsForMe : _questionsForFriend;
    final bool isCompleted = _answers.every((element) => element != null);

    return Scaffold(
      appBar: AppBar(title: Text(_isForMe! ? 'Avaliação Pessoal' : 'Apoio a Amigo(a)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !isCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / activeQuestions.length,
                    backgroundColor: const Color(0xFF23324D),
                    color: const Color(0xFF48A9A6),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pergunta ${_currentQuestionIndex + 1} de ${activeQuestions.length}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFFF1DAC4), fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        backgroundColor: const Color(0xFF48A9A6).withValues(alpha: 0.2),
                        label: Text(
                          _isForMe! ? 'Contexto Próprio' : 'Contexto de Amizade',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF48A9A6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeQuestions[_currentQuestionIndex],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFF1DAC4)),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC86B68),
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
                      side: const BorderSide(color: Color(0xFF48A9A6)),
                    ),
                    onPressed: () => _answerQuestion(false),
                    child: const Text('NÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _previousQuestion,
                    child: const Text('Voltar / Mudar opção anterior', style: TextStyle(color: Color(0xFF48A9A6))),
                  ),
                ],
              )
            : QuizResultView(answers: _answers, isForMe: _isForMe!, onRestart: _resetQuiz),
      ),
    );
  }
}

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key, required this.answers, required this.isForMe, required this.onRestart});

  final List<bool?> answers;
  final bool isForMe;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    int simCount = answers.where((element) => element == true).length;
    bool hasHighRiskTriggers = (answers.length > 3 && answers[3] == true) || (answers.length > 6 && answers[6] == true);

    String title;
    String description;
    Color headerColor;
    IconData headerIcon;

    if (isForMe) {
      if (simCount >= 5 || hasHighRiskTriggers) {
        title = 'Indicadores Elevados (Risco Alto)';
        description = 'A sua situação apresenta indicadores claros de risco elevado. Procure ajuda especializada de imediato.';
        headerColor = const Color(0xFFC86B68);
        headerIcon = Icons.warning_amber_rounded;
      } else {
        title = 'Indicadores Moderados / Baixos';
        description = 'Existem sinais a merecer atenção. Considere conversar com uma linha de apoio de forma confidencial.';
        headerColor = const Color(0xFF48A9A6);
        headerIcon = Icons.info_outline;
      }
    } else {
      if (simCount >= 5 || hasHighRiskTriggers) {
        title = 'Alerta Máximo de Apoio a Amigo(a)';
        description = 'O seu amigo(a) pode estar numa situação de elevado perigo. Mostre disponibilidade sem julgar e encoraje o contacto com entidades especializadas.';
        headerColor = const Color(0xFFC86B68);
        headerIcon = Icons.warning_amber_rounded;
      } else {
        title = 'Atenção Necessária';
        description = 'Existem sinais de alerta na relação do seu amigo(a). Mantenha o contacto próximo e mostre apoio.';
        headerColor = const Color(0xFF48A9A6);
        headerIcon = Icons.info_outline;
      }
    }

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF23324D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: headerColor, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(headerIcon, size: 48, color: headerColor),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor)),
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFFF1DAC4))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF48A9A6),
            foregroundColor: const Color(0xFF18243A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.phone),
          label: const Text('Contactar Linha de Apoio (800 202 148)', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFF48A9A6)),
          ),
          onPressed: onRestart,
          child: const Text('Refazer Questionário', style: TextStyle(color: Color(0xFF48A9A6))),
        ),
      ],
    );
  }
}

// =====================================================================
// 3. MÓDULO DE ACONSELHAMENTO E APOIO (Completo com as 7 secções)
// =====================================================================
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> supportSections = [
      {
        'title': 'O que fazer antes de abandonar a relação?',
        'icon': Icons.description_outlined,
        'screen': const GenericDetailSubScreen(
          title: 'O que fazer antes de abandonar a relação?',
          intro: 'Planear a saída com antecedência e segurança é um passo essencial para proteger a sua integridade física e emocional.',
          subItems: [
            {'title': 'Plano de Segurança:', 'text': 'Identifique locais seguros para onde se dirigir em caso de crise e memorize contactos de emergência.'},
            {'title': 'Documentação e Dinheiro:', 'text': 'Reúna cópias de documentos de identificação essenciais e guarde algum valor monetário num local seguro.'},
          ],
        ),
      },
      {
        'title': 'O que preciso levar comigo?',
        'icon': Icons.work_outline,
        'screen': const GenericDetailSubScreen(
          title: 'O que preciso levar comigo?',
          intro: 'Em caso de saída urgente, priorize os bens absolutamente indispensáveis para si e para os seus dependentes.',
          subItems: [
            {'title': 'Itens Essenciais:', 'text': 'Documentos de identidade, cartões bancários, chaves, telemóvel e medicação crónica.'},
          ],
        ),
      },
      {
        'title': 'Quais os riscos e como posso manter-me seguro(a)?',
        'icon': Icons.warning_amber_rounded,
        'screen': const GenericDetailSubScreen(
          title: 'Quais os riscos e como posso manter-me seguro(a)?',
          intro: 'O momento da separação ou decisão de rutura pode representar um período de maior vulnerabilidade e risco.',
          subItems: [
            {'title': 'Atenção e Proteção:', 'text': 'Mantenha contactos regulares com a sua rede de apoio e acione as autoridades perante ameaças.'},
          ],
        ),
      },
      {
        'title': 'Crianças e contacto contínuo',
        'icon': Icons.family_restroom,
        'screen': const GenericDetailSubScreen(
          title: 'Crianças e contacto contínuo',
          intro: 'A salvaguarda e o bem-estar dos menores são prioridades absolutas em contextos familiares difíceis.',
          subItems: [
            {'title': 'Proteção de Menores:', 'text': 'As crianças expostas à violência doméstica são também consideradas vítimas diretas perante a lei.'},
          ],
        ),
      },
      {
        'title': 'Animais de Estimação',
        'icon': Icons.pets,
        'screen': const GenericDetailSubScreen(
          title: 'Animais de Estimação',
          intro: 'A preocupação com o bem-estar dos animais de estimação é legítima e existem redes de apoio especializadas.',
          subItems: [
            {'title': 'Acolhimento Temporário:', 'text': 'Existem associações preparadas para colaborar no acolhimento de animais de vítimas em crise.'},
          ],
        ),
      },
      {
        'title': 'O que posso fazer para me proteger quando sair de casa?',
        'icon': Icons.security,
        'screen': const GenericDetailSubScreen(
          title: 'O que posso fazer para me proteger quando sair de casa?',
          intro: 'Adote medidas preventivas para garantir a sua privacidade e segurança diária.',
          subItems: [
            {'title': 'Segurança Digital:', 'text': 'Apague o histórico relevante, altere palavras-passe e desative a geolocalização.'},
          ],
        ),
      },
      {
        'title': 'Não está sozinho(a).',
        'icon': Icons.people_outline,
        'screen': const GenericDetailSubScreen(
          title: 'Não está sozinho(a).',
          intro: 'Existem profissionais qualificados prontos a ouvi-lo(a) sem qualquer tipo de julgamento.',
          subItems: [
            {'title': 'Confidencialidade:', 'text': 'Todos os serviços de aconselhamento e linhas de apoio funcionam de forma totalmente confidencial e gratuita.'},
          ],
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Aconselhamento e Apoio')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: supportSections.length,
        itemBuilder: (context, index) {
          final section = supportSections[index];
          return Card(
            elevation: 2,
            color: const Color(0xFF23324D),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF48A9A6).withValues(alpha: 0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => section['screen']),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                child: Row(
                  children: [
                    Icon(section['icon'], color: const Color(0xFF48A9A6), size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        section['title'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF48A9A6)),
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

class GenericDetailSubScreen extends StatelessWidget {
  const GenericDetailSubScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.subItems,
  });

  final String title;
  final String intro;
  final List<Map<String, String>> subItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(intro, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFF1DAC4))),
            const SizedBox(height: 24),
            const Text('Saber Mais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
            const SizedBox(height: 12),
            ...subItems.map((item) => Card(
                  elevation: 2,
                  color: const Color(0xFF23324D),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFF48A9A6).withValues(alpha: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
                        const SizedBox(height: 6),
                        Text(item['text']!, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFFF1DAC4))),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 4. GUIA DE SEGURANÇA DIGITAL (Completo com as 7 categorias)
// =====================================================================
class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> safetySections = [
      {
        'title': 'Endereço de email',
        'icon': Icons.email_outlined,
        'screen': const GenericDetailSubScreen(
          title: 'Endereço de email',
          intro: 'Mantenha o seu e-mail seguro utilizando palavras-passe fortes e verificando os dispositivos associados.',
          subItems: [
            {'title': 'Palavras-passe:', 'text': 'Evite combinações fáceis de adivinhar e ative a verificação em dois passos.'},
          ],
        ),
      },
      {
        'title': 'Browsers',
        'icon': Icons.language,
        'screen': const GenericDetailSubScreen(
          title: 'Browsers',
          intro: 'Utilize o modo de navegação privada e limpe regularmente o histórico de pesquisa.',
          subItems: [
            {'title': 'Modo Anónimo:', 'text': 'Impede que o navegador guarde o registo das páginas visitadas.'},
          ],
        ),
      },
      {
        'title': 'Redes Sociais',
        'icon': Icons.share,
        'screen': const GenericDetailSubScreen(
          title: 'Redes Sociais',
          intro: 'Reveja as definições de privacidade e evite partilhar a localização em tempo real.',
          subItems: [
            {'title': 'Privacidade:', 'text': 'Defina perfis como privados e limite o acesso a estranhos.'},
          ],
        ),
      },
      {
        'title': 'Dispositivos Eletrónicos',
        'icon': Icons.devices,
        'screen': const GenericDetailSubScreen(
          title: 'Dispositivos Eletrónicos',
          intro: 'Proteja o seu telemóvel com códigos PIN ou biometria seguros.',
          subItems: [
            {'title': 'Bloqueio:', 'text': 'Configure o telemóvel para bloquear automaticamente após curtos períodos de inatividade.'},
          ],
        ),
      },
      {
        'title': 'Aplicações de Mensagens',
        'icon': Icons.message_outlined,
        'screen': const GenericDetailSubScreen(
          title: 'Aplicações de Mensagens',
          intro: 'Utilize aplicações com encriptação de ponta a ponta e mensagens temporárias.',
          subItems: [
            {'title': 'Mensagens Temporárias:', 'text': 'Faça com que conversas sensíveis desapareçam automaticamente.'},
          ],
        ),
      },
      {
        'title': 'Aplicações',
        'icon': Icons.apps,
        'screen': const GenericDetailSubScreen(
          title: 'Aplicações',
          intro: 'Reveja as permissões concedidas às aplicações instaladas no seu dispositivo.',
          subItems: [
            {'title': 'Permissões:', 'text': 'Desative o acesso à localização para aplicações que não o exijam.'},
          ],
        ),
      },
      {
        'title': 'Jogos',
        'icon': Icons.sports_esports,
        'screen': const GenericDetailSubScreen(
          title: 'Jogos',
          intro: 'Tenha cuidado com interações em chats de jogos online.',
          subItems: [
            {'title': 'Chat:', 'text': 'Evite partilhar informações pessoais ou rotinas em plataformas de jogos.'},
          ],
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Guia de segurança digital')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Esteja mais seguro(a) online\n\n'
              'Os perpetradores de violência doméstica podem utilizar ferramentas digitais para controlar as vítimas através de assédio ou geolocalização.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFFF1DAC4)),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Saber Mais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF48A9A6))),
          const SizedBox(height: 12),
          ...safetySections.map((section) => Card(
                elevation: 2,
                color: const Color(0xFF23324D),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF48A9A6).withValues(alpha: 0.3)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => section['screen']));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                    child: Row(
                      children: [
                        Icon(section['icon'], color: const Color(0xFF48A9A6), size: 24),
                        const SizedBox(width: 16),
                        Expanded(child: Text(section['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)))),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF48A9A6)),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// =====================================================================
// 5. ECRÃ DE LINHAS DE APOIO
// =====================================================================
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resources = [
      {
        'title': '1. Linha LGBT',
        'hours': 'Disponível de quinta a sábado, das 20:00 às 23:00',
        'phone': '218873922',
        'description': 'A Linha LGBT da associação ILGA Portugal, é uma linha telefónica de apoio e informação sobre questões LGBT.'
      },
      {
        'title': '2. SMS Segurança',
        'hours': '24 horas por dia',
        'phone': '961010200',
        'description': 'Permite às pessoas surdas enviar um SMS, sendo este comunicado verbalmente pelos operadores da GNR.'
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
        'title': '6. 112 - Número Europeu de Emergência',
        'hours': '24 horas por dia (Gratuita)',
        'phone': '112',
        'description': 'Contacto imediato para situações de perigo iminente para a vida ou integridade física.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Linhas de Apoio')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final res = resources[index];
          return Card(
            elevation: 2,
            color: const Color(0xFF23324D),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF48A9A6).withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(res['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF48A9A6))),
                  const SizedBox(height: 4),
                  Text(res['hours']!, style: const TextStyle(color: Color(0xFFF1DAC4), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(res['description']!, style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFFF1DAC4))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Color(0xFF48A9A6)),
                          const SizedBox(width: 6),
                          Text('Contacto: ${res['phone']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF48A9A6))),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48A9A6),
                          foregroundColor: const Color(0xFF18243A),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Ligar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () => _launchPhone(res['phone']!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// 6. ECRÃ DE EMERGÊNCIA
// =====================================================================
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_in_talk, size: 64, color: Color(0xFFC86B68)),
            const SizedBox(height: 16),
            const Text(
              'Emergência - 112',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF1DAC4)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Em caso de perigo imediato, ligue diretamente para as autoridades.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFFF1DAC4)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC86B68),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.call),
              label: const Text('Ligar 112 Agora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => _launchPhone('112'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 7. ALTERAR CÓDIGO SECRETO
// =====================================================================
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _message;
  bool _success = false;
  bool _loading = true;
  String _currentPin = '1234';

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadPin() async {
    final pin = await SecretCodeService.getSecretCode();
    setState(() {
      _currentPin = pin;
      _loading = false;
    });
  }

  Future<void> _changePin() async {
    if (_currentController.text.trim() != _currentPin) {
      setState(() { _message = 'Código atual incorreto.'; _success = false; });
      return;
    }
    if (_newController.text.trim().length < 4) {
      setState(() { _message = 'O novo código deve ter pelo menos 4 caracteres.'; _success = false; });
      return;
    }
    if (_newController.text.trim() != _confirmController.text.trim()) {
      setState(() { _message = 'Os códigos não coincidem.'; _success = false; });
      return;
    }
    await SecretCodeService.setSecretCode(_newController.text.trim());
    setState(() {
      _currentPin = _newController.text.trim();
      _message = 'Código alterado com sucesso!';
      _success = true;
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Código Secreto')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF48A9A6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Color(0xFF48A9A6)),
                  const SizedBox(height: 16),
                  const Text(
                    'Altere o código secreto de acesso ao painel',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFFF1DAC4)),
                  ),
                  const SizedBox(height: 32),
                  _buildField(_currentController, 'Código Atual'),
                  const SizedBox(height: 16),
                  _buildField(_newController, 'Novo Código'),
                  const SizedBox(height: 16),
                  _buildField(_confirmController, 'Confirmar Novo Código'),
                  const SizedBox(height: 24),
                  if (_message != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _success
                            ? const Color(0xFF48A9A6).withValues(alpha: 0.15)
                            : const Color(0xFFC86B68).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _success ? Icons.check_circle_outline : Icons.error_outline,
                            color: _success ? const Color(0xFF48A9A6) : const Color(0xFFC86B68),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _success ? const Color(0xFF48A9A6) : const Color(0xFFC86B68),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48A9A6),
                      foregroundColor: const Color(0xFF18243A),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _changePin,
                    child: const Text('Alterar Código', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Color(0xFFF1DAC4)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF48A9A6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF48A9A6), width: 2),
        ),
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF48A9A6)),
      ),
    );
  }
}
