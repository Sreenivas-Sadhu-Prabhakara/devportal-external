import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProductStatus { loading, ready, error }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.loading,
    this.product,
    this.error = '',
  });

  final ProductStatus status;
  final ApiProduct? product;
  final String error;

  ProductState copyWith({
    ProductStatus? status,
    ApiProduct? product,
    String? error,
  }) {
    return ProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, product, error];
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repository) : super(const ProductState());

  final CatalogRepository _repository;

  Future<void> load(String id) async {
    emit(const ProductState(status: ProductStatus.loading));
    try {
      final product = await _repository.getProduct(id);
      emit(ProductState(status: ProductStatus.ready, product: product));
    } catch (e) {
      emit(ProductState(status: ProductStatus.error, error: '$e'));
    }
  }
}
