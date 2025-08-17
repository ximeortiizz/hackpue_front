import 'package:app_1/ActivityScreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class NewsArticle {
  String title;
  String link;
  String summary;
  String date;
  String explicacion;
  String actividadSugerida;

  NewsArticle({
    required this.title,
    required this.link,
    required this.summary,
    required this.date,
    required this.explicacion,
    required this.actividadSugerida,
  });
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

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
        explicacion: "Una vulnerabilidad es como una puerta sin cerradura en un programa. Si un 'malo' la encuentra, puede entrar sin permiso. Por eso es muy importante 'poner la cerradura' actualizando los programas.",
        actividadSugerida: "Juego de las Actualizaciones: Dibuja un castillo con varias puertas. Explica que cada actualización es un guardián nuevo que protege una puerta. Cada vez que 'actualicen' (pongan un guardián), el castillo estará más seguro.",
      ),
      NewsArticle(
        title: 'Aumento de ataques de Phishing dirigidos a usuarios en la nube',
        summary: 'Los ciberdelincuentes están utilizando tácticas cada vez más sofisticadas para robar credenciales de acceso a plataformas como Microsoft 350...',
        link: 'https://www.xataka.com/seguridad/microsoft-365-se-ha-convertido-objetivo-numero-uno-phishing-laboral-este-motivo',
        date: '14 de Agosto, 2025',
        explicacion: "El phishing es como un lobo disfrazado de oveja. Son correos o mensajes que parecen de alguien que conoces (como un amigo o un juego), pero en realidad es un 'malo' que quiere robar tus contraseñas.",
        actividadSugerida: "Juego de Roles: 'El Pescador de Secretos'. Crea tarjetas con mensajes: unos seguros y otros sospechosos (p. ej., '¡Ganaste un premio! Haz clic aquí'). Pídele a tu hijo que 'pesque' solo los mensajes seguros.",
      ),
      NewsArticle(
        title: '¿Es seguro el "smishing"? Cómo protegerte de estafas por SMS',
        summary: 'El "smishing" o phishing por SMS está en auge. Los estafadores envían mensajes de texto falsos haciéndose pasar por bancos o empresas...',
        link: 'https://www.osi.es/es/actualidad/blog/2023/04/21/que-es-el-smishing-y-como-puedes-protegerte',
        date: '13 de Agosto, 2025',
        explicacion: "El smishing es muy parecido al phishing, pero ocurre en los mensajes de texto del teléfono. A veces envían enlaces peligrosos que no debemos abrir, incluso si parecen importantes.",
        actividadSugerida: "La Regla de los 3 Pasos: 1. ¿Conozco a quien me envía esto? 2. ¿Me pide que haga algo rápido o me ofrece algo demasiado bueno? 3. Si dudo, pregunto a un adulto antes de tocar nada. Practica con mensajes de ejemplo.",
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Noticias importantes', style: TextStyle(fontSize:20, color: Colors.white, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(icon: const Icon(Icons.apps_rounded, color: Colors.white), onPressed: () {},),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    double diff = index - _currentPage;
                    final double scale = (1 - diff.abs() * 0.1).clamp(0.88, 1.0);
                    final double yOffset = diff.abs() * 30.0;
                    final double rotation = diff * -0.1;

                    return Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: scale,
                          child: NewsCard(article: articles[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: -10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
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
          Text(
            article.date,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            article.summary,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.3),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Guía para hablar", style: TextStyle(color: Colors.grey.shade700, fontSize: 12,),),
                    Text("del tema...", style: TextStyle(color: Colors.grey.shade700, fontSize: 12,),),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityScreen(
                        explicacion: article.explicacion,
                        actividadSugerida: article.actividadSugerida,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.black.withOpacity(0.2),),
                      ),
                      child: Text("Ver Aquí", style: TextStyle(color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 14,),),
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