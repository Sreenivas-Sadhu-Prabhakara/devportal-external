import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';

/// Persistent cinematic top-nav chrome wrapping every page.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const _TopNav(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        const PortalMark(size: 30),
                        const SizedBox(width: 12),
                        Text(
                          'DEVPORTAL',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                _NavLink('Home', '/', active: location == '/'),
                _NavLink('Catalog', '/catalog',
                    active: location.startsWith('/catalog') ||
                        location.startsWith('/product')),
                _NavLink('Flows', '/flows',
                    active: location.startsWith('/flows')),
                const Spacer(),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, auth) {
                    if (!auth.signedIn) {
                      return FilledButton(
                        onPressed: () => context.go('/signin'),
                        child: const Text('Sign in'),
                      );
                    }
                    return Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const Icon(Icons.apps_rounded, size: 18),
                          label: const Text('My apps'),
                          style: TextButton.styleFrom(
                            foregroundColor: location.startsWith('/dashboard') ||
                                    location.startsWith('/apps') ||
                                    location.startsWith('/register')
                                ? AppColors.textHi
                                : AppColors.textMid,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ProfileMenu(auth: auth),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.to, {required this.active});

  final String label;
  final String to;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => context.go(to),
        style: TextButton.styleFrom(
          foregroundColor: active ? AppColors.textHi : AppColors.textMid,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final initials = auth.displayName.isNotEmpty
        ? auth.displayName
            .trim()
            .split(' ')
            .map((p) => p.isEmpty ? '' : p[0])
            .take(2)
            .join()
        : 'U';
    return PopupMenuButton<String>(
      tooltip: auth.email,
      offset: const Offset(0, 48),
      color: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.line),
      ),
      onSelected: (v) {
        if (v == 'signout') context.read<AuthCubit>().signOut();
        if (v == 'apps') context.go('/dashboard');
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auth.displayName,
                  style: const TextStyle(
                      color: AppColors.textHi, fontWeight: FontWeight.w700)),
              Text(auth.email,
                  style:
                      const TextStyle(color: AppColors.textFaint, fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'apps', child: Text('My apps')),
        const PopupMenuItem(value: 'signout', child: Text('Sign out')),
      ],
      child: CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.accent,
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
