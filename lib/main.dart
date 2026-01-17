import 'dart:math';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Хрен угадаешь',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();
  int? _result;
  String? _message;
  bool _gameFinished = false;
  bool _hasResult = false;
  int _attempts = 0;
  bool _fakeWinUsed = false;

  final List<String> _winMessages = [
    "Я выиграл 😂",
    "Опять я 🤗",
    "Хитро. Но нет 🧐",
    "Мимо 😘",
    "Почти… но я быстрее 🤑",
    "Ха. Не сегодня 😂",
    "Ты верил. Я знал 🤗",
  ];

  void _processInput() {
    if (_gameFinished) return;

    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final number = int.tryParse(input);
    if (number == null || number < 1) {
      _showError('Введите число от 1 до 100');
      return;
    }

    int normalizedNumber = number > 100 ? 100 : number;
    _attempts++;

    // Check for fake win scenario
    if (_attempts == 3 && !_fakeWinUsed && normalizedNumber < 100) {
      _triggerFakeWin(normalizedNumber);
      return;
    }

    setState(() {
      if (normalizedNumber == 100) {
        _result = 101;
        _message = 'Я выиграл! Моя игра, мои правила! Гуляй, Вася. 😜';
        _gameFinished = true;
        _hasResult = true;
      } else {
        _result = normalizedNumber + 1;
        _message = _winMessages[_random.nextInt(_winMessages.length)];
        _hasResult = true;
      }
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  void _triggerFakeWin(int normalizedNumber) {
    setState(() {
      _result = normalizedNumber - 1;
      _message = 'Ай молодца, наконец-то! Ты победил.... но.....';
      _hasResult = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _result = normalizedNumber + 1;
          _message = 'но не сегодня! 😛';
          _fakeWinUsed = true;
        });
      }
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _resetGame() {
    if (_gameFinished) return;

    setState(() {
      _result = null;
      _message = null;
      _hasResult = false;
      _attempts = 0;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _openUrl(String url) {
    html.window.open(url, '_blank');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[200]!,
              Colors.grey[300]!,
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SingleChildScrollView(
              child: _gameFinished ? _buildFinalScreen() : _buildGameScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Header text
        Text(
          'Загадай число от 1 до 100 💡',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Result block
        if (_hasResult) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple[50]!,
                  Colors.deepPurple[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '$_result',
                    key: ValueKey(_result),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _message ?? '',
                    key: ValueKey(_message),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Input field
        SizedBox(
          width: double.infinity,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Введите число',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.deepPurple[300]!,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.deepPurple[300]!,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.deepPurple[800]!,
                  width: 3,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            onSubmitted: (_) => _processInput(),
          ),
        ),
        const SizedBox(height: 24),

        // Action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasResult ? _resetGame : _processInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              _hasResult ? 'Давай ещё!' : 'Отправить',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFinalScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Large result
        Text(
          '101',
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 24),

        // Final message
        Text(
          'Я выиграл! Моя игра, мои правила! Гуляй, Вася. 😜',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Divider
        Divider(
          color: Colors.grey[400],
          thickness: 1,
          height: 32,
        ),
        const SizedBox(height: 32),

        // Story block
        Text(
          'Кстати…',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Эту игру я придумал в 1986 году\n'
          'на уроке информатики.\n'
          'Написал на BASIC.\n\n'
          'Учитель сыграл, смеялся,\n'
          'поставил мне 5 за урок, четверть и год\n'
          'и сказал больше не приходить,\n'
          'чтобы я не занимал компьютер.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Call to action
        Text(
          'Если вам зашло — вы можете:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Contact buttons
        _buildContactButton(
          emoji: '☕',
          title: 'Угостить кофе',
          subtitle: 'без обязательств',
          onTap: () => _openUrl('https://buymeacoffee.com/paulgutn'),
        ),
        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '📱',
          title: 'Сделай мне такое же',
          subtitle: 'и закажи приложение с таким же характером 😏',
          onTap: () => _openUrl('https://toprete.com'),
        ),
        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '✈️',
          title: 'Написать в Telegram',
          subtitle: '',
          onTap: () => _openUrl('https://t.me/pliim1970'),
        ),
        const SizedBox(height: 16),

        _buildContactButton(
          emoji: '💬',
          title: 'Написать в WhatsApp',
          subtitle: '',
          onTap: () => _openUrl('https://wa.me/995579182894'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildContactButton({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple[800],
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.deepPurple[300]!,
              width: 2,
            ),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
