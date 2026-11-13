import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const FotoTxtApp());

class FotoTxtApp extends StatelessWidget {
  const FotoTxtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto para TXT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF1F6FEB), useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F6FEB),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
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
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _controller = TextEditingController();

  File? _image;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _recognizer.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 95);
    } catch (e) {
      setState(() => _message = 'Não foi possível abrir a câmera/galeria: $e');
      return;
    }
    if (picked == null) return;

    setState(() {
      _image = File(picked!.path);
      _busy = true;
      _message = 'Lendo o texto…';
      _controller.clear();
    });

    try {
      final result = await _recognizer.processImage(InputImage.fromFilePath(picked.path));
      final text = result.text.trim();
      if (!mounted) return;
      setState(() {
        _controller.text = text;
        _message = text.isEmpty
            ? 'Nenhum texto encontrado. Tente uma foto mais nítida e bem iluminada.'
            : 'Pronto! Revise o texto abaixo.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = 'Erro ao ler a imagem: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _writeTxt() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 19).replaceAll(RegExp(r'[:T]'), '-');
    final file = File('${dir.path}/texto-$stamp.txt');
    return file.writeAsString(_controller.text);
  }

  // Abre a folha de compartilhamento do sistema: dali dá para salvar em
  // Arquivos/Drive, mandar no WhatsApp, e-mail, etc.
  Future<void> _saveOrShare() async {
    final file = await _writeTxt();
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'text/plain')]));
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Texto copiado')));
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Foto para TXT')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Tirar foto'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Escolher da galeria'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 220, fit: BoxFit.contain),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (_image != null && !_busy) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: null,
                minLines: 10,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Texto reconhecido'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton(onPressed: hasText ? _copy : null, child: const Text('Copiar')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(onPressed: hasText ? _saveOrShare : null, child: const Text('Salvar .txt')),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
