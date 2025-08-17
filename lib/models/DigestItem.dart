class DigestItem {
  final String id; // _id.$oid
  final String source;
  final String url;
  final String title;
  final String summary;
  final String published; // ISO8601 string
  final String category;
  final bool processed;
  final String digestEs;
  final List<String> kickstartersEs;
  final String riskLevel;
  final ActivityEs? activityEs;

  DigestItem({
    required this.id,
    required this.source,
    required this.url,
    required this.title,
    required this.summary,
    required this.published,
    required this.category,
    required this.processed,
    required this.digestEs,
    required this.kickstartersEs,
    required this.riskLevel,
    this.activityEs,
  });

  factory DigestItem.fromJson(Map<String, dynamic> json) {
    return DigestItem(
      id: json["_id"]["\$oid"] as String,
      source: json["source"] ?? "",
      url: json["url"] ?? "",
      title: json["title"] ?? "",
      summary: json["summary"] ?? "",
      published: json["published"] ?? "",
      category: json["category"] ?? "",
      processed: json["processed"] ?? false,
      digestEs: json["digest_es"] ?? "",
      kickstartersEs: (json["kickstarter_es"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      riskLevel: json["risk_level"] ?? "medio",
      activityEs: json["activity_es"] != null
          ? ActivityEs.fromJson(json["activity_es"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": {"\$oid": id},
      "source": source,
      "url": url,
      "title": title,
      "summary": summary,
      "published": published,
      "category": category,
      "processed": processed,
      "digest_es": digestEs,
      "kickstarter_es": kickstartersEs,
      "risk_level": riskLevel,
      "activity_es": activityEs?.toJson(),
    };
  }
}

class ActivityEs {
  final String titulo;
  final List<String> pasos;

  ActivityEs({required this.titulo, required this.pasos});

  factory ActivityEs.fromJson(Map<String, dynamic> json) {
    return ActivityEs(
      titulo: json["titulo"] ?? "",
      pasos: (json["pasos"] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"titulo": titulo, "pasos": pasos};
  }
}
