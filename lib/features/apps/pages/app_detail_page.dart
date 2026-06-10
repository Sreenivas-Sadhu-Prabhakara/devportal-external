import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/format.dart';
import '../../../widgets/content_wrap.dart';
import '../cubit/app_detail_cubit.dart';
import '../widgets/credential_field.dart';

class AppDetailPage extends StatelessWidget {
  const AppDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDetailCubit, AppDetailState>(
      builder: (context, state) {
        if (state.status == AppDetailStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == AppDetailStatus.error || state.app == null) {
          return Center(
            child: Text('Could not load app.\n${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textFaint)),
          );
        }
        final app = state.app!;
        return SingleChildScrollView(
          child: ContentWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                TextButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('My apps'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMid,
                      padding: EdgeInsets.zero),
                ),
                const SizedBox(height: 14),
                _AppHeader(app: app),
                const SizedBox(height: 32),
                if (app.status == AppStatus.pending)
                  const _PendingNotice()
                else
                  _Credentials(app: app),
                const SizedBox(height: 32),
                _Products(products: state.products),
                if (state.analytics != null) ...[
                  const SizedBox(height: 32),
                  _Analytics(analytics: state.analytics!),
                ],
                const SizedBox(height: 64),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.app});
  final DeveloperApp app;

  (String, BadgeTone) get _status => switch (app.status) {
        AppStatus.approved => ('Active', BadgeTone.success),
        AppStatus.pending => ('Pending approval', BadgeTone.warn),
        AppStatus.revoked => ('Revoked', BadgeTone.danger),
      };

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryColor(app.colorIndex);
    final (label, tone) = _status;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [
              accent.withValues(alpha: 0.9),
              accent.withValues(alpha: 0.4),
            ]),
          ),
          child: const Icon(Icons.apps_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(app.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: 12),
                  StatusBadge(label, tone: tone),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                app.description.isEmpty
                    ? 'Created ${app.createdAt}'
                    : '${app.description}  ·  Created ${app.createdAt}',
                style: const TextStyle(color: AppColors.textFaint, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingNotice extends StatelessWidget {
  const _PendingNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warn.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.warn.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.warn, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Awaiting approval',
                    style: TextStyle(
                        color: AppColors.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                  'This app includes a restricted product. API keys will be '
                  'issued automatically once the API team approves the request.',
                  style: TextStyle(color: AppColors.textLo, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Credentials extends StatelessWidget {
  const _Credentials({required this.app});
  final DeveloperApp app;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Credentials'),
        const SizedBox(height: 16),
        for (final c in app.credentials)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                    const StatusBadge('Approved', tone: BadgeTone.success),
                    const Spacer(),
                    Text('Never expires',
                        style: const TextStyle(
                            color: AppColors.textFaint, fontSize: 12.5)),
                  ],
                ),
                const SizedBox(height: 18),
                CredentialField(label: 'Consumer key', value: c.key),
                const SizedBox(height: 16),
                CredentialField(label: 'Consumer secret', value: c.secret),
              ],
            ),
          ),
      ],
    );
  }
}

class _Products extends StatelessWidget {
  const _Products({required this.products});
  final List<ApiProduct> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('API products'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final p in products)
              GestureDetector(
                onTap: () => context.go('/product/${p.id}'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.categoryColor(p.colorIndex),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(p.name,
                          style: const TextStyle(
                              color: AppColors.textMid,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Analytics extends StatelessWidget {
  const _Analytics({required this.analytics});
  final AppAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final total = analytics.statusBreakdown
        .fold<double>(0, (sum, p) => sum + p.value);
    final quotaFraction = analytics.quotaLimit == 0
        ? 0.0
        : analytics.quotaUsed / analytics.quotaLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Usage — last 14 days'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Total calls',
                value: formatInt(analytics.totalCalls),
                icon: Icons.show_chart_rounded,
                delta: '+12.4%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricTile(
                label: 'Avg latency',
                value: '${analytics.avgLatencyMs.round()} ms',
                icon: Icons.bolt_rounded,
                delta: '-3.1%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricTile(
                label: 'Error rate',
                value: '${analytics.errorRatePct.toStringAsFixed(2)}%',
                icon: Icons.error_outline_rounded,
                deltaPositive: false,
                delta: '+0.2%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calls per day',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              MiniAreaChart(
                values: analytics.traffic.map((p) => p.value).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status codes',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    for (final s in analytics.statusBreakdown)
                      StatBar(
                        label: s.label,
                        fraction: total == 0 ? 0 : s.value / total,
                        trailing: formatInt(s.value),
                        color: s.label.startsWith('2')
                            ? AppColors.success
                            : s.label.startsWith('4')
                                ? AppColors.warn
                                : AppColors.danger,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quota this month',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 18),
                    Text(
                      '${formatInt(analytics.quotaUsed)} / ${formatInt(analytics.quotaLimit)}',
                      style: const TextStyle(
                          color: AppColors.textHi,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: quotaFraction.clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceRaised,
                        valueColor: AlwaysStoppedAnimation(
                          quotaFraction > 0.9
                              ? AppColors.danger
                              : AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('${(quotaFraction * 100).toStringAsFixed(1)}% used',
                        style: const TextStyle(
                            color: AppColors.textFaint, fontSize: 12.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
