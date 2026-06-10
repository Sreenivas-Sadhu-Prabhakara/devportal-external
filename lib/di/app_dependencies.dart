import 'package:devportal_shared/devportal_shared.dart';

/// Composition root. Selects the data source via
/// `--dart-define=DATA_SOURCE=mock|live`. Today only `mock` is wired; the live
/// Drupal-backed repositories land in Phase 4 behind the same interfaces.
class AppDependencies {
  AppDependencies({
    required this.catalog,
    required this.apps,
    required this.analytics,
    required this.flows,
    required this.dataSource,
  });

  final CatalogRepository catalog;
  final AppsRepository apps;
  final AnalyticsRepository analytics;
  final FlowsRepository flows;
  final String dataSource;

  static const _source = String.fromEnvironment(
    'DATA_SOURCE',
    defaultValue: 'mock',
  );

  factory AppDependencies.bootstrap() {
    switch (_source) {
      // case 'live': // TODO(phase-4): Drupal JSON:API-backed repositories.
      default:
        return AppDependencies(
          catalog: MockCatalogRepository(),
          apps: MockAppsRepository(),
          analytics: MockAnalyticsRepository(),
          flows: MockFlowsRepository(),
          dataSource: 'mock',
        );
    }
  }
}
