import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FlowsStatus { loading, ready, error }

class FlowsState extends Equatable {
  const FlowsState({
    this.status = FlowsStatus.loading,
    this.flows = const [],
    this.error = '',
  });

  final FlowsStatus status;
  final List<FlowScenario> flows;
  final String error;

  @override
  List<Object?> get props => [status, flows, error];
}

class FlowsCubit extends Cubit<FlowsState> {
  FlowsCubit(this._repo) : super(const FlowsState());

  final FlowsRepository _repo;

  Future<void> load() async {
    emit(const FlowsState());
    try {
      emit(FlowsState(status: FlowsStatus.ready, flows: await _repo.list()));
    } catch (e) {
      emit(FlowsState(status: FlowsStatus.error, error: '$e'));
    }
  }
}
