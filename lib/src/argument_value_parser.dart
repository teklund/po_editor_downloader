/// A utility class for parsing command-line arguments and extracting values
/// for specific options.
sealed class ArgumentValueParser {
  /// Parses command-line arguments to extract the value of a specific option.
  ///
  /// This method searches for an option with the given `optionName` in the
  /// provided list of `args`. If the option is found, its value is extracted
  /// and returned. If the option is not found, `null` is returned.
  ///
  /// The option is expected to be in the format `--optionName=value`.
  /// For example, if `optionName` is `'files_path'`, the method would search
  /// for an argument like `'--files_path=path/to/output'`.
  ///
  /// **Parameters:**
  /// - `optionName`: The name of the option to search for.
  /// - `args`: The list of command-line arguments.
  ///
  /// **Returns:**
  /// The value of the option if found, or `null` if not found.
  static String? parse(String optionName, List<String> args) {
    for (final arg in args) {
      if (arg.contains('--$optionName=')) {
        return arg.replaceAll('--$optionName=', '').replaceAll('"', '').trim();
      }
    }
    return null;
  }
}
