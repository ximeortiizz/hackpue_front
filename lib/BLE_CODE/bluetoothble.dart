import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'dart:io';

class BLEScreen extends StatefulWidget {
  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  FlutterBluePlus flutterBlue = FlutterBluePlus(); 
  BluetoothDevice? espDevice; 
  BluetoothCharacteristic? espCharacteristic; 

  List<ScanResult> scanResults = []; 
  int receivedData = 0;
  bool isScanning = false;
  bool isConnected = false;

  final Guid serviceUUID = Guid("2E18CC93-EFBE-4927-AC92-0D229C122383");
  final Guid characteristicUUID = Guid("13909B07-0859-452F-AB6E-E5A4BC8D9DF4");

  @override
  void initState() {
    super.initState();
    checkBluetoothSupport();
  }

  Future<void> checkBluetoothSupport() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("La función Bluetooth no está disponible en este dispositivo.");
      return;
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print("Estado de Bluetooth: $state");
      if (state == BluetoothAdapterState.on) {
        scanForDevices();
      } else {
        print("Por favor, habilita la función Bluetooth para continuar.");
      }
    });

    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  void scanForDevices() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results
            .where((result) =>
                (result.device.advName.contains('ESP32')) ||
                (result.device.advName.contains('EMG')))
            .toList();
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  int _convertToInt(List<int> value) {
    if (value.length == 1) {
      return value[0]; 
    } else if (value.length == 2) {
      return (value[1] << 8) | value[0]; 
    } else if (value.length == 4) {
      return (value[3] << 24) |
          (value[2] << 16) |
          (value[1] << 8) |
          value[0]; 
    }
    return 0; 
  }

  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      espDevice = device;
      isConnected = true;
    });

    await espDevice!.connect();
    print("Conectado a ${device.advName}");

    List<BluetoothService> services = await espDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == characteristicUUID) {
            espCharacteristic = characteristic;
            await espCharacteristic!.setNotifyValue(true);

            late async.StreamSubscription<List<int>> bleSubscription =
                espCharacteristic!.lastValueStream.listen((value) {
              int emgValue = _convertToInt(value);

              setState(() {
                receivedData = emgValue;
              });

              print("Dato recibido: $emgValue");
            });
          }
        }
      }
    }
  }

  void disconnectDevice() async {
    if (espDevice != null) {
      bool _really_disconect = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("¿Desconectar?"),
              content: const Text('¿Estás seguro de que quieres desconectarte del ESP32?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.deepPurple))),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Aceptar', style: TextStyle(color: Colors.purple))),
              ],
            );
          });

      if (_really_disconect) {
        await espDevice!.disconnect();
        setState(() {
          espDevice = null;
          receivedData = 0;
          isConnected = false;
        });
        print("Desconectado del ESP32");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE ESP32")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              isConnected ? "✅ Conectado al ESP32" : "❌ No conectado",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.green : Colors.red),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isScanning ? null : scanForDevices,
            child: Text(isScanning ? "Buscando..." : "Buscar Dispositivos"),
          ),
          const SizedBox(height: 20),
          if (scanResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final device = scanResults[index].device;
                  return ListTile(
                    title: Text(device.advName.isNotEmpty ? device.advName : "Dispositivo desconocido"),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => connectToDevice(device),
                      child: const Text("Conectar"),
                    ),
                  );
                },
              ),
            ),
          if (isConnected)
            ElevatedButton(
              onPressed: disconnectDevice,
              child: const Text("Desconectar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
        ],
      ),
    );
  }
}
