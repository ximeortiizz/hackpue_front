import 'dart:async' as async;
import 'dart:io';
import 'package:app_1/APINewsScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app_1/NewsScreen.dart';

class Feature {
  final String title;
  final String subtitle;
  final String bottomText;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<Color> gradientColors;
  final String? imagePath;

  Feature({
    required this.title,
    required this.subtitle,
    required this.bottomText,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.gradientColors,
    this.imagePath,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //  BLE SERVICE :)
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? espDevice;
  BluetoothCharacteristic? espCharacteristic;

  List<ScanResult> scanResults = [];
  int receivedData = 0;
  bool isScanning = false;
  bool isConnected = false;

  final Guid serviceUUID = Guid("2E18CC93-EFBE-4927-AC92-0D229C122383");
  final Guid characteristicUUID = Guid("13909B07-0859-452F-AB6E-E5A4BC8D9DF4");

  int _selectedIndex = 1;
  bool _isPanelOpen = false;

  final List<Feature> features = [
    Feature(
      title: 'Grooming',
      subtitle: 'La noticia de hoy',
      bottomText: '',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color.fromRGBO(0, 100, 0, 1),
      iconBgColor: const Color.fromRGBO(167, 216, 169, 1),
      gradientColors: [
        const Color.fromRGBO(230, 249, 240, 1),
        const Color(0xFFDBF4E8),
      ],
    ),
    Feature(
      title: 'Phishing',
      subtitle: 'La noticia de hoy',
      bottomText: '',
      icon: Icons.grid_view_rounded,
      iconColor: const Color(0xFF00008B),
      iconBgColor: const Color(0xFFADC8E6),
      gradientColors: [const Color(0xFFEBF2FA), const Color(0xFFE2EAF8)],
    ),
    Feature(
      title: 'Control Parental',
      subtitle: 'La noticia de hoy',
      bottomText: '',
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFF00008B),
      iconBgColor: const Color(0xFFADC8E6),
      gradientColors: [const Color(0xFFEBF2FA), const Color(0xFFE2EAF8)],
    ),

    Feature(
      title: 'Privacidad',
      subtitle: 'La noticia de hoy',
      bottomText: '',
      icon: Icons.shield_outlined,
      iconColor: const Color(0xFF006400),
      iconBgColor: const Color(0xFFA7D8A9),
      gradientColors: [const Color(0xFFE6F9F0), const Color(0xFFDBF4E8)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    checkBluetoothSupport();
  }

  Future<void> checkBluetoothSupport() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth no está disponible en este dispositivo.");
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
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results
            .where(
              (r) =>
                  r.device.advName.contains("ESP32") ||
                  r.device.advName.contains("EMG"),
            )
            .toList();
      });
    });
    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  int _convertToInt(List<int> value) {
    if (value.length == 1) return value[0];
    if (value.length == 2) return (value[1] << 8) | value[0];
    if (value.length == 4) {
      return (value[3] << 24) | (value[2] << 16) | (value[1] << 8) | value[0];
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
            espCharacteristic!.lastValueStream.listen((value) {
              int emgValue = _convertToInt(value);
              setState(() => receivedData = emgValue);
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
            title: Text("¿Desconectar?"),
            content: Text('¿Estás seguro de que quieres desconectarte?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Aceptar', style: TextStyle(color: Colors.cyan)),
              ),
            ],
          );
        },
      );
      if (_really_disconect) {
        await espDevice!.disconnect();
        setState(() {
          espDevice = null;
          receivedData = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildFeaturesGrid()]),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(13, 71, 161, 1),
            Colors.lightBlue,
            Color.fromRGBO(102, 187, 106, 1),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          _buildProfileBar(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isPanelOpen
                ? _buildConnectionPanel()
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 25),
          _buildTimeLimit(),
          const SizedBox(height: 20),
          _buildNewsSection(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildProfileBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            //backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('lib/assets/robot.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Robot 1",
                style: TextStyle(
                  fontFamily: 'Lokeya',
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                      fontFamily: 'Lokeya',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: AnimatedRotation(
              turns: _isPanelOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
            ),
            onPressed: () {
              setState(() => _isPanelOpen = !_isPanelOpen);
              if (_isPanelOpen) scanForDevices();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dispositivos encontrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cocogoose',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (isScanning)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (!isScanning && scanResults.isEmpty)
            const Text(
              "No se encontraron dispositivos",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          if (scanResults.isNotEmpty)
            ...scanResults.map((r) {
              final device = r.device;
              return ListTile(
                title: Text(
                  device.advName.isNotEmpty
                      ? device.advName
                      : "Dispositivo desconocido",
                ),
                subtitle: Text(
                  device.remoteId.toString(),
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: ElevatedButton(
                  onPressed: () => connectToDevice(device),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Conectar",
                    style: TextStyle(color: Color(0xFF2D3E8B)),
                  ),
                ),
              );
            }).toList(),
          if (isConnected)
            ElevatedButton(
              onPressed: disconnectDevice,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Desconectar"),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeLimit() {
    return const Column(
      children: [
        Text(
          'Bienvenido',
          style: TextStyle(
            fontFamily: 'AGRESSIVE',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Educa y protege a tus menores",
          style: TextStyle(
            fontFamily: 'Lokeya',
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.article_outlined, color: Colors.white, size: 28),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Noticias del Dia',
                      style: TextStyle(
                        fontFamily: 'Lokeya',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Resumen de ciberseguridad',
                      style: TextStyle(
                        fontFamily: 'Lokeya',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          return FeatureCard(feature: features[index]);
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Inicio', 1),
          _buildNavItem(Icons.notifications_none, 'Informarme', 2),
          _buildNavItem(Icons.call, 'Emergencias', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? const Color(0xFF2D3E8B) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cocogoose',
              fontSize: 12,
              color: isSelected ? const Color(0xFF2D3E8B) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Feature feature;
  const FeatureCard({Key? key, required this.feature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: feature.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: feature.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: const TextStyle(
                  fontFamily: 'Cocogoose',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature.subtitle,
                style: const TextStyle(
                  fontFamily: 'Lokeya',
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
              Text(
                feature.bottomText,
                style: const TextStyle(
                  fontFamily: 'Lokeya',
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
