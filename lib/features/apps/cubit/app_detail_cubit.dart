import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppDetailStatus { loading, ready, error }

class AppDetailState extends Equatable {
  const AppDetailState({
    this.status = AppDetailStatus.loading,
    this.app,
    this.analytics,
    this.products = const [],
    this.error = '',
  });

  final AppDetailStatus status;
  final DeveloperApp? app;
  final AppAnalytics? analytics;
  final List<ApiProduct> products; // resolved product objects for this app
  final String error;

  @override
  List<Object?> get props => [status, app, analytics, products, error];
}

class AppDetailCubit extends Cubit<AppDetailState> {
  AppDetailCubit(this._apps, this._analytics, this._catalog)
      : super(const AppDetailState());

  final AppsRepository _apps;
  final AnalyticsRepository _analytics;
  final CatalogRepository _catalog;

  Future<void> load(String appId) async {
    emit(const AppDetailState());
    try {
      final app = await _apps.getApp(appId);
      final allProducts = await _catalog.getProducts();
      final products =
          allProducts.where((p) => app.productIds.contains(p.id)).toList();
      AppAnalytics? analytics;
      if (app.status == AppStatus.approved) {
        analytics = await _analytics.getAppAnalytics(appId);
      }
      emit(AppDetailState(
        status: AppDetailStatus.ready,
        app: app,
        analytics: analytics,
        products: products,
      ));
    } catch (e) {
      emit(AppDetailState(status: AppDetailStatus.error, error: '$e'));
    }
  }
}
