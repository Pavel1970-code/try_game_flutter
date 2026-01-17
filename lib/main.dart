import 'dart:math';
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result and message displayed above input
              if (_hasResult) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '$_result',
                    key: ValueKey(_result),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _message ?? '',
                    key: ValueKey(_message),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Input field
              if (!_gameFinished) ...[
                SizedBox(
                  width: 200,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '1-100',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
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
                        borderSide: const BorderSide(
                          color: Colors.deepPurple,
                          width: 3,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                    onSubmitted: (_) => _processInput(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              if (!_gameFinished) ...[
                ElevatedButton(
                  onPressed: _hasResult ? _resetGame : _processInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _hasResult ? 'Давай ещё!' : 'Попробовать',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              if (_gameFinished) ...[
                const SizedBox(height: 16),
                Text(
                  'Игра окончена!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
