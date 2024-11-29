final class Language {
  final String name;
  final String code;
  final int translations;
  final double percentage;
  final String updated;

  const Language({
    required this.name,
    required this.code,
    required this.translations,
    required this.percentage,
    required this.updated,
  });

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
