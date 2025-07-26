import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website Analyzer',
      home: URLAnalyzer(),
    );
  }
}

class URLAnalyzer extends StatefulWidget {
  @override
  _URLAnalyzerState createState() => _URLAnalyzerState();
}

class _URLAnalyzerState extends State<URLAnalyzer> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> analyzeUrl(String url) async {
    setState(() {
      loading = true;
      result = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://backend-flutter-0pcz.onrender.com/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          result = body;
        });
      } else {
        setState(() {
          result = {"error": body["error"] ?? "Unknown error"};
        });
      }
    } catch (e) {
      setState(() {
        result = {"error": "Connection error: $e"};
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Website Topic Analyzer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter website URL"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => analyzeUrl(_controller.text),
              child: Text("Analyze"),
            ),
            SizedBox(height: 20),
            if (loading) CircularProgressIndicator(),
            if (result != null) ...[
              if (result!.containsKey("error"))
                Text(result!["error"], style: TextStyle(color: Colors.red))
              else
                ...result!.entries.map((e) {
                  final key = e.key;
                  final value = e.value;

                  String formattedValue;
                  if (value is num) {
                    formattedValue = "${value.toStringAsFixed(1)}%";
                  } else {
                    formattedValue = value?.toString() ?? '';
                  }

                  return Text("$key: $formattedValue");
                }).toList()
            ]
          ],
        ),
      ),
    );
  }
}
