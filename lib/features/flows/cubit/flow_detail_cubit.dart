import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FlowDetailStatus { loading, ready, error }

class FlowDetailState extends Equatable {
  const FlowDetailState({
    this.status = FlowDetailStatus.loading,
    this.scenario,
    this.shownSteps = 0,
    this.running = false,
    this.error = '',
  });

  final FlowDetailStatus status;
  final FlowScenario? scenario;
  final int shownSteps; // number of steps with a revealed response
  final bool running; // the step at index [shownSteps] is executing
  final String error;

  bool get isComplete =>
      scenario != null && shownSteps >= scenario!.steps.length;

  FlowDetailState copyWith({
    FlowDetailStatus? status,
    FlowScenario? scenario,
    int? shownSteps,
    bool? running,
    String? error,
  }) {
    return FlowDetailState(
      status: status ?? this.status,
      scenario: scenario ?? this.scenario,
      shownSteps: shownSteps ?? this.shownSteps,
      running: running ?? this.running,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, scenario, shownSteps, running, error];
}

class FlowDetailCubit extends Cubit<FlowDetailState> {
  FlowDetailCubit(this._repo) : super(const FlowDetailState());

  final FlowsRepository _repo;

  Future<void> load(String id) async {
    emit(const FlowDetailState());
    try {
      emit(FlowDetailState(
          status: FlowDetailStatus.ready, scenario: await _repo.get(id)));
    } catch (e) {
      emit(FlowDetailState(status: FlowDetailStatus.error, error: '$e'));
    }
  }

  Future<void> advance() async {
    final s = state;
    if (s.scenario == null || s.running || s.isComplete) return;
    emit(s.copyWith(running: true)); // current step "calls" the API
    await Future<void>.delayed(const Duration(milliseconds: 650));
    emit(s.copyWith(shownSteps: s.shownSteps + 1, running: false));
  }

  void reset() => emit(state.copyWith(shownSteps: 0, running: false));
}
