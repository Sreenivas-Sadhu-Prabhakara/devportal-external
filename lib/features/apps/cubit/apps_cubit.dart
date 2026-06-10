import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppsStatus { loading, ready, error }

class AppsState extends Equatable {
  const AppsState({
    this.status = AppsStatus.loading,
    this.apps = const [],
    this.error = '',
  });

  final AppsStatus status;
  final List<DeveloperApp> apps;
  final String error;

  @override
  List<Object?> get props => [status, apps, error];
}

class AppsCubit extends Cubit<AppsState> {
  AppsCubit(this._repository) : super(const AppsState());

  final AppsRepository _repository;

  Future<void> load(String email) async {
    emit(const AppsState());
    try {
      final apps = await _repository.getApps(email);
      emit(AppsState(status: AppsStatus.ready, apps: apps));
    } catch (e) {
      emit(AppsState(status: AppsStatus.error, error: '$e'));
    }
  }
}
