import 'package:integration_test/integration_test_driver.dart';

/// Driver for running integration tests
/// This allows us to run tests with: 
/// flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/app_test.dart
Future<void> main() => integrationDriver();
