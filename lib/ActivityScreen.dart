import 'package:app_1/audio_selection.dart';
import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  String explicacion;
  String actividadSugerida;

  ActivityScreen({
    super.key,
    required this.explicacion,
    required this.actividadSugerida,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late String explicacion;
  late String actividadSugerida;

  @override
  void initState() {
    super.initState();
    explicacion = widget.explicacion;
    actividadSugerida = widget.actividadSugerida;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1), 
                Color(0xFF42A5F5), 
                Color(0xFF66BB6A), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              "Guía Interactiva",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            "Guía para Padres",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            explicacion,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

           Column( // Cambiado a Column para evitar Overflow en pantallas pequeñas
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Alerta")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.notifications),
                label: const Text("Activar alerta"),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  // --- CAMBIO CLAVE AQUÍ ---
                  // En lugar de un SnackBar, ahora navega a la nueva pantalla
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AudioPlayerScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.mic),
                label: const Text("Mandar mensaje a Robot"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}