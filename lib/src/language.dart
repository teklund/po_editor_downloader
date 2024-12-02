/// Language DTO from PO Editor
final class Language {
  /// Name of language. example "English"
  final String name;

  /// Code of language. Example "en"
  final String code;

  /// Number of translated terms
  final int translations;

  /// Percent of translated terms
  final double percentage;

  /// When language was last updated
  final String updated;

  /// Construct language dto from parameters
  const Language({
    required this.name,
    required this.code,
    required this.translations,
    required this.percentage,
    required this.updated,
  });

  /// Construct language from json
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'],
      code: json['code'],
      translations: json['translations'],
      percentage: json['percentage'].toDouble(),
      updated: json['updated'],
    );
  }

  @override
  String toString() {
    return 'Language(name: $name, code: $code, translations: $translations, percentage: $percentage, updated: $updated)';
  }
}
