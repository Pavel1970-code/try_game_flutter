import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const TryApp());
}

class TryApp extends StatelessWidget {
  const TryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Try',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A4A4A),
          surface: Color(0xFF2A2A2A),
        ),
      ),
      home: const TryGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TryGame extends StatefulWidget {
  const TryGame({super.key});

  @override
  State<TryGame> createState() => _TryGameState();
}

class _TryGameState extends State<TryGame> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _output;
  String? _systemMessage;
  bool _hasAttempted = false;
  int _attemptCount = 0;
  final Random _random = Random();

  final List<String> _standardPhrases = [
    'I won.',
    'As expected.',
    'Still me.',
    'Predictable.',
    'Nothing changed.',
    'You tried.',
  ];

  final List<String> _persistentPhrases = [
    'Again didn\'t help.',
    'Same outcome.',
    'Consistency matters.',
    'I admire your persistence.',
  ];

  final List<String> _invalidPhrases = [
    'No.',
    'That\'s not a number.',
    'Out of range.',
    'You know the rules.',
  ];

  final List<String> _hundredPhrases = [
    'My game. My rules.',
    'Limits are for you.',
    '101 exists. Just not for you.',
  ];

  void _processInput() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      return;
    }

    final number = int.tryParse(input);

    if (number == null || number < 1 || number > 100) {
      setState(() {
        _systemMessage =
            _invalidPhrases[_random.nextInt(_invalidPhrases.length)];
        _output = null;
      });
      _controller.clear();
      _focusNode.unfocus();
      return;
    }

    final result = number + 1;
    _attemptCount++;

    String message;
    if (number == 100) {
      message = _hundredPhrases[_random.nextInt(_hundredPhrases.length)];
    } else if (_attemptCount > 3) {
      message = _persistentPhrases[_random.nextInt(_persistentPhrases.length)];
    } else {
      message = _standardPhrases[_random.nextInt(_standardPhrases.length)];
    }

    setState(() {
      _output = result.toString();
      _systemMessage = message;
      _hasAttempted = true;
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  void _reset() {
    setState(() {
      _output = null;
      _systemMessage = null;
      _hasAttempted = false;
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '1-100',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[500]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasAttempted ? _reset : _processInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _hasAttempted ? 'Again?' : 'Try',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (_output != null) ...[
                const SizedBox(height: 48),
                Text(
                  _output!,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
              if (_systemMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  _systemMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
