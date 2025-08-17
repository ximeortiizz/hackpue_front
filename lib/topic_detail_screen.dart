
import 'package:flutter/material.dart';

class Noticia {
  final String title;
  final String description;
  final String contenidoCompleto; 
  Noticia({
    required this.title,
    required this.description,
    required this.contenidoCompleto,
  });
}

class Topic {
  final String title;
  final String expertName;
  final String expertImagePath;
  final List<Noticia> noticias;

  Topic({
    required this.title,
    required this.expertName,
    required this.expertImagePath,
    required this.noticias,
  });
}

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    const mainGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(13, 71, 161, 1),
        Colors.lightBlue,
        Color.fromRGBO(102, 187, 106, 1),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: Colors.transparent, 
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: mainGradient,
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                title: Text(
                  widget.topic.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                background: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0, left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: AssetImage(widget.topic.expertImagePath),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.topic.expertName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          // --- Lista de Noticias (Acordeón) ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final noticia = widget.topic.noticias[index];
                return _buildNewsCard(noticia, index);
              },
              childCount: widget.topic.noticias.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Noticia noticia, int index) {
    bool isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(noticia.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(noticia.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(height: 30),
              Text(
                noticia.contenidoCompleto,
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.black.withOpacity(0.7), height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}