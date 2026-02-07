import 'package:flutter/material.dart';
import 'download_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YT Downloader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DownloadPage(),
    );
  }
}
