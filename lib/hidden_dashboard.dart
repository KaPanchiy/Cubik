import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/secret_code_service.dart';

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

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.help_outline, 'title': 'Será violência doméstica?', 'screen': const QuizScreen()},
    {'icon': Icons.list_alt, 'title': 'Tipos de Violência', 'screen': const TypesScreen()},
    {'icon': Icons.info_outline, 'title': 'Aconselhamento e Apoio', 'screen': const SupportScreen()},
    {'icon': Icons.menu_book, 'title': 'Guia de segurança digital', 'screen': const DigitalSafetyScreen()},
    {'icon': Icons.grid_view, 'title': 'Recursos Úteis', 'screen': const ResourcesScreen()},
    {'icon': Icons.lock_outline, 'title': 'Alterar Código Secreto', 'screen': const ChangePinScreen()},
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
          Navigator.of(context).popUntil((route) => route.isFirst);
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
      'description': 'A violência física é qualquer conduta que envolve o uso direto da força contra outra pessoa, atingindo a sua integridade corporal ou a sua saúde. Como uma das formas mais evidentes de agressão, pode manifestar-se de diversas maneiras, como agressões, espancamentos e socos, podendo ser também acompanhada por outras formas de violência, tais como a psicológica e a sexual.\n\nAs suas consequências vão muito além das lesões corporais, incluindo sérios danos emocionais e psicológicos que podem durar por toda a vida da vítima. Além disso, esse tipo de conduta gera importantes desdobramentos legais, podendo resultar em responsabilidades penais, civis e na concessão de medidas protetivas.',
      'help': 'Procure atendimento médico imediato se estiver ferida(o) para registo de lesões. Contacte o 112 em caso de perigo iminente ou a Linha de Apoio à Vítima (800 202 148).'
    },
    {
      'title': 'Violência Psicológica e Controlo Coercivo',
      'icon': Icons.psychology,
      'isRichDescription': true,
      'intro': 'A violência psicológica consiste em agressões sem contacto físico — como humilhações, desvalorizações e menosprezos verbais — que causam danos emocionais profundos. Embora invisível, afeta a autoestima, a razão e a capacidade de reação da vítima. Costuma começar de forma subtil em ambientes familiares, escolares, sociais ou profissionais, evoluindo até ao controlo total do agressor.',
      'bulletPoints': [
        {'title': 'Humilhações:', 'text': ' Piadas e críticas que rebaixam a vítima, mesmo quando camufladas em tom de brincadeira, ou ações degradantes direcionadas perante entes queridos ou desconhecidos.'},
        {'title': 'Isolamento Social:', 'text': ' Impedir ou encorajar a vítima de se conectar com amigos, familiares ou colegas.'},
        {'title': 'Controlo e Vigilância:', 'text': ' Monitorizar horários, vestuário, finanças ou interações sociais. Se o controlo for excessivo, acaba por se transformar numa forma clara de violência psicológica.'},
        {'title': 'Culpabilização:', 'text': ' Fazer a vítima sentir-se sempre errada ou responsável pelas ações do agressor.'},
        {'title': 'Gaslighting (Manipulação da Realidade):', 'text': ' Manipulação exercida para distorcer a perceção da realidade da vítima.'},
        {'title': 'Ameaça:', 'text': ' Gera medo e restringe as ações da vítima. Alguns casos graves são punidos por lei.'},
        {'title': 'Chantagem:', 'text': ' Forma de controlo que explora o sentimento de medo ou a culpa.'},
        {'title': 'Monopolizar a Tomada de Decisões:', 'text': ' Impedir que o outro participe em decisões essenciais (controlo do dinheiro, gestão do tempo, escolha profissional, etc.).'},
        {'title': 'Insultos e Gritos:', 'text': ' As discussões pontuais são normais nos relacionamentos, mas os gritos constantes e os insultos repetidos constituem violência psicológica.'},
        {'title': 'Controlo da Imagem:', 'text': ' Restrições impostas à aparência ou à imagem através de humilhações, coações ou ameaças.'},
        {'title': 'Provocações:', 'text': ' Atitudes que ultrapassam os limites da confiança e visam prejudicar e humilhar.'},
        {'title': 'Moralização:', 'text': ' Associada à chantagem e à humilhação, traduz-se na demonstração constante de superioridade moral.'},
        {'title': 'Críticas Destrutivas:', 'text': ' Críticas reiteradas e constantes que não pretendem ajudar, mas sim destruir a autoconfiança.'},
        {'title': 'Invalidação Emocional:', 'text': ' Desqualificar de forma sistemática os sentimentos de alguém, provocando incapacidade de expressão e incredulidade no próprio julgamento.'},
        {'title': 'Indiferença:', 'text': ' Permanecer deliberadamente indiferente ao outro em qualquer contexto relacional.'},
        {'title': 'Assédio Moral:', 'text': ' Forma de violência psicológica deliberada, cujo intuito é destruir sistematicamente a autoestima da vítima.'}
      ],
      'help': 'Registe episódios num diário seguro (pode usar a aba Diário desta app). Fale com amigos de confiança ou familiares e contacte a linha 800 202 148 para aconselhamento psicológico.'
    },
    {
      'title': 'Violência Financeira e Económica',
      'icon': Icons.account_balance_wallet,
      'isRichDescription': true,
      'intro': 'A violência económica consiste em qualquer comportamento que busca dominar ou subjugar a vítima, manipulando o seu acesso a recursos financeiros, bens, informações ou ao poder de decisão sobre os mesmos. Trata-se do uso do dinheiro como ferramenta de controlo e imposição de limites.',
      'bulletPoints': [
        {'title': 'Proibição de trabalhar:', 'text': ' Impedir que a vítima procure emprego, estude ou mantenha atividade profissional.'},
        {'title': 'Controlo rigoroso de gastos:', 'text': ' Exigir justificações detalhadas para cada despesa, fixar mesadas restritas ou reter cartões e contas bancárias.'},
        {'title': 'Criação de dívidas:', 'text': ' Contrair empréstimos ou obrigações financeiras em nome da vítima sem o seu consentimento livre.'}
      ],
      'help': 'Tente guardar documentos importantes e extratos bancários num local seguro ou digital. Procure apoio jurídico gratuito através da APAV (116 006) ou Segurança Social.'
    },
    {
      'title': 'Violência Sexual',
      'icon': Icons.block,
      'isRichDescription': true,
      'intro': 'A violência sexual manifesta-se através de diferentes condutas graves, que se distinguem pelos atos praticados e pela relação de poder entre os envolvidos:',
      'bulletPoints': [
        {'title': 'Estupro/Coação Sexual:', 'text': ' Ocorre ao constranger a vítima a praticar atos sexuais não consentidos mediante violência ou grave ameaça.'},
        {'title': 'Assédio Sexual:', 'text': ' Consiste em constranger alguém para obter vantagem ou favorecimento sexual, tirando proveito de uma posição de superioridade hierárquica.'}
      ],
      'help': 'Não tome banho nem mude de roupa se o ato foi muito recente, para preservação de provas. Dirija-se a uma urgência hospitalar ou ligue para a Linha SOS Mulher (808 200 175).'
    },
    {
      'title': 'Stalking (Perseguição Persistente)',
      'icon': Icons.security,
      'isRichDescription': true,
      'intro': 'O stalking caracteriza-se por um padrão de comportamentos repetidos e indesejados dirigidos a uma pessoa, comumente por alguém do círculo de relações.',
      'bulletPoints': [
        {'title': 'Presencial:', 'text': ' Vigilância, tentativas de aproximação, presenças indesejadas e envio contínuo de mensagens ou presentes.'},
        {'title': 'Digital (Cyberstalking):', 'text': ' Publicação de fotos, comentários invasivos, monitorização nas redes sociais ou contactos insistentes por meios eletrónicos.'}
      ],
      'help': 'Guarde todas as provas (capturas de ecrã de mensagens, registos de chamadas). Evite responder aos contactos do perseguidor e reporte imediatamente às autoridades.'
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
                      description: item['description'] ?? '',
                      isRichDescription: item['isRichDescription'] ?? false,
                      intro: item['intro'] ?? '',
                      bulletPoints: item['bulletPoints'] ?? [],
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
                        color: const Color(0xFF1565C0).withValues(alpha: 0.1),
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
              child: isRichDescription
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (intro.isNotEmpty) ...[
                          Text(
                            intro,
                            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                          ),
                        ],
                        if (bulletPoints.isNotEmpty) ...[
                          if (intro.isNotEmpty) const SizedBox(height: 12),
                          ...bulletPoints.map((bp) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                                    children: [
                                      const TextSpan(text: '• '),
                                      TextSpan(
                                        text: bp['title'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: bp['text']),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ],
                    )
                  : Text(
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
                color: const Color(0xFF1565C0).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.3)),
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
      List<String> currentQuestions = _isForMe! ? _questionsForMe : _questionsForFriend;
      if (_currentQuestionIndex < currentQuestions.length - 1) {
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
              const Icon(Icons.help_outline, size: 64, color: Color(0xFF1565C0)),
              const SizedBox(height: 24),
              const Text(
                'Para quem está a responder a este questionário?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                'Escolha uma das opções abaixo para personalizarmos as perguntas e as recomendações de apoio.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
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
                  side: const BorderSide(color: Color(0xFFA0522D), width: 2),
                ),
                icon: const Icon(Icons.people, color: Color(0xFFA0522D)),
                label: const Text('É com um(a) amigo(a) / conhecido(a)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA0522D))),
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
      appBar: AppBar(
        title: Text(_isForMe! ? 'Avaliação Pessoal' : 'Apoio a Amigo(a)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !isCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / activeQuestions.length,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pergunta ${_currentQuestionIndex + 1} de ${activeQuestions.length}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.1),
                        label: Text(
                          _isForMe! ? 'Contexto Próprio' : 'Contexto de Amizade',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeQuestions[_currentQuestionIndex],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
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
                  TextButton(
                    onPressed: _previousQuestion,
                    child: const Text('Voltar / Mudar opção anterior'),
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
    bool hasHighRiskTriggers = (answers.length > 3 && answers[3] == true) ||
        (answers.length > 6 && answers[6] == true);

    String title;
    String description;
    Color headerColor;
    IconData headerIcon;

    if (isForMe) {
      if (simCount >= 5 || hasHighRiskTriggers) {
        title = 'Indicadores Elevados (Risco Alto)';
        description = 'A sua situação apresenta indicadores claros de risco elevado para a sua integridade e segurança. Procure ajuda especializada de imediato ou contacte as autoridades.';
        headerColor = Colors.red.shade700;
        headerIcon = Icons.warning_amber_rounded;
      } else if (simCount >= 2) {
        title = 'Indicadores Moderados';
        description = 'Existem sinais evidentes de controlo e desgaste emocional na relação. Considere conversar de forma confidencial com uma linha de apoio ou profissional.';
        headerColor = Colors.orange.shade800;
        headerIcon = Icons.info_outline;
      } else {
        title = 'Indicadores Baixos';
        description = 'Foram assinalados poucos sinais de alerta, mas mantenha-se atento(a) a qualquer mudança de comportamento ou restrição da sua liberdade.';
        headerColor = Colors.green.shade700;
        headerIcon = Icons.check_circle_outline;
      }
    } else {
      if (simCount >= 5 || hasHighRiskTriggers) {
        title = 'Alerta Máximo de Apoio';
        description = 'O seu amigo(a) pode estar numa situação de elevado perigo. Mostre disponibilidade para ouvir sem julgar e encoraje o contacto com entidades especializadas.';
        headerColor = Colors.red.shade700;
        headerIcon = Icons.warning_amber_rounded;
      } else {
        title = 'Atenção Necessária';
        description = 'Existem sinais de alerta na relação do seu amigo(a). Mantenha o contacto próximo e mostre que está lá para ajudar.';
        headerColor = Colors.orange.shade800;
        headerIcon = Icons.info_outline;
      }
    }

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: headerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: headerColor, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(headerIcon, size: 48, color: headerColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.phone),
          label: const Text('Contactar Linha de Apoio (800 202 148)', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            debugPrint('Ligar para linha de apoio');
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onRestart,
          child: const Text('Refazer Questionário'),
        ),
      ],
    );
  }
}

// =====================================================================
// 3. MÓDULO DE ACONSELHAMENTO E APOIO (Estilo Bright Sky)
// =====================================================================
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aconselhamento e Apoio')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orientação Segura',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                ),
                SizedBox(height: 8),
                Text(
                  'Se suspeita que está a viver uma situação abusiva ou conhece alguém nessa situação, lembre-se de que não está sozinho(a). O apoio é confidencial e gratuito.',
                  style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'O que deve fazer?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA0522D)),
          ),
          const SizedBox(height: 8),
          _buildSupportCard(
            '1. Plano de Segurança',
            'Identifique um local seguro para onde ir em caso de emergência e guarde cópias digitais de documentos importantes num local inacessível ao agressor.',
            Icons.shield_outlined,
          ),
          _buildSupportCard(
            '2. Fale com Alguém de Confiança',
            'Partilhe o que está a sentir com um familiar ou amigo próximo. Quebrar o isolamento é um passo fundamental.',
            Icons.people_outline,
          ),
          _buildSupportCard(
            '3. Contacte Linhas Especializadas',
            'Ligue grátis para a Linha de Apoio à Vítima (800 202 148) ou para o 112 em caso de perigo imediato.',
            Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 4. ECRÃ DE RECURSOS ÚTEIS (Com os dados completos)
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
        'hours': '24 horas por dia (Gratuita)',
        'phone': '112',
        'description': 'Contacto imediato para situações de perigo iminente para a vida, integridade física ou segurança.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Recursos Úteis')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final res = resources[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(res['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0))),
                  const SizedBox(height: 4),
                  Text(res['hours']!, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(res['description']!, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Color(0xFFA0522D)),
                      const SizedBox(width: 6),
                      Text('Contacto: ${res['phone']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFA0522D))),
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
// 5. OUTROS ECRÃS (DigitalSafety, Diary, Emergency)
// =====================================================================
class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia de Segurança Digital')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Aprenda a apagar o histórico de navegação, proteger as suas palavras-passe, usar o modo de navegação anónima e detetar aplicações de spyware ou monitorização no seu telemóvel.',
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),
      ),
    );
  }
}

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Registo de Diário / Ocorrências\n(Espaço seguro e encriptado para apontar incidentes)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
        ),
      ),
    );
  }
}

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
            const Icon(Icons.phone_in_talk, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Emergência - 112',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Em caso de perigo imediato, ligue diretamente para as autoridades.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.call),
              label: const Text('Ligar 112 Agora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

// =====================================================================
// ECRÃ DE ALTERAÇÃO DE CÓDIGO/SENHA SECRETA
// =====================================================================
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _currentPin = SecretCodeService.defaultCode;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentPin() async {
    final pin = await SecretCodeService.getSecretCode();
    if (mounted) {
      setState(() {
        _currentPin = pin;
      });
    }
  }

  Future<void> _saveNewPin() async {
    final newPin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, escreve um novo código/senha.';
        _isSuccess = false;
      });
      return;
    }

    if (newPin != confirmPin) {
      setState(() {
        _statusMessage = 'Os dois códigos não coincidem. Tenta novamente.';
        _isSuccess = false;
      });
      return;
    }

    await SecretCodeService.setSecretCode(newPin);
    if (mounted) {
      setState(() {
        _currentPin = newPin;
        _statusMessage = 'Código secreto alterado com sucesso!';
        _isSuccess = true;
        _pinController.clear();
        _confirmPinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Código Secreto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.security, size: 64, color: Color(0xFF1565C0)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Personaliza o teu Código de Acesso',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Este é o código que deves introduzir na caixa "Resgatar Código" do jogo para abrir este painel oculto.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Código secreto atual: "$_currentPin"',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'Novo Código Secreto',
                hintText: 'Ex: 5678 ou OMEUCODIGO',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_open),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              decoration: InputDecoration(
                labelText: 'Confirmar Novo Código',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _isSuccess ? Colors.green.shade300 : Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveNewPin,
                child: const Text('Guardar Novo Código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}