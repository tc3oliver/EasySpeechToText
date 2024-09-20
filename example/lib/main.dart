import 'package:flutter/material.dart';
import 'package:easy_speech_to_text/easy_speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final EasySpeechToText _speechToText = EasySpeechToText();
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechToText.initialize();
      bool hasPermission = await _speechToText.hasPermission();
      if (!hasPermission) {
        hasPermission = await _speechToText.requestPermission();
      }
      if (!hasPermission) {
        debugPrint('Permission not granted');
      }
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _recognizedText = ''; // 清空之前的辨識結果
    });

    _speechToText.startListening(
      localeId: 'zh_TW',
      onResult: (text) {
        setState(() {
          // 確認這次辨識結果與之前的不同，才進行更新
          if (!_recognizedText.endsWith(text)) {
            debugPrint('Recognized: $text');
            _recognizedText += text; // 追加新的結果
          }
        });
      },
      onError: (error) {
        debugPrint('Error111: $error');
        if (error != 'No match found') {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
  }

  void _stopListening() {
    _speechToText.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _cancelListening() {
    _speechToText.cancelListening();
    setState(() {
      _isListening = false;
      _recognizedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Speech to Text Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Easy Speech to Text Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Recognized Text:',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _recognizedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isListening
                  ? ElevatedButton(
                      onPressed: _stopListening,
                      child: const Text('Stop Listening'),
                    )
                  : ElevatedButton(
                      onPressed: _startListening,
                      child: const Text('Start Listening'),
                    ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _cancelListening,
                child: const Text('Cancel Listening'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
