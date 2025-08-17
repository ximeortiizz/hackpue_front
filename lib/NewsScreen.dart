import 'package:app_1/ActivityScreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // Necesario para ImageFilter (efecto glass)

// Modelo de datos para cada artículo de noticia
class NewsArticle {
  final String title;
  final String link;
  final String summary;
  final String date;
  final Color color;

  NewsArticle({
    required this.title,
    required this.link,
    required this.summary,
    required this.date,
    required this.color,
  });
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<Color> cardColors = [
    const Color(0xFFFEF3C7), // Amarillo Pálido
    const Color(0xFFE0E7FF), // Lavanda Suave
    const Color(0xFFFEE2E2), // Rosa Claro
    const Color(0xFFD1FAE5), // Menta Verde
  ];

  late final List<NewsArticle> articles;

  @override
  void initState() {
    super.initState();
    articles = [
      NewsArticle(
        title: 'Vulnerabilidad crítica en OpenSSL afecta a servidores de todo el mundo',
        summary: 'Una nueva falla de seguridad en la popular librería de criptografía OpenSSL podría permitir a los atacantes ejecutar código de forma remota...',
        link: 'https://www.incibe.es/protege-tu-empresa/avisos-seguridad',
        date: '15 de Agosto, 2025',
        color: cardColors[0],
      ),
      NewsArticle(
        title: 'Aumento de ataques de Phishing dirigidos a usuarios en la nube',
        summary: 'Los ciberdelincuentes están utilizando tácticas cada vez más sofisticadas para robar credenciales de acceso a plataformas como Microsoft 365...',
        link: 'https://www.xataka.com/seguridad/microsoft-365-se-ha-convertido-objetivo-numero-uno-phishing-laboral-este-motivo',
        date: '14 de Agosto, 2025',
        color: cardColors[1],
      ),
      NewsArticle(
        title: '¿Es seguro el "smishing"? Cómo protegerte de estafas por SMS',
        summary: 'El "smishing" o phishing por SMS está en auge. Los estafadores envían mensajes de texto falsos haciéndose pasar por bancos o empresas...',
        link: 'https://www.osi.es/es/actualidad/blog/2023/04/21/que-es-el-smishing-y-como-puedes-protegerte',
        date: '13 de Agosto, 2025',
        color: cardColors[2],
      ),
    ];

    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Noticias importantes', style: TextStyle( fontSize:20 , color: Colors.black,),),
        actions: [
          IconButton(icon: const Icon(Icons.apps_rounded, color: Colors.black), onPressed: () {},),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                double scale = (1 - (_currentPage - index).abs() * 0.1).clamp(0.88, 1.0);
                return Transform.scale(
                  scale: scale,
                  child: NewsCard(article: articles[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({Key? key, required this.article}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo lanzar $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: article.color,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 25, spreadRadius: -10, offset: Offset(0, 10),),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.08), borderRadius: BorderRadius.circular(15),), child: const Text('CIBERSEGURIDAD', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 11),),),
          const SizedBox(height: 16),
          Text(article.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontSize: 24, height: 1.25, fontWeight: FontWeight.bold),),
          const SizedBox(height: 8),

          // --- ENLACE "CONOCER MÁS..." ---
          GestureDetector(
            onTap: () => _launchURL(article.link),
            child: Text(
              "Conocer más...",
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Text(article.date, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13),),
          const SizedBox(height: 20),
          Text(article.summary, maxLines: 5, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 15, height: 1.5,),),
          
          const Spacer(), // Empuja la sección de abajo al fondo

          // --- SECCIÓN INFERIOR CONSERVADA ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF9D4D5),
                child: Icon(Icons.priority_high_rounded, color: Colors.red.shade800, size: 22,),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Guía para hablar", style: TextStyle(color: Colors.grey.shade700, fontSize: 12),),
                    Text("del tema...", style: TextStyle(color: Colors.grey.shade700, fontSize: 12),),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navegación corregida
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityScreen()));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        "Ver Guía", // Texto más descriptivo
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}