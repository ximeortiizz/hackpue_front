import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String assetPath) async {
    try {
      await audioPlayer.play(AssetSource(assetPath));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reproduciendo: $assetPath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir el audio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Enviar Mensaje de Voz",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona una frase para enviar:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),

              _buildAudioButton(
                text: "Frase 1",
                icon: Icons.task_alt,
                assetPath: 'audio/audio1.mp4',
              ),
              const SizedBox(height: 15),
              _buildAudioButton(
                text: "Frase 2",
                icon: Icons.task_alt,
                assetPath: 'audio/audio2.wav',
              ),
              const SizedBox(height: 15),
              _buildAudioButton(
                text: "Frase 3",
                icon: Icons.task_alt,
                assetPath: 'audio/audio3.wav',
              ),
              const SizedBox(height: 15),
              _buildAudioButton(
                text: "Frase 4",
                icon: Icons.task_alt,
                assetPath: 'audio/audio3.wav',
              ),
              const SizedBox(height: 15),
              _buildAudioButton(
                text: "Frase 5",
                icon: Icons.task_alt,
                assetPath: 'audio/audio3.wav',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioButton({
    required String text,
    required IconData icon,
    required String assetPath,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _playAudio(assetPath),
      icon: Icon(icon, size: 24),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }
}
