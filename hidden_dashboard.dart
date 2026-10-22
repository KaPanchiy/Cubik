import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'diary_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cubik - Painel de Apoio',
      theme: ThemeData(
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

    final List<Widget> bottomScreens = [
      const HomeGridViewContent(),
      const DiaryScreen(),
      const EmergencyScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubik - Não está sozinho(a)',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF1DAC4))),
      ),
      body: bottomScreens[model.currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC86B68),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Sair Rápido',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sair Rápido ativado! A fechar o painel...'),
              backgroundColor: Color(0xFFC86B68),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: model.currentIndex,
        backgroundColor: const Color(0xFF18243A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF48A9A6),
        unselectedItemColor: const Color(0xFFF1DAC4).withOpacity(0.6),
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
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.help_outline,
        'title': 'Será violência doméstica?',
        'screen': const QuizScreen()
      },
      {
        'icon': Icons.list_alt,
        'title': 'Tipos de Violência',
        'screen': const TypesScreen()
      },
      {
        'icon': Icons.info_outline,
        'title': 'Aconselhamento e Apoio',
        'screen': const SupportScreen()
      },
      {
        'icon': Icons.menu_book,
        'title': 'Guia de segurança digital',
        'screen': const DigitalSafetyScreen()
      },
      {
        'icon': Icons.grid_view,
        'title': 'Linhas de Apoio',
        'screen': const ResourcesScreen()
      },
      {
        'icon': Icons.vpn_key_outlined,
        'title': 'Código de Resgate',
        'screen': const CodeSettingsScreen()
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
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

  const MenuCard(
      {super.key, required this.icon, required this.title, required this.onTap});

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
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF48A9A6).withOpacity(0.3),
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
                    color: const Color(0xFF48A9A6).withOpacity(0.12),
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
// 1. TIPOS DE VIOLÊNCIA
// =====================================================================
class TypesScreen extends StatelessWidget {
  const TypesScreen({super.key});

  final List<Map<String, dynamic>> _violenceTypes = const [
    {
      'title': 'Violência Física',
      'icon': Icons.personal_injury,
      'description':
          'A violência física é qualquer conduta que envolve o uso direto da força contra outra pessoa, atingindo a sua integridade corporal ou a sua saúde. Como uma das formas mais evidentes de agressão, pode manifestar-se de diversas maneiras, como agressões, espancamentos e socos, podendo ser também acompanhada por outras formas de violência, tais como a psicológica e a sexual.\n\nAs suas consequências vão muito além das lesões corporais, incluindo sérios danos emocionais e psicológicos que podem durar por toda a vida da vítima. Além disso, esse tipo de conduta gera importantes desdobramentos legais, podendo resultar em responsabilidades penais, civis e na concessão de medidas protetivas.',
      'help':
          'Procure atendimento médico imediato se estiver ferida(o) para registo de lesões. Contacte o 112 em caso de perigo iminente ou a Linha de Apoio à Vítima (800 202 148).'
    },
    {
      'title': 'Violência Psicológica e Controlo Coercivo',
      'icon': Icons.psychology,
      'description':
          'A violência psicológica consiste em agressões sem contacto físico — como humilhações, desvalorizações e menosprezos verbais — que causam danos emocionais profundos. Embora invisível, afeta profundamente a autoestima, a autonomia e a capacidade de reação da vítima.\n\nEnvolve táticas sistemáticas de controlo coercivo, isolamento social face a familiares e amigos, e ameaças constantes que geram um clima de medo permanente.',
      'help':
          'Registe episódios num diário seguro. Fale com pessoas de confiança e contacte a linha especializada 800 202 148.'
    },
    {
      'title': 'Violência Financeira e Económica',
      'icon': Icons.account_balance_wallet,
      'description':
          'A violência económica e financeira engloba qualquer comportamento que visa dominar a vítima através da restrição ou manipulação do seu acesso a recursos económicos. Inclui a proibição de trabalhar ou estudar, o controlo total dos rendimentos e a ocultação de informação financeira.\n\nEsta forma de controlo priva a pessoa de independência, dificultando imenso a sua capacidade de se afastar do contexto abusivo.',
      'help':
          'Tente guardar cópias de documentos e comprovativos financeiros num local seguro ou digital. Procure aconselhamento jurídico gratuito através da APAV (116 006).'
    },
    {
      'title': 'Violência Sexual',
      'icon': Icons.block,
      'description':
          'A violência sexual manifesta-se através de qualquer ato sexual não consentido, coação, imposição de práticas sexuais indesejadas ou comentários desrespeitosos de cariz sexual, obtidos mediante força, ameaça ou aproveitamento de vulnerabilidade.\n\nConstitui uma grave violação dos direitos fundamentais, da dignidade e da autodeterminação pessoal da vítima.',
      'help':
          'Se a agressão foi recente, evite tomar banho ou alterar vestuário para preservar eventuais vestígios. Dirija-se de imediato a uma urgência hospitalar e contacte as autoridades.'
    },
    {
      'title': 'Stalking (Perseguição Persistente)',
      'icon': Icons.security,
      'description':
          'O stalking caracteriza-se por um padrão repetido e indesejado de condutas persecutórias, tais como vigilância constante, monitorização obsessiva de movimentos, rondas à residência ou local de trabalho, e envio maciço de mensagens.\n\nEste comportamento invasivo gera na vítima um sentimento contínuo de insegurança, medo e ansiedade extrema face à sua privacidade.',
      'help':
          'Guarde todas as provas digitais (capturas de ecrã, registos de chamadas e mensagens) e apresente denúncia imediata às autoridades policiais.'
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
              side: BorderSide(
                  color: const Color(0xFF48A9A6).withOpacity(0.3), width: 1),
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
                        color: const Color(0xFF48A9A6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'],
                          size: 32, color: const Color(0xFF48A9A6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF1DAC4))),
                          const SizedBox(height: 4),
                          const Text('Toque para ver detalhes e orientações',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFF1DAC4))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Color(0xFF48A9A6)),
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
  final String title;
  final String description;
  final String help;
  final IconData icon;

  const TypeDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.help,
    required this.icon,
  });

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
            Text(title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1DAC4)),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text('O que é?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF48A9A6))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23324D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF48A9A6).withOpacity(0.3)),
              ),
              child: Text(description,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ),
            const SizedBox(height: 20),
            const Text('Como pedir ajuda?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF48A9A6))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23324D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF48A9A6)),
              ),
              child: Text(help,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 2. QUESTIONÁRIO
// =====================================================================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool? _isForMe;
  int _currentQuestionIndex = 0;
  final List<bool?> _answers = List.filled(8, null);

  final List<String> _questionsForMe = [
    'Sente medo ou apreensão constante perante a reação do(a) seu(sua) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) controla com quem fala, redes sociais ou como se veste?',
    'Sente-se isolado(a) da sua família ou amigos devido à pressão do(a) parceiro(a)?',
    'O(A) seu(sua) parceiro(a) já ameaçou fazer-lhe mal, às crianças ou animais?',
    'O(A) seu(sua) parceiro(a) controla o seu dinheiro ou impede-o(a) de trabalhar?',
    'Recebe chamadas ou mensagens obsessivas para prestar contas de onde está?',
    'Já existiu alguma tentativa de estrangulamento ou agressão física direta?',
    'Houve uma separação recente e enfrentou forte resistência ou ameaças?'
  ];

  final List<String> _questionsForFriend = [
    'Nota que o(a) seu(sua) amigo(a) demonstra medo constante do(a) parceiro(a)?',
    'O(A) parceiro(a) controla os horários, saídas ou redes sociais do(a) seu(sua) amigo(a)?',
    'Repara que o(a) amigo(a) se tem afastado da família e amigos habituais?',
    'Já ouviu ou suspeita que o(a) parceiro(a) fez ameaças físicas ao(à) amigo(a)?',
    'O(A) seu(sua) amigo(a) aparenta não ter qualquer autonomia financeira?',
    'O(A) parceiro(a) envia mensagens obsessivamente para controlar o(a) amigo(a)?',
    'Notou marcas físicas inexplicáveis ou hematomas no(a) seu(sua) amigo(a)?',
    'Sabe se o(a) amigo(a) tentou terminar a relação e enfrentou perigo?'
  ];

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
              const Text('Para quem está a responder a este questionário?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1DAC4))),
              const SizedBox(height: 36),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48A9A6),
                    foregroundColor: const Color(0xFF18243A),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () => setState(() => _isForMe = true),
                child: const Text('A situação é comigo',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF48A9A6), width: 2)),
                onPressed: () => setState(() => _isForMe = false),
                child: const Text('É com um(a) amigo(a) / conhecido(a)',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1DAC4))),
              ),
            ],
          ),
        ),
      );
    }

    final List<String> activeQuestions =
        _isForMe! ? _questionsForMe : _questionsForFriend;
    bool isCompleted = _answers.every((a) => a != null);

    return Scaffold(
      appBar: AppBar(
          title: Text(_isForMe! ? 'Avaliação Pessoal' : 'Apoio a Amigo(a)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !isCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      'Pergunta ${_currentQuestionIndex + 1} de ${activeQuestions.length}',
                      style: const TextStyle(
                          color: Color(0xFF48A9A6),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(activeQuestions[_currentQuestionIndex],
                      style: const TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          color: Color(0xFFF1DAC4))),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF23324D),
                      foregroundColor: const Color(0xFFF1DAC4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                          color: Color(0xFF48A9A6), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _answers[_currentQuestionIndex] = true;
                        if (_currentQuestionIndex < activeQuestions.length - 1) {
                          _currentQuestionIndex++;
                        }
                      });
                    },
                    child: const Text('SIM',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1DAC4))),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF23324D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                          color: Color(0xFF48A9A6), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _answers[_currentQuestionIndex] = false;
                        if (_currentQuestionIndex < activeQuestions.length - 1) {
                          _currentQuestionIndex++;
                        }
                      });
                    },
                    child: const Text('NÃO',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1DAC4))),
                  ),
                ],
              )
            : QuizResultView(
                answers: _answers,
                isForMe: _isForMe!,
                onRestart: () {
                  setState(() {
                    _isForMe = null;
                    _currentQuestionIndex = 0;
                    _answers.fillRange(0, _answers.length, null);
                  });
                },
              ),
      ),
    );
  }
}

class QuizResultView extends StatelessWidget {
  const QuizResultView(
      {super.key,
      required this.answers,
      required this.isForMe,
      required this.onRestart});

  final List<bool?> answers;
  final bool isForMe;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    int simCount = answers.where((a) => a == true).length;
    bool highRisk = simCount >= 4 ||
        (answers.length > 3 && answers[3] == true) ||
        (answers.length > 6 && answers[6] == true);

    String title = isForMe
        ? (highRisk
            ? 'Indicadores Elevados (Risco Alto)'
            : 'Indicadores Moderados')
        : (highRisk
            ? 'Alerta Máximo de Apoio a Amigo(a)'
            : 'Atenção Necessária');
    String description = isForMe
        ? (highRisk
            ? 'A sua situação apresenta indicadores claros de risco elevado. Contacte a linha de apoio ou autoridades imediatamente.'
            : 'Existem sinais que merecem atenção. Considere conversar de forma confidencial com uma linha especializada.')
        : (highRisk
            ? 'O(A) seu(sua) amigo(a) aparenta estar em elevado perigo. Mostre apoio sem julgar e encoraje o contacto especializado.'
            : 'Detetou alguns sinais de alerta na relação do(a) amigo(a). Mantenha contacto próximo.');

    Color headerColor =
        highRisk ? const Color(0xFFC86B68) : const Color(0xFF48A9A6);

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF23324D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: headerColor, width: 2),
          ),
          child: Column(
            children: [
              Icon(
                  highRisk
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline_rounded,
                  size: 48,
                  color: headerColor),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: headerColor)),
              const SizedBox(height: 12),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF48A9A6),
            foregroundColor: const Color(0xFF18243A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.phone),
          label: const Text('Contactar Linha (800 202 148)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Color(0xFF48A9A6), width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onRestart,
          child: const Text('Refazer Questionário',
              style: TextStyle(
                  color: Color(0xFFF1DAC4),
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
      ],
    );
  }
}

// =====================================================================
// 3. ACONSELHAMENTO E APOIO
// =====================================================================
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  final List<Map<String, dynamic>> _supportSections = const [
    {
      'title': 'O que fazer antes de abandonar a relação?',
      'icon': Icons.description_outlined,
      'intro':
          'Planear a saída com antecedência e máxima discrição é uma das etapas mais determinantes para salvaguardar a segurança física e psicológica, tanto da vítima como dos dependentes envolvidos.',
      'subItems': [
        {
          'title': 'Elaboração de um Plano de Segurança:',
          'text':
              ' Identifique previamente locais seguros de acolhimento (residências de familiares de confiança ou estruturas institucionais) e memorize vias de saída alternativas.'
        },
        {
          'title': 'Rede de Contactos de Emergência:',
          'text':
              ' Memorize os números essenciais de socorro (112 e 800 202 148) e estabeleça um código de alerta discreto com uma pessoa de total confiança.'
        },
        {
          'title': 'Reserva Documental e Financeira:',
          'text':
              ' Reúna e guarde cópias seguras (físicas ou digitais encriptadas) de documentos de identificação fundamentais, mantendo também alguma liquidez monetária num local inacessível ao agressor.'
        },
      ],
    },
    {
      'title': 'O que preciso levar comigo?',
      'icon': Icons.work_outline,
      'intro':
          'Num contexto de saída urgente, a gestão do tempo é crucial. Recomenda-se manter os bens estritamente essenciais reunidos e acessíveis num local seguro.',
      'subItems': [
        {
          'title': 'Identificação Civil e Legal:',
          'text':
              ' Cartão de Cidadão, Passaporte, Certidões de Nascimento, boletins de saúde e processos de regulação de responsabilidades parentais.'
        },
        {
          'title': 'Recursos e Acessos:',
          'text':
              ' Cartões bancários essenciais, chaves de habitação ou viatura, bem como contratos de trabalho, arrendamento ou propriedade.'
        },
        {
          'title': 'Cuidados de Saúde e Comunicação:',
          'text':
              ' Medicação de toma crónica, respetivas prescrições médicas, telemóvel pessoal, carregador e contactos úteis anotados em papel.'
        },
      ],
    },
    {
      'title': 'Quais os riscos e como posso manter-me seguro(a)?',
      'icon': Icons.warning_amber_rounded,
      'intro':
          'O período temporal em redor da decisão de separação constitui estatisticamente a fase de maior vulnerabilidade e risco de escalada de conflitos violentos.',
      'subItems': [
        {
          'title': 'Discrição Preventiva:',
          'text':
              ' Evite comunicar antecipadamente ao agressor a intenção de terminar a relação, salvaguardando a sua integridade através de aconselhamento profissional prévio.'
        },
        {
          'title': 'Modificação de Hábitos:',
          'text':
              ' Altere rotinas diárias, horários de deslocação e percursos habituais para o local de trabalho, residência ou estabelecimentos comerciais.'
        },
        {
          'title': 'Acompanhamento Institucional:',
          'text':
              ' Informe formalmente as autoridades policiais competentes (PSP/GNR) para assegurar o patrulhamento preventivo e o enquadramento legal de proteção.'
        },
      ],
    },
    {
      'title': 'Crianças e contacto contínuo',
      'icon': Icons.family_restroom,
      'intro':
          'A exposição de menores a ambientes de violência doméstica produz impactos severos no seu desenvolvimento. Perante a lei, as crianças expostas são legalmente consideradas vítimas diretas.',
      'subItems': [
        {
          'title': 'Salvaguarda Imediata:',
          'text':
              ' Garanta que o plano de fuga ou afastamento acautela o transporte seguro e a proteção integral dos menores em simultâneo.'
        },
        {
          'title': 'Apoio Psicológico Especializado:',
          'text':
              ' Recorra a entidades especializadas (como a APAV ou CPCJ) para assegurar acompanhamento terapêutico adequado aos menores.'
        },
        {
          'title': 'Tutela Jurídica:',
          'text':
              ' Solicite apoio judiciário prioritário para a regulação do exercício das responsabilidades parentais e restrição de contactos de risco.'
        },
      ],
    },
    {
      'title': 'Animais de Estimação',
      'icon': Icons.pets,
      'intro':
          'Os animais de companhia são frequentemente instrumentalizados por agressores como forma de coação emocional. A proteção do bem-estar animal é legítima e prioritária.',
      'subItems': [
        {
          'title': 'Acolhimento Especializado:',
          'text':
              ' Existem protocolos entre redes de apoio a vítimas e associações de acolhimento animal para salvaguardar temporariamente os animais em situação de risco.'
        },
        {
          'title': 'Registo Sanitário:',
          'text':
              ' Mantenha a documentação veterinária, boletim de vacinas e registo do microchip devidamente atualizados e em seu nome.'
        },
      ],
    },
    {
      'title': 'O que posso fazer para me proteger quando sair de casa?',
      'icon': Icons.security,
      'intro':
          'A fase pós-saída exige a implementação rigorosa de barreiras de proteção no quotidiano para prevenir tentativas de aproximação ou assédio.',
      'subItems': [
        {
          'title': 'Blindagem Tecnológica e Pessoal:',
          'text':
              ' Modifique credenciais de acesso a plataformas digitais, desative a partilha de localização e alerte as chefias profissionais sobre a situação de segurança.'
        },
        {
          'title': 'Registo Documental de Ocorrências:',
          'text':
              ' Documente de forma sistemática e segura todas as tentativas de contacto ou intimidação através de um diário encriptado.'
        },
      ],
    },
    {
      'title': 'Não está sozinho(a).',
      'icon': Icons.people_outline,
      'intro':
          'Enfrentar uma situação de violência requer enorme coragem, mas o apoio especializado está permanentemente acessível através de uma rede institucional qualificada.',
      'subItems': [
        {
          'title': 'Equipas Multidisciplinares Gratuitas:',
          'text':
              ' Profissionais de psicologia, serviço social e advocacia prestam apoio humanizado, isento de julgamentos e sem custos associados.'
        },
        {
          'title': 'Sigilo Profissional Estrito:',
          'text':
              ' Todos os contactos efetuados através das linhas de apoio oficiais encontram-se protegidos por rigorosos padrões de confidencialidade legal.'
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aconselhamento e Apoio')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _supportSections.length,
        itemBuilder: (context, index) {
          final item = _supportSections[index];
          return Card(
            elevation: 2,
            color: const Color(0xFF23324D),
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                  color: const Color(0xFF48A9A6).withOpacity(0.3), width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenericFormattedDetailScreen(
                      title: item['title'],
                      icon: item['icon'],
                      intro: item['intro'],
                      subItems: item['subItems'],
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
                        color: const Color(0xFF48A9A6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'],
                          size: 28, color: const Color(0xFF48A9A6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1DAC4)),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Color(0xFF48A9A6)),
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

// =====================================================================
// 4. GUIA DE SEGURANÇA DIGITAL
// =====================================================================
class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});

  final List<Map<String, dynamic>> _safetySections = const [
    {
      'title': 'Endereço de email',
      'icon': Icons.email_outlined,
      'intro':
          'O correio eletrónico constitui o eixo central da identidade digital, sendo frequentemente utilizado para recuperação de credenciais e notificações bancárias ou institucionais.',
      'subItems': [
        {
          'title': 'Palavras-Passe Robustas:',
          'text':
              ' Utilize chaves de acesso longas, complexas e exclusivas para cada conta, evitando dados biográficos previsíveis.'
        },
        {
          'title': 'Autenticação de Dois Fatores (2FA):',
          'text':
              ' Configure aplicações autenticadoras para adicionar uma camada suplementar de segurança contra acessos não autorizados.'
        },
        {
          'title': 'Monitorização de Sessões:',
          'text':
              ' Verifique periodicamente o painel de dispositivos conectados à conta e termine imediatamente sessões ativas desconhecidas.'
        },
      ],
    },
    {
      'title': 'Browsers',
      'icon': Icons.language,
      'intro':
          'Os navegadores web armazenam históricos de navegação, credenciais memorizadas e ficheiros temporários que podem expor pesquisas sensíveis.',
      'subItems': [
        {
          'title': 'Utilização de Modos Privados:',
          'text':
              ' Recorra sistematicamente a janelas anónimas para consultar conteúdos de apoio ou suporte institucional.'
        },
        {
          'title': 'Higienização de Dados:',
          'text':
              ' Efetue a limpeza regular da cache, cookies e histórico de navegação se partilhar o terminal informático.'
        },
      ],
    },
    {
      'title': 'Redes Sociais',
      'icon': Icons.share,
      'intro':
          'As plataformas sociais expõem inadvertidamente padrões de comportamento, redes de contactos e localizações geográficas em tempo real.',
      'subItems': [
        {
          'title': 'Restrição de Privacidade:',
          'text':
              ' Configure os perfis com o nível máximo de privacidade, limitando o acesso público a publicações e listas de amigos.'
        },
        {
          'title': 'Gestão de Localização:',
          'text':
              ' Desative a marcação automática de coordenadas geográficas e evite partilhar registos visuais em direto de locais que frequenta.'
        },
      ],
    },
    {
      'title': 'Dispositivos Eletrónicos',
      'icon': Icons.devices,
      'intro':
          'Smartphones e computadores portáteis guardam ficheiros e comunicações privadas que requerem mecanismos físicos e lógicos rigorosos de proteção.',
      'subItems': [
        {
          'title': 'Códigos de Acesso Fortes:',
          'text':
              ' Implemente códigos PIN alfanuméricos complexos ou autenticação biométrica avançada.'
        },
        {
          'title': 'Bloqueio Automático Pronto:',
          'text':
              ' Reduza o tempo limite de inatividade para o bloqueio automático do ecrã do equipamento.'
        },
      ],
    },
    {
      'title': 'Aplicações de Mensagens',
      'icon': Icons.message_outlined,
      'intro':
          'As plataformas de comunicação instantânea devem ser configuradas para garantir a confidencialidade e integridade das mensagens trocadas.',
      'subItems': [
        {
          'title': 'Encriptação de Ponta a Ponta:',
          'text':
              ' Assegure-se de que utiliza serviços que encriptam as comunicações de forma a impedir a interceção por terceiros.'
        },
        {
          'title': 'Definição de Mensagens Temporárias:',
          'text':
              ' Ative a eliminação automática de conversas sensíveis para não reter histórico comprometedor no dispositivo.'
        },
      ],
    },
    {
      'title': 'Aplicações',
      'icon': Icons.apps,
      'intro':
          'Muitas aplicações instaladas requerem permissões excessivas sobre sensores e ficheiros do sistema que podem ser aproveitadas para monitorização.',
      'subItems': [
        {
          'title': 'Auditoria de Permissões:',
          'text':
              ' Reveja e revogue o acesso de aplicações de terceiros à câmara, microfone, contactos e dados de localização.'
        },
        {
          'title': 'Deteção de Anomalias:',
          'text':
              ' Monitore o comportamento do dispositivo face a consumo energético injustificado ou sobreaquecimento anormal.'
        },
      ],
    },
    {
      'title': 'Jogos',
      'icon': Icons.sports_esports,
      'intro':
          'Os ecossistemas de jogos online contam com canais de chat interativos que podem ser instrumentalizados para engenharia social ou perseguição digital.',
      'subItems': [
        {
          'title': 'Isolamento de Identidade:',
          'text':
              ' Evite partilhar dados biográficos, contactos pessoais, horários ou localizações em comunidades de jogos.'
        },
        {
          'title': 'Utilização de Pseudónimos:',
          'text':
              ' Adote nomes de utilizador totalmente desassociados da sua identidade civil e redes sociais principais.'
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia de Segurança Digital')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _safetySections.length,
        itemBuilder: (context, index) {
          final item = _safetySections[index];
          return Card(
            elevation: 2,
            color: const Color(0xFF23324D),
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                  color: const Color(0xFF48A9A6).withOpacity(0.3), width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenericFormattedDetailScreen(
                      title: item['title'],
                      icon: item['icon'],
                      intro: item['intro'],
                      subItems: item['subItems'],
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
                        color: const Color(0xFF48A9A6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'],
                          size: 28, color: const Color(0xFF48A9A6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1DAC4)),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Color(0xFF48A9A6)),
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

// COMPONENTE DE DETALHE FORMATADO
class GenericFormattedDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<Map<String, String>> subItems;

  const GenericFormattedDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.intro,
    required this.subItems,
  });

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
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1DAC4)),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF23324D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF48A9A6).withOpacity(0.3)),
              ),
              child: Text(intro,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Color(0xFFF1DAC4))),
            ),
            const SizedBox(height: 20),
            const Text('Orientações Práticas',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF48A9A6))),
            const SizedBox(height: 12),
            ...subItems.map((item) => Card(
                  elevation: 2,
                  color: const Color(0xFF23324D),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: const Color(0xFF48A9A6).withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFFF1DAC4)),
                        children: [
                          const TextSpan(
                              text: '• ',
                              style: TextStyle(
                                  color: Color(0xFF48A9A6),
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: item['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF48A9A6))),
                          TextSpan(text: item['text']),
                        ],
                      ),
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
// 5. LINHAS DE APOIO
// =====================================================================
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  final List<Map<String, String>> _resources = const [
    {
      'title': '1. Serviço Vítimas Violência Doméstica',
      'hours': 'Disponível 24 horas por dia (Gratuita)',
      'phone': '800202148',
      'description':
          'Linha telefónica confidencial com profissionais especializados no atendimento, informação e apoio a vítimas de violência doméstica.'
    },
    {
      'title': '2. Linha de Apoio à Vítima (APAV)',
      'hours': 'Dias úteis, das 09:00 às 21:00 (Gratuita)',
      'phone': '116006',
      'description':
          'Serviço de atendimento e apoio psicológico, social e jurídico prestado pela Associação Portuguesa de Apoio à Vítima.'
    },
    {
      'title': '3. Linha Nacional de Emergência Social',
      'hours': 'Disponível 24 horas por dia (Gratuita)',
      'phone': '144',
      'description':
          'Resposta imediata e encaminhamento para acolhimento em situações de emergência e proteção social urgente.'
    },
    {
      'title': '4. SMS Segurança (Pessoas Surdas)',
      'hours': 'Disponível 24 horas por dia',
      'phone': '961010200',
      'description':
          'Permite o envio de mensagem de texto (SMS) comunicada de imediato pelos operadores da GNR.'
    },
    {
      'title': '5. Linha LGBT (ILGA Portugal)',
      'hours': 'Quinta a Sábado, das 20:00 às 23:00',
      'phone': '218873922',
      'description':
          'Apoio telefónico, escuta ativa e informação especializada sobre questões de orientação sexual e identidade de género.'
    },
    {
      'title': '6. 112 - Emergência Nacional',
      'hours': 'Disponível 24 horas por dia (Gratuita)',
      'phone': '112',
      'description':
          'Contacto imediato das forças de segurança para situações de perigo iminente para a vida ou integridade física.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linhas de Apoio')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          final res = _resources[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: const LinearGradient(
                colors: [Color(0xFF23324D), Color(0xFF1C2A42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF48A9A6).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(res['title']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF48A9A6))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Color(0xFFF1DAC4)),
                      const SizedBox(width: 6),
                      Text(res['hours']!,
                          style: TextStyle(
                              color: const Color(0xFFF1DAC4).withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(res['description']!,
                      style: const TextStyle(
                          fontSize: 13, height: 1.4, color: Color(0xFFF1DAC4))),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48A9A6),
                        foregroundColor: const Color(0xFF18243A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.phone, size: 18),
                      label: Text('Ligar ${res['phone']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('A simular chamada para ${res['phone']}...'),
                            backgroundColor: const Color(0xFF48A9A6),
                          ),
                        );
                      },
                    ),
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
// 6. CÓDIGO DE RESGATE
// =====================================================================
class CodeSettingsScreen extends StatefulWidget {
  const CodeSettingsScreen({super.key});

  @override
  State<CodeSettingsScreen> createState() => _CodeSettingsScreenState();
}

class _CodeSettingsScreenState extends State<CodeSettingsScreen> {
  final TextEditingController _codeController =
      TextEditingController(text: "GIFT2026");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Código de Resgate')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acesso Disfarçado',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF48A9A6))),
            const SizedBox(height: 8),
            const Text(
                'Este é o código que introduz no jogo de blocos para abrir este painel secreto.',
                style: TextStyle(color: Color(0xFFF1DAC4), height: 1.4)),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              style: const TextStyle(
                  color: Color(0xFFF1DAC4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
              decoration: InputDecoration(
                labelText: 'Código Secreto',
                labelStyle: const TextStyle(color: Color(0xFF48A9A6)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF48A9A6))),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48A9A6),
                    foregroundColor: const Color(0xFF18243A),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Código de resgate alterado com sucesso!'),
                        backgroundColor: Color(0xFF48A9A6)),
                  );
                },
                child: const Text('Guardar Novo Código',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 7. ECRÃ DE EMERGÊNCIA 112
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
            const Text('Emergência - 112',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1DAC4))),
            const SizedBox(height: 8),
            const Text(
                'Em caso de perigo imediato, ligue diretamente para as autoridades.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFFF1DAC4))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC86B68),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.call),
              label: const Text('Ligar 112 Agora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                debugPrint('Chamada de emergência 112 acionada');
              },
            ),
          ],
        ),
      ),
    );
  }
}