String? parseArguments(String optionName, List<String> args) {
  for (final arg in args) {
    if (arg.contains('--$optionName')) {
      return arg.replaceAll('--$optionName=', '').trim();
    }
  }
  return null;
}
