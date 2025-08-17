import 'dart:async' as async;
import 'dart:io';
import 'package:app_1/APINewsScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app_1/NewsScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_1/ActivityScreen.dart'; 
import 'package:app_1/topic_detail_screen.dart'; // <-- 1. IMPORTA LA NUEVA PANTALLA



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
      subtitle: 'Protege a los menores del acoso digital',
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

  final List<Topic> topics = [
    Topic(
      title: "Grooming",
      expertName: "Equipo de Seguridad",
      expertImagePath: 'lib/assets/robot.png',
      noticias: [
        Noticia(
          title: "Caso Reciente de Acoso en Redes",
          description: "Un análisis del modus operandi.",
          contenidoCompleto: "El reciente caso destapado por las autoridades muestra cómo los acosadores utilizan perfiles falsos en plataformas de juegos para ganarse la confianza de los menores, solicitando información personal de forma gradual.",
        ),
        Noticia(
          title: "Cómo Identificar las Señales de Alerta",
          description: "Guía para padres y educadores.",
          contenidoCompleto: "Las señales de alerta incluyen cambios de comportamiento en el menor, secretismo con sus dispositivos, recibir regalos de desconocidos o usar un lenguaje que no es propio de su edad. Es crucial mantener una comunicación abierta.",
        ),
      ],
    ),
    Topic(
      title: "Phishing",
      expertName: "Equipo de Seguridad",
      expertImagePath: 'lib/assets/robot.png',
      noticias: [
        Noticia(
          title: "El Engaño del Paquete Falso",
          description: "Cuidado con los SMS fraudulentos (Smishing).",
          contenidoCompleto: "Una nueva ola de ataques de 'smishing' utiliza mensajes de texto que afirman que un paquete no pudo ser entregado. El enlace adjunto dirige a una página falsa para robar datos bancarios.",
        ),
        Noticia(
          title: "Falsas Ofertas de Empleo en WhatsApp",
          description: "Una nueva táctica para robar datos.",
          contenidoCompleto: "Los estafadores envían mensajes masivos por WhatsApp ofreciendo trabajos con horarios flexibles y altos ingresos. El objetivo es dirigir a las víctimas a sitios web maliciosos para sustraer su información personal y financiera.",
        ),
      ],
    ),
    Topic(
      title: "Control Parental",
      expertName: "Equipo de Seguridad",
      expertImagePath: 'lib/assets/robot.png',
      noticias: [
        Noticia(
          title: "Herramientas Nativas de Control",
          description: "Aprovecha las opciones de iOS y Android.",
          contenidoCompleto: "Tanto iOS (Tiempo en Pantalla) como Android (Bienestar Digital y Family Link) ofrecen herramientas gratuitas y potentes para gestionar el tiempo de uso, restringir contenido y aprobar descargas de aplicaciones. Aprende a configurarlas.",
        ),
        Noticia(
          title: "Más Allá del Bloqueo: El Diálogo",
          description: "Por qué conversar es la mejor herramienta.",
          contenidoCompleto: "Aunque las herramientas de control son útiles, los expertos en seguridad infantil coinciden en que la mejor protección es un diálogo constante. Establecer acuerdos y explicar los porqués es más efectivo a largo plazo que una simple prohibición.",
        ),
      ],
    ),
    Topic(
      title: "Privacidad",
      expertName: "Equipo de Seguridad",
      expertImagePath: 'lib/assets/robot.png',
      noticias: [
        Noticia(
          title: "El Peligro de las Fotos con Uniforme",
          description: "Riesgos de compartir información sin querer.",
          contenidoCompleto: "Publicar fotos de los niños con el uniforme escolar puede revelar información sensible como el nombre del colegio y su ubicación. Se recomienda evitar este tipo de publicaciones en perfiles públicos para proteger su seguridad.",
        ),
        Noticia(
          title: "Revisa los Permisos de las Apps",
          description: "¿Por qué un juego necesita acceso a tus contactos?",
          contenidoCompleto: "Muchas aplicaciones solicitan permisos que no son necesarios para su funcionamiento, como acceso a la cámara, micrófono o contactos. Es fundamental revisar y gestionar estos permisos en los ajustes del teléfono para evitar la recopilación de datos innecesaria.",
        ),
        Noticia(
          title: "Contraseñas Seguras para Niños",
          description: "Crea frases secretas en lugar de palabras.",
          contenidoCompleto: "Enseña a tus hijos a crear contraseñas largas y fáciles de recordar usando una 'frase secreta' como 'MiPerroMaxCome5Galletas!'. Es más segura y memorable que una palabra corta y compleja.",
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    checkBluetoothSupport();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo realizar la llamada a $phoneNumber'),
        ),
      );
    }
  }

  void _showEmergencyCallSheet(BuildContext context) {
    const String phoneNumber = '+522222222222';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10),),),
              const SizedBox(height: 20),
              const Text('Llamada de Emergencia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
              const SizedBox(height: 8),
              const Text('Estás a punto de contactar a la Policía Cibernética.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey),),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _makePhoneCall(phoneNumber);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text('Llamar ahora', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
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
          "Educa y protege a los menores",
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
          // CAMBIO CLAVE: Reducimos el valor para dar más altura a las tarjetas
          childAspectRatio: 1.1, 
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TopicDetailScreen(topic: topics[index]),
                ),
              );
            },
            child: FeatureCard(feature: features[index]),
          );
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
          _buildNavItem(Icons.info, 'Guía', 2),
          _buildNavItem(Icons.call, 'Emergencias', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _showEmergencyCallSheet(context);
        } if (index==2){
          Navigator.push(
             context,
            MaterialPageRoute(
              builder: (context) =>  NewsScreen( 
              ),
            )
          );
        } 
        else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: isSelected ? const Color(0xFF2D3E8B) : Colors.grey,),
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
