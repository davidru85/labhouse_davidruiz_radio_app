import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Conformance tests for Phase 1, Sub-task 1.5 (CI/CD Workflows & Git Hooks).
///
/// These assertions encode the contract from ADR-0008 (CI/CD strategy) and
/// ADR-0009 (git workflow). They intentionally check the *content* of the
/// workflow and hook files — not just their existence — so a stub file cannot
/// satisfy the GREEN step. Checks use plain `dart:io` string matching to avoid
/// adding a `yaml` dependency (none is declared in pubspec.yaml).
void main() {
  group('CI/CD & Git Hooks Conformance (Sub-task 1.5)', () {
    group('.github/workflows/ci.yml', () {
      final file = File('.github/workflows/ci.yml');

      test('exists and is not empty', () {
        expect(file.existsSync(), isTrue, reason: 'ci.yml must exist');
        expect(
          file.readAsStringSync().trim(),
          isNotEmpty,
          reason: 'ci.yml must not be empty',
        );
      });

      test('declares the four required jobs (ADR-0008)', () {
        final content = file.readAsStringSync();
        // ADR-0008 §Verification layers: analyze, test, build-android,
        // build-ios run as four parallel jobs and are the required status
        // checks on `main`.
        for (final job in const [
          'analyze:',
          'test:',
          'build-android:',
          'build-ios:',
        ]) {
          expect(
            content,
            contains(job),
            reason: 'ci.yml must declare the `$job` job (ADR-0008)',
          );
        }
      });

      test('passes config via --dart-define-from-file (ADR-0007/0008)', () {
        final content = file.readAsStringSync();
        expect(
          content,
          contains('--dart-define-from-file=config/app.json'),
          reason: 'build jobs must inject config via '
              '--dart-define-from-file=config/app.json (ADR-0008)',
        );
      });
    });

    group('lefthook.yml', () {
      final file = File('lefthook.yml');

      test('exists and is not empty', () {
        expect(file.existsSync(), isTrue, reason: 'lefthook.yml must exist');
        expect(
          file.readAsStringSync().trim(),
          isNotEmpty,
          reason: 'lefthook.yml must not be empty',
        );
      });

      test('runs format and analyze on pre-commit (ADR-0008)', () {
        final content = file.readAsStringSync();
        expect(
          content,
          contains('pre-commit:'),
          reason: 'lefthook.yml must define a pre-commit hook (ADR-0008)',
        );
        expect(
          content,
          contains('dart format'),
          reason: 'pre-commit must run `dart format` (ADR-0008)',
        );
        expect(
          content,
          contains('flutter analyze'),
          reason: 'pre-commit must run `flutter analyze` (ADR-0008)',
        );
      });

      test('runs tests on pre-push (ADR-0008)', () {
        final content = file.readAsStringSync();
        expect(
          content,
          contains('pre-push:'),
          reason: 'lefthook.yml must define a pre-push hook (ADR-0008)',
        );
        expect(
          content,
          contains('flutter test'),
          reason: 'pre-push must run `flutter test` (ADR-0008)',
        );
      });

      test('validates Conventional Commits on commit-msg (ADR-0009)', () {
        final content = file.readAsStringSync();
        // ADR-0009 §Enforcement: a regex-based commit-msg hook enforces
        // Conventional Commits without adding a Node dependency.
        expect(
          content,
          contains('commit-msg:'),
          reason: 'lefthook.yml must define a commit-msg hook (ADR-0009)',
        );
        expect(
          content,
          contains('feat|fix|refactor|test|docs|chore|style|perf'),
          reason: 'commit-msg must validate Conventional Commit types '
              '(ADR-0009)',
        );
      });
    });
  });
}
