// APINewsScreen.dart (usa tu APIService ya separado)
import 'package:app_1/services/APIService.dart';
import 'package:flutter/material.dart';

class APINewsScreen extends StatefulWidget {
  const APINewsScreen({super.key});
  @override
  State<APINewsScreen> createState() => _APINewsScreenState();
}

class _APINewsScreenState extends State<APINewsScreen> {
  final api = APIService(
    baseUrl: "https://absolute-live-sheepdog.ngrok-free.app",
    apiKey: "rexy",
  );

  bool loading = false;
  String errorMsg = "";
  List<String> processedIds = [];

  @override
  void initState() {
    super.initState();
    _runFlow();
  }

  Future<void> _runFlow() async {
    setState(() {
      loading = true;
      errorMsg = "";
      processedIds.clear();
    });

    try {
      // 1) Ingesta
      try {
        await api.runIngest();
      } catch (e) {
        setState(() {
          errorMsg = "Error en runIngest: $e";
        });
        return;
      }

      // 2) Queue → obtener pendientes
      List<Map<String, dynamic>> queue = [];
      try {
        queue = await api.fetchQueue();
      } catch (e) {
        setState(() {
          errorMsg = "Error en fetchQueue: $e";
        });
        return;
      }
      if (queue.isEmpty) {
        setState(() {
          errorMsg = "No hay pendientes en la cola.";
        });
        return;
      }

      // 3) Process auto por cada item
      for (final it in queue) {
        final id = _extractId(it);
        if (id == null) continue;
        final ok = await api.processAuto(id);
        if (ok) processedIds.add(id);
      }

      if (processedIds.isEmpty) {
        setState(() {
          errorMsg =
              "No se pudo procesar ningún item (quizá ya estaban procesados).";
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String? _extractId(Map<String, dynamic> it) {
    if (it["id"] != null) return it["id"].toString();
    if (it["_id"] is Map && it["_id"]["\$oid"] != null) {
      return it["_id"]["\$oid"].toString();
    }
    return null;
    // TIP: si tu /queue ya devuelve "id" como string, perfecto; usa eso.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerta Digital Familiar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: loading ? null : _runFlow,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
          ? Center(child: Text(errorMsg))
          : processedIds.isEmpty
          ? const Center(child: Text("Listo. Procesados 0 items."))
          : ListView.builder(
              itemCount: processedIds.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text("Procesado: ${processedIds[i]}"),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _runFlow,
        label: const Text("Correr flujo"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
