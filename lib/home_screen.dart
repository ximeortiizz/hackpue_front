import 'dart:async' as async;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Modelo para las tarjetas de funcionalidades
class Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final List<Color> gradientColors;

  Feature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.gradientColors,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- BLE SERVICE ---
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
      icon: Icons.block,
      iconBgColor: const Color(0xFFF9D4D5),
      gradientColors: [Color(0xFFFBE9EA), Color(0xFFFADDE1)],
    ),
    Feature(
      title: 'Phishing',
      subtitle: 'La noticia de hoy',
      icon: Icons.grid_view_rounded,
      iconBgColor: const Color(0xFFFBE1C8),
      gradientColors: [Color(0xFFFEF3E5), Color(0xFFFDECD7)],
    ),
    Feature(
      title: 'Parental Control',
      subtitle: 'La noticia de hoy',
      icon: Icons.location_on_outlined,
      iconBgColor: const Color(0xFFD3D3F6),
      gradientColors: [Color(0xFFEBEBFC), Color(0xFFE3E2F8)],
    ),
    Feature(
      title: 'Privacidad',
      subtitle: 'La noticia de hoy',
      icon: Icons.shield_outlined,
      iconBgColor: const Color(0xFFCFF0DF),
      gradientColors: [Color(0xFFE6F9F0), Color(0xFFDBF4E8)],
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
      if (state == BluetoothAdapterState.on) {
        print("Bluetooth activado");
      } else {
        print("Por favor enciende el Bluetooth");
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
            .where((r) =>
                r.device.advName.contains("ESP32") ||
                r.device.advName.contains("EMG"))
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
      await espDevice!.disconnect();
      setState(() {
        espDevice = null;
        isConnected = false;
        receivedData = 0;
      });
      print("Desconectado del ESP32");
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildFeaturesGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3E8B),
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
            child:
                _isPanelOpen ? _buildConnectionPanel() : const SizedBox.shrink(),
          ),
          const SizedBox(height: 25),
          _buildTimeLimit(),
          const SizedBox(height: 25),
          _buildActionControls(),
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
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=25'),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Robot 1",
                  style: TextStyle(
                      fontFamily: 'Cocogoose',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800])),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                        fontFamily: 'Cocogoose',
                        fontSize: 12,
                        color: Colors.grey[600]),
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
          Text('Dispositivos encontrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cocogoose',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 10),
          if (isScanning)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (!isScanning && scanResults.isEmpty)
            const Text("No se encontraron dispositivos",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70)),
          if (scanResults.isNotEmpty)
            ...scanResults.map((r) {
              final device = r.device;
              return ListTile(
                title: Text(device.advName.isNotEmpty
                    ? device.advName
                    : "Dispositivo desconocido"),
                subtitle: Text(device.remoteId.toString(),
                    style: const TextStyle(color: Colors.white70)),
                trailing: ElevatedButton(
                  onPressed: () => connectToDevice(device),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Conectar",
                      style: TextStyle(color: Color(0xFF2D3E8B))),
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
        Text('Bienvenido',
            style: TextStyle(
                fontFamily: 'Cocogoose',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 4),
        Text("Educa y protege a tus menores",
            style: TextStyle(
                fontFamily: 'Cocogoose', fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  Widget _buildActionControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
              Icons.lock_outline, 'Lock phone', const Color(0xFFE89ABE)),
          _buildActionButton(Icons.pause, 'Pause', const Color(0xFF2D3E8B)),
          _buildActionButton(
              Icons.add_circle_outline, 'Add time', const Color(0xFF2D3E8B)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontFamily: 'Cocogoose',
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold)),
      ],
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
          childAspectRatio: 0.9,
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
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 1),
          _buildNavItem(Icons.notifications_none, 'Notification', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
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
          Icon(icon,
              size: 28,
              color: isSelected ? const Color(0xFF2D3E8B) : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cocogoose',
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF2D3E8B) : Colors.grey,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: feature.iconBgColor,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(feature.icon, color: Colors.white, size: 24),
          ),
          const Spacer(),
          Text(feature.title,
              style: const TextStyle(
                  fontFamily: 'Cocogoose',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(feature.subtitle,
              style: const TextStyle(
                  fontFamily: 'Cocogoose',
                  fontSize: 11,
                  color: Colors.black54)),
        ],
      ),
    );
  }
}
