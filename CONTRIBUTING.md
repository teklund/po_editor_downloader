# Contributing to POEditor Downloader

Thank you for your interest in contributing to POEditor Downloader! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Code Style](#code-style)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) ^3.0.0 or higher
- [Flutter](https://flutter.dev/docs/get-started/install) (if testing with Flutter projects)
- Git

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/po_editor_downloader.git
   cd po_editor_downloader
   ```

3. **Install dependencies**:

   ```bash
   dart pub get
   ```

4. **Verify the setup** by running tests:

   ```bash
   dart test
   ```

5. **Test the CLI tool**:

   ```bash
   dart run bin/po_editor_downloader.dart --help
   ```

## Making Changes

### Branch Strategy

- Create a new branch for your feature/fix:

  ```bash
  git checkout -b feature/your-feature-name
  # or
  git checkout -b fix/issue-description
  ```

### Commit Messages

Follow conventional commit format:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `test:` for adding/updating tests
- `refactor:` for code refactoring
- `style:` for formatting changes

Example:

```text
feat: add support for filtering by multiple tags

- Allow JSON array input for tags parameter
- Update argument parser to handle array format
- Add validation for tag format
```

## Testing

### Running Tests

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Writing Tests

- Add tests for new features in the `test/` directory
- Follow the existing test structure and naming conventions
- Test both success and error cases
- Mock external dependencies (HTTP calls to POEditor API)

Example test structure:

```dart
import 'package:test/test.dart';
import 'package:po_editor_downloader/src/your_module.dart';

void main() {
  group('YourModule', () {
    test('should handle valid input correctly', () {
      // Arrange
      // Act
      // Assert
    });

    test('should throw exception for invalid input', () {
      // Test error cases
    });
  });
}
```

## Code Style

### Dart Style Guidelines

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code:

  ```bash
  dart format .
  ```

- Run the linter:

  ```bash
  dart analyze
  ```

### Code Organization

- Keep functions small and focused
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Follow the existing project structure:
  - `bin/` - Executable entry point
  - `lib/` - Main library code
  - `lib/src/` - Internal implementation
  - `test/` - Test files

### Documentation

- Add dartdoc comments for public classes and methods:

  ```dart
  /// Downloads translation files from POEditor API.
  /// 
  /// [apiToken] is your POEditor API token.
  /// [projectId] is the POEditor project ID.
  /// Returns a [Future] that completes when download is finished.
  Future<void> downloadTranslations(String apiToken, String projectId) async {
    // Implementation
  }
  ```

## Submitting Changes

### Before Submitting

1. **Format your code**:

   ```bash
   dart format .
   ```

2. **Run linter**:

   ```bash
   dart analyze
   ```

3. **Run tests**:

   ```bash
   dart test
   ```

4. **Update documentation** if needed

### Pull Request Process

1. **Push your changes** to your fork:

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub with:
   - Clear title and description
   - Reference any related issues
   - Include screenshots/examples if applicable

3. **Respond to feedback** and make requested changes

4. **Ensure CI passes** - all tests and checks must pass

### Pull Request Template

When creating a PR, please include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass locally
- [ ] Documentation updated
```

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Environment information**:
   - Dart/Flutter version
   - Operating system
   - POEditor Downloader version

2. **Steps to reproduce**:
   - Exact command used
   - Expected behavior
   - Actual behavior

3. **Additional context**:
   - Error messages
   - Log output
   - Screenshots if relevant

### Feature Requests

When requesting features:

1. **Describe the problem** the feature would solve
2. **Propose a solution** or approach
3. **Consider alternatives** and their trade-offs
4. **Provide examples** of how it would be used

## Getting Help

- 📖 Check the [README](README.md) for usage instructions
- 🐛 Search [existing issues](https://github.com/teklund/po_editor_downloader/issues) before creating new ones
- 💬 Ask questions in issue discussions
- 📧 Contact maintainers for security-related issues

## Recognition

Contributors will be acknowledged in:

- CHANGELOG.md for their contributions
- GitHub contributors list

Thank you for contributing to POEditor Downloader! 🎉
