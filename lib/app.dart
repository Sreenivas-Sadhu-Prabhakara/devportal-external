import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_cubit.dart';
import 'di/app_dependencies.dart';
import 'routing/app_router.dart';

/// Root widget. Provides repositories + auth, then a router-driven MaterialApp.
class DevPortalApp extends StatefulWidget {
  const DevPortalApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<DevPortalApp> createState() => _DevPortalAppState();
}

class _DevPortalAppState extends State<DevPortalApp> {
  late final AuthCubit _auth = AuthCubit();
  late final GoRouter _router = buildRouter(_auth);

  @override
  void dispose() {
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(value: widget.deps.catalog),
        RepositoryProvider<AppsRepository>.value(value: widget.deps.apps),
        RepositoryProvider<AnalyticsRepository>.value(
            value: widget.deps.analytics),
        RepositoryProvider<FlowsRepository>.value(value: widget.deps.flows),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: _auth,
        child: MaterialApp.router(
          title: 'Developer Portal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: _router,
        ),
      ),
    );
  }
}
