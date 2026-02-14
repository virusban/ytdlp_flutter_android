import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Downloader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String _format = 'mp3';
  String _log = '';
  bool _busy = false;

  final YoutubeExplode _yt = YoutubeExplode();

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  Future<void> _appendLog(String line) async {
    setState(() {
      _log = '$_log\n$line';
    });
  }

  Future<Directory> _appDir() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _ensurePermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _downloadAndConvert(String url, String format) async {
    setState(() => _busy = true);
    try {
      await _appendLog('Checking permissions...');
      final ok = await _ensurePermissions();
      if (!ok) {
        await _appendLog('Storage permission denied.');
        return;
      }

      await _appendLog('Getting video info...');
      final video = await _yt.videos.get(url);
      final title = video.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      await _appendLog('Title: $title');

      final dir = await _appDir();
      final streams = await _yt.videos.streamsClient.getManifest(video.id);

      if (format == 'mp4' || format == 'mkv') {
        final streamInfo = streams.muxed.withHighestBitrate();
        final stream = _yt.videos.streamsClient.get(streamInfo);
        final outPath = '${dir.path}/$title.${streamInfo.container.name}';
        final outFile = File(outPath);
        await _appendLog('Downloading video to $outPath');
        final fileStream = outFile.openWrite();
        await for (final data in stream) {
          fileStream.add(data);
        }
        await fileStream.flush();
        await fileStream.close();
        await _appendLog('Download complete');
        if (format != streamInfo.container.name) {
          final converted = '${dir.path}/$title.$format';
          await _appendLog('Conversion skipped: FFmpegKit not available in this build');
        }
      } else {
        final audioInfo = streams.audio.withHighestBitrate();
        final stream = _yt.videos.streamsClient.get(audioInfo);
        final tempPath = '${dir.path}/$title.${audioInfo.container.name}';
        final tempFile = File(tempPath);
        await _appendLog('Downloading audio to $tempPath');
        final fileStream = tempFile.openWrite();
        await for (final data in stream) {
          fileStream.add(data);
        }
        await fileStream.flush();
        await fileStream.close();
        await _appendLog('Audio download complete');

        final outPath = '${dir.path}/$title.$format';
        await _appendLog('Conversion skipped: FFmpegKit not available in this build');
      }
    } catch (e, st) {
      await _appendLog('Error: $e');
      await _appendLog('$st');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'YouTube URL or ID'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Format:'),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _format,
              items: const [
                DropdownMenuItem(value: 'mp3', child: Text('MP3')),
                DropdownMenuItem(value: 'flac', child: Text('FLAC')),
                DropdownMenuItem(value: 'wav', child: Text('WAV')),
                DropdownMenuItem(value: 'mp4', child: Text('MP4')),
                DropdownMenuItem(value: 'mkv', child: Text('MKV')),
              ],
              onChanged: (v) => setState(() => _format = v ?? 'mp3'),
            ),
          ]),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy
                ? null
                : () {
                    final url = _urlController.text.trim();
                    if (url.isEmpty) {
                      _appendLog('Please enter a URL');
                      return;
                    }
                    _downloadAndConvert(url, _format);
                  },
            child: _busy ? const CircularProgressIndicator() : const Text('Download'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(_log.isEmpty ? 'Logs will appear here.' : _log),
            ),
          ),
        ]),
      ),
    );
  }
}
