/// The supported naming conventions for string conversion.
enum NamingConvention {
  /// No conversion — keys are used as-is from POEditor
  none,

  /// camelCase — e.g. `helloWorld`
  camelCase,

  /// PascalCase — e.g. `HelloWorld`
  pascalCase,

  /// snake_case — e.g. `hello_world`
  snakeCase,

  /// CONSTANT_CASE — e.g. `HELLO_WORLD`
  constantCase,

  /// kebab-case — e.g. `hello-world`
  kebabCase,

  /// dot.case — e.g. `hello.world`
  dotCase,

  /// Title Case — e.g. `Hello World`
  titleCase,

  /// path/case — e.g. `hello/world`
  pathCase;

  /// Whether this convention produces valid Dart identifiers.
  ///
  /// Conventions that use hyphens, dots, spaces, or slashes as separators
  /// are not valid Dart identifiers and will cause issues with Flutter
  /// gen-l10n or slang code generation.
  bool get isDartCompatible => switch (this) {
        none => true,
        camelCase || pascalCase || snakeCase || constantCase => true,
        kebabCase || dotCase || titleCase || pathCase => false,
      };
}
