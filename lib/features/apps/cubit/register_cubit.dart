import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RegisterStatus { loadingProducts, ready, submitting, success, error }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.loadingProducts,
    this.products = const [],
    this.created,
    this.error = '',
  });

  final RegisterStatus status;
  final List<ApiProduct> products;
  final DeveloperApp? created;
  final String error;

  RegisterState copyWith({
    RegisterStatus? status,
    List<ApiProduct>? products,
    DeveloperApp? created,
    String? error,
  }) {
    return RegisterState(
      status: status ?? this.status,
      products: products ?? this.products,
      created: created ?? this.created,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, products, created, error];
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._catalog, this._apps) : super(const RegisterState());

  final CatalogRepository _catalog;
  final AppsRepository _apps;

  Future<void> loadProducts() async {
    try {
      final products = await _catalog.getProducts();
      emit(state.copyWith(status: RegisterStatus.ready, products: products));
    } catch (e) {
      emit(state.copyWith(status: RegisterStatus.error, error: '$e'));
    }
  }

  /// Restricted = any selected product is non-public → goes to approval queue.
  bool _isRestricted(List<String> productIds) {
    return state.products
        .where((p) => productIds.contains(p.id))
        .any((p) => p.visibility != ProductVisibility.public);
  }

  Future<void> submit({
    required String developerEmail,
    required String name,
    required String description,
    required List<String> productIds,
  }) async {
    emit(state.copyWith(status: RegisterStatus.submitting));
    try {
      final app = await _apps.registerApp(
        developerEmail: developerEmail,
        name: name,
        description: description,
        productIds: productIds,
        restricted: _isRestricted(productIds),
      );
      emit(state.copyWith(status: RegisterStatus.success, created: app));
    } catch (e) {
      emit(state.copyWith(status: RegisterStatus.error, error: '$e'));
    }
  }
}
