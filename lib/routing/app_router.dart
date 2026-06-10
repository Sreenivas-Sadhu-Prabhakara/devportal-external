import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_cubit.dart';
import '../auth/sign_in_page.dart';
import '../features/apps/cubit/app_detail_cubit.dart';
import '../features/apps/cubit/apps_cubit.dart';
import '../features/apps/cubit/register_cubit.dart';
import '../features/apps/pages/app_detail_page.dart';
import '../features/apps/pages/dashboard_page.dart';
import '../features/apps/pages/register_app_page.dart';
import '../features/catalog/cubit/catalog_cubit.dart';
import '../features/catalog/cubit/product_cubit.dart';
import '../features/catalog/pages/catalog_page.dart';
import '../features/catalog/pages/home_page.dart';
import '../features/catalog/pages/product_detail_page.dart';
import '../features/flows/cubit/flow_detail_cubit.dart';
import '../features/flows/cubit/flows_cubit.dart';
import '../features/flows/pages/flow_detail_page.dart';
import '../features/flows/pages/flows_list_page.dart';
import 'app_shell.dart';
import 'go_router_refresh.dart';

const _protected = {'/dashboard', '/register'};
bool _isProtected(String loc) =>
    _protected.contains(loc) || loc.startsWith('/apps/');

GoRouter buildRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final signedIn = auth.state.signedIn;
      if (_isProtected(loc) && !signedIn) {
        return '/signin?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (loc == '/signin' && signedIn) return '/dashboard';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  CatalogCubit(ctx.read<CatalogRepository>())..load(),
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  CatalogCubit(ctx.read<CatalogRepository>())..load(),
              child: const CatalogPage(),
            ),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => BlocProvider(
              create: (ctx) => ProductCubit(ctx.read<CatalogRepository>())
                ..load(state.pathParameters['id']!),
              child: const ProductDetailPage(),
            ),
          ),
          GoRoute(
            path: '/flows',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  FlowsCubit(ctx.read<FlowsRepository>())..load(),
              child: const FlowsListPage(),
            ),
          ),
          GoRoute(
            path: '/flows/:id',
            builder: (context, state) => BlocProvider(
              create: (ctx) => FlowDetailCubit(ctx.read<FlowsRepository>())
                ..load(state.pathParameters['id']!),
              child: const FlowDetailPage(),
            ),
          ),
          GoRoute(
            path: '/signin',
            builder: (context, state) =>
                SignInPage(from: state.uri.queryParameters['from']),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => BlocProvider(
              create: (ctx) => AppsCubit(ctx.read<AppsRepository>())
                ..load(auth.state.email),
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => BlocProvider(
              create: (ctx) => RegisterCubit(
                ctx.read<CatalogRepository>(),
                ctx.read<AppsRepository>(),
              )..loadProducts(),
              child: const RegisterAppPage(),
            ),
          ),
          GoRoute(
            path: '/apps/:id',
            builder: (context, state) => BlocProvider(
              create: (ctx) => AppDetailCubit(
                ctx.read<AppsRepository>(),
                ctx.read<AnalyticsRepository>(),
                ctx.read<CatalogRepository>(),
              )..load(state.pathParameters['id']!),
              child: const AppDetailPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
