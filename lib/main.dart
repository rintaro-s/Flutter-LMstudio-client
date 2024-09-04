import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMstudio Client',
      home: Scaffold(
        appBar: AppBar(
          title: Text('LMstudio Client'),
        ),
        body: PromptInput(),
      ),
    );
  }
}

class PromptInput extends StatefulWidget {
  @override
  _PromptInputState createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _ipController = TextEditingController(text: 'localhost');
  String _response = '';

  Future<void> _sendInferenceRequest(String prompt, String ipAddress) async {
    final url = Uri.parse('http://$ipAddress:1234/v1/completions');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'prompt': prompt,
      'temperature': 0.7,
      'max_tokens': 100,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        _response = jsonDecode(response.body)['choices'][0]['text'];
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode} ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _ipController,
            decoration: InputDecoration(labelText: 'IPアドレスを入力してください'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _promptController,
            decoration: InputDecoration(labelText: 'プロンプトを入力してください'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _sendInferenceRequest(_promptController.text, _ipController.text),
            child: Text('送信'),
          ),
          SizedBox(height: 20),
          Text(_response),
        ],
      ),
    );
  }
}
