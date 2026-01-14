import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? _authorMessage;
  bool _hasAttempted = false;
  bool _gameEnded = false;

  void _processInput() {
    if (_gameEnded) return;

    final input = _controller.text.trim();

    if (input.isEmpty) {
      return;
    }

    final number = int.tryParse(input);

    if (number == null || number < 1 || number > 100) {
      setState(() {
        _systemMessage = 'Нет.';
        _output = null;
        _authorMessage = null;
      });
      _controller.clear();
      _focusNode.unfocus();
      return;
    }

    final result = number + 1;

    if (number == 100) {
      setState(() {
        _output = '101';
        _systemMessage = 'Моя игра. Мои правила.';
        _authorMessage =
            'Эту гадость сделал я.\nЕсли нужно что-то похожее или лучше — пиши.';
        _gameEnded = true;
        _hasAttempted = true;
      });
      _controller.clear();
      _focusNode.unfocus();
    } else {
      setState(() {
        _output = result.toString();
        _systemMessage = 'Я выиграл.';
        _authorMessage = null;
        _hasAttempted = true;
      });
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _reset() {
    if (_gameEnded) return;

    setState(() {
      _output = null;
      _systemMessage = null;
      _authorMessage = null;
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
              if (_systemMessage != null) ...[
                Text(
                  _systemMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              if (_output != null) ...[
                Text(
                  _output!,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 32),
              ],
              if (!_gameEnded) ...[
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
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
                    onSubmitted: (_) => _processInput(),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              if (_hasAttempted && !_gameEnded) ...[
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ещё', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
              if (!_hasAttempted && !_gameEnded) ...[
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _processInput,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
              if (_authorMessage != null) ...[
                const SizedBox(height: 48),
                Text(
                  _authorMessage!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://t.me/pliim1970');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    '@pliim1970',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      decoration: TextDecoration.underline,
                    ),
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
