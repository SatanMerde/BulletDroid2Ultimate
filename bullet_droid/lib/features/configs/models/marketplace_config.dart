class MarketplaceConfig {
  final String id;
  final String name;
  final String author;
  final String description;
  final String downloadUrl;
  final List<String> tags;
  final String version;

  MarketplaceConfig({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.downloadUrl,
    required this.tags,
    required this.version,
  });

  factory MarketplaceConfig.fromJson(Map<String, dynamic> json) {
    return MarketplaceConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      downloadUrl: json['downloadUrl'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      version: json['version'] as String,
    );
  }
}
