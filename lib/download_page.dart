import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});
  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  String _status = "Idle";
  String _savePath = "";
  double _progress = 0.0;
  String _selectedFormat = "mp4";

  final List<String> formats = ["mp4","mkv","webm","mp3","flac","wav"];
  static const platform = MethodChannel("ytdlp_flutter");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YT Downloader")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _urlController, decoration: const InputDecoration(labelText: "YouTube URL", border: OutlineInputBorder())),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _selectedFormat,
            items: formats.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val){setState(()=>_selectedFormat=val!);}
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _pickFolder, child: const Text("Choose Save Folder")),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _download, child: const Text("Download")),
          const SizedBox(height: 16),
          LinearPercentIndicator(lineHeight: 14, percent: _progress, center: Text("${(_progress*100).toStringAsFixed(0)}%"), progressColor: Colors.blue),
          const SizedBox(height: 16),
          Text(_status)
        ]),
      ),
    );
  }

  void _pickFolder() async {
    String? dir = await FilePicker.platform.getDirectoryPath();
    if(dir != null) setState(()=>_savePath=dir);
  }

  void _download() async {
    if(_urlController.text.isEmpty || _savePath.isEmpty){
      setState(()=>_status="Enter URL and select folder");
      return;
    }

    setState(()=>_status="Downloading...");
    try{
      final result = await platform.invokeMethod("download", {
        "url": _urlController.text,
        "path": _savePath,
        "format": _selectedFormat
      });
      setState(()=>_status=result);
      _progress=1.0;
    } catch(e){
      setState(()=>_status="Error: $e");
    }
  }
}
