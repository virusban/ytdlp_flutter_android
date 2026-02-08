import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (light, dark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: light ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: dark ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final urlController = TextEditingController();
  String format = "mp4";
  String? folder;

  static const channel = MethodChannel("ytdlp_channel");

  Future<void> pickFolder() async {
    folder = await FilePicker.platform.getDirectoryPath();
    setState(() {});
  }

  Future<void> download() async {
    if (folder == null || urlController.text.isEmpty) return;

    await channel.invokeMethod("download", {
      "url": urlController.text,
      "path": folder,
      "format": format,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Загрузка началась")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YT-DLP Downloader"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "⚠️ Только для личного использования",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "YouTube URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: format,
              decoration: const InputDecoration(
                labelText: "Формат",
                border: OutlineInputBorder(),
              ),
              items: const [
                "mp4", "mkv", "webm", "mp3", "flac", "wav"
              ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => format = v!),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: pickFolder,
              icon: const Icon(Icons.folder_open),
              label: const Text("Выбрать папку"),
            ),
            if (folder != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(folder!, style: Theme.of(context).textTheme.bodySmall),
              ),
            const Spacer(),
            FilledButton(
              onPressed: download,
              child: const Text("⬇ Скачать"),
            ),
          ],
        ),
      ),
    );
  }
}
