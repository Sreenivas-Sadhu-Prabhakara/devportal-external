import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/content_wrap.dart';
import '../cubit/catalog_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state.status == CatalogStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == CatalogStatus.error) {
          return _Error(message: state.error);
        }
        final categories = state.byCategory;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroSpotlight(
                eyebrow: 'Developer Platform',
                title: 'Build with our APIs.',
                tagline:
                    'Browse the catalog, register an app, get your keys and go '
                    'live in minutes. Secure, governed and ready for production.',
                accent: AppColors.accent,
                ctaLabel: 'Browse the catalog',
                onCta: () => context.go('/catalog'),
                secondaryLabel: 'View featured',
                onSecondary: () => context.go('/catalog'),
              ),
              const SizedBox(height: 8),
              ContentWrap(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    if (state.featured.isNotEmpty) ...[
                      Carousel(
                        title: 'Featured APIs',
                        actionLabel: 'See all',
                        onAction: () => context.go('/catalog'),
                        children: [
                          for (final p in state.featured)
                            _card(context, p),
                        ],
                      ),
                      const SizedBox(height: 44),
                    ],
                    for (final entry in categories.entries) ...[
                      Carousel(
                        title: entry.key,
                        children: [
                          for (final p in entry.value) _card(context, p),
                        ],
                      ),
                      const SizedBox(height: 44),
                    ],
                    const _CtaBand(),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, ApiProduct p) {
    return PosterCard(
      title: p.name,
      subtitle: p.tagline,
      category: p.category,
      version: p.version,
      accent: AppColors.categoryColor(p.colorIndex),
      onTap: () => context.go('/product/${p.id}'),
    );
  }
}

class _CtaBand extends StatelessWidget {
  const _CtaBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            AppColors.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to integrate?',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Register an application to get API keys and start calling.',
                  style: TextStyle(color: AppColors.textLo),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          FilledButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Get API keys'),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 36),
          const SizedBox(height: 12),
          Text('Something went wrong',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: AppColors.textFaint)),
        ],
      ),
    );
  }
}
