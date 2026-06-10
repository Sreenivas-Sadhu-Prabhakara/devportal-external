import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/content_wrap.dart';
import '../cubit/catalog_cubit.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state.status == CatalogStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = ['All', ...state.byCategory.keys];
        final filtered = state.products.where((p) {
          final matchesCat = _category == 'All' || p.category == _category;
          final q = _query.toLowerCase();
          final matchesQuery = q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.tagline.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q);
          return matchesCat && matchesQuery;
        }).toList();

        return SingleChildScrollView(
          child: ContentWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('API Catalog',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                const Text(
                  'Every API product available to you. Open one to read the '
                  'docs and try it live.',
                  style: TextStyle(color: AppColors.textLo, fontSize: 16),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 420,
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search APIs…',
                      prefixIcon:
                          Icon(Icons.search_rounded, color: AppColors.textFaint),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in categories)
                      _FilterChip(
                        label: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text('No APIs match your search.',
                          style: TextStyle(color: AppColors.textFaint)),
                    ),
                  )
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final p in filtered)
                        PosterCard(
                          title: p.name,
                          subtitle: p.tagline,
                          category: p.category,
                          version: p.version,
                          accent: AppColors.categoryColor(p.colorIndex),
                          onTap: () => context.go('/product/${p.id}'),
                        ),
                    ],
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMid,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
