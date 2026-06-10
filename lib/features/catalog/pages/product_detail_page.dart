import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/format.dart';
import '../../../widgets/content_wrap.dart';
import '../cubit/product_cubit.dart';
import '../widgets/markdown_lite.dart';
import '../widgets/tryit_console.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state.status == ProductStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductStatus.error || state.product == null) {
          return Center(
            child: Text('Could not load product.\n${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textFaint)),
          );
        }
        final p = state.product!;
        final accent = AppColors.categoryColor(p.colorIndex);
        return DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(product: p, accent: accent),
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: AppSpacing.maxContent),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: AppColors.accent,
                          indicatorWeight: 2.5,
                          labelColor: AppColors.textHi,
                          unselectedLabelColor: AppColors.textLo,
                          labelStyle:
                              TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                          tabs: [
                            Tab(text: 'Overview'),
                            Tab(text: 'Documentation'),
                            Tab(text: 'Try it'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(product: p, accent: accent),
                    _DocsTab(product: p),
                    _TryItTab(product: p),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product, required this.accent});
  final ApiProduct product;
  final Color accent;

  (String, BadgeTone) get _visibility => switch (product.visibility) {
        ProductVisibility.public => ('Public', BadgeTone.success),
        ProductVisibility.partner => ('Partner', BadgeTone.warn),
        ProductVisibility.internal => ('Internal', BadgeTone.info),
      };

  @override
  Widget build(BuildContext context) {
    final (visLabel, visTone) = _visibility;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.28), AppColors.canvas],
          stops: const [0, 0.7],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContent),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/catalog'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Catalog'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMid,
                      padding: EdgeInsets.zero),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: Text(product.name,
                          style: Theme.of(context).textTheme.displaySmall),
                    ),
                    const SizedBox(width: 14),
                    StatusBadge(product.version, tone: BadgeTone.accent),
                    const SizedBox(width: 8),
                    StatusBadge(visLabel, tone: visTone),
                  ],
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(product.tagline,
                      style: const TextStyle(
                          color: AppColors.textMid, fontSize: 16, height: 1.5)),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Register an app'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.product, required this.accent});
  final ApiProduct product;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About this API',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(product.description,
                          style: const TextStyle(
                              color: AppColors.textLo,
                              fontSize: 15.5,
                              height: 1.6)),
                      const SizedBox(height: 32),
                      Text('Endpoints',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      for (final e in product.endpoints)
                        _EndpointRow(endpoint: e),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: _PlanCard(product: product, accent: accent),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({required this.endpoint});
  final ApiEndpoint endpoint;

  Color get _color => switch (endpoint.method) {
        'GET' => AppColors.info,
        'POST' => AppColors.success,
        'PATCH' => AppColors.warn,
        'DELETE' => AppColors.danger,
        _ => AppColors.textLo,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(endpoint.method,
                style: TextStyle(
                    color: _color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(endpoint.path,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.5,
                    color: AppColors.textHi)),
          ),
          Flexible(
            child: Text(endpoint.summary,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textFaint, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.product, required this.accent});
  final ApiProduct product;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Text('${product.tierName} tier',
                  style: const TextStyle(
                      color: AppColors.textHi,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          _kv('Quota',
              '${formatInt(product.quotaLimit)} / ${product.quotaInterval}'),
          _kv('Base path', product.basePath),
          _kv('Version', product.version),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.canvasAlt,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: AppColors.textFaint),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Billing arrives in a later phase — free today.',
                      style: TextStyle(
                          color: AppColors.textFaint, fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: AppColors.textFaint, fontSize: 13)),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

class _DocsTab extends StatelessWidget {
  const _DocsTab({required this.product});
  final ApiProduct product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ContentWrap(
        maxWidth: 860,
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 64),
          child: MarkdownLite(product.docsMarkdown),
        ),
      ),
    );
  }
}

class _TryItTab extends StatelessWidget {
  const _TryItTab({required this.product});
  final ApiProduct product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ContentWrap(
        maxWidth: 860,
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('Try it', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Send a live request using one of your app keys. Responses below '
              'are representative samples.',
              style: TextStyle(color: AppColors.textLo),
            ),
            const SizedBox(height: 20),
            TryItConsole(product: product),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}
