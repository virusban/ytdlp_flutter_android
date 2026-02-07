import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_python/flutter_python.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  String _status = "Idle";
  double _progress = 0.0;
  String _selectedFormat = "mp4";
  String _savePath = "";

  final List<String> formats = ["mp4", "mkv", "webm", "mp3", "flac", "wav"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YT Downloader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "YouTube URL"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedFormat,
              items: formats.map((f) {
                return DropdownMenuItem(value: f, child: Text(f));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFormat = val!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFolder,
              child: const Text("Choose Save Folder"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _download,
              child: const Text("Download"),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 14.0,
              percent: _progress,
              center: Text("${(_progress * 100).toStringAsFixed(0)}%"),
              progressColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }

  void _pickFolder() async {
    String? selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir != null) {
      setState(() {
        _savePath = selectedDir;
        _status = "Selected folder: $_savePath";
      });
    }
  }

  void _download() async {
    if (_urlController.text.isEmpty || _savePath.isEmpty) {
      setState(() {
        _status = "Enter URL and select folder";
      });
      return;
    }

    setState(() {
      _status = "Downloading...";
      _progress = 0.0;
    });

    final python = FlutterPython();
    python.setPythonScript("python/ytdlp_download.py");

    try {
      await python.run(
        args: [_urlController.text, _savePath, _selectedFormat],
        onStdout: (line) {
          if (line.contains("%")) {
            final match = RegExp(r"(\d+\.?\d*)%").firstMatch(line);
            if (match != null) {
              setState(() {
                _progress = double.parse(match.group(1)!) / 100;
              });
            }
          }
          setState(() {
            _status = line;
          });
        },
      );
      setState(() {
        _status = "Download completed!";
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }
}
