import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CatalogStatus { loading, ready, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.products = const [],
    this.error = '',
  });

  final CatalogStatus status;
  final List<ApiProduct> products;
  final String error;

  List<ApiProduct> get featured => products.where((p) => p.featured).toList();

  Map<String, List<ApiProduct>> get byCategory {
    final map = <String, List<ApiProduct>>{};
    for (final p in products) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }

  CatalogState copyWith({
    CatalogStatus? status,
    List<ApiProduct>? products,
    String? error,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, products, error];
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());

  final CatalogRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CatalogStatus.loading));
    try {
      final products = await _repository.getProducts();
      emit(state.copyWith(status: CatalogStatus.ready, products: products));
    } catch (e) {
      emit(state.copyWith(status: CatalogStatus.error, error: '$e'));
    }
  }
}
