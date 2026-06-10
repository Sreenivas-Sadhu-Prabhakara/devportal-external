import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/content_wrap.dart';
import '../cubit/apps_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppsCubit, AppsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: ContentWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My apps',
                              style:
                                  Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 8),
                          const Text(
                            'Your registered applications and their API keys.',
                            style: TextStyle(
                                color: AppColors.textLo, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/register'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Register app'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (state.status == AppsStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.apps.isEmpty)
                  _EmptyState(onCreate: () => context.go('/register'))
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final app in state.apps) _AppCard(app: app),
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

class _AppCard extends StatefulWidget {
  const _AppCard({required this.app});
  final DeveloperApp app;

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> {
  bool _hover = false;

  (String, BadgeTone) get _status => switch (widget.app.status) {
        AppStatus.approved => ('Active', BadgeTone.success),
        AppStatus.pending => ('Pending approval', BadgeTone.warn),
        AppStatus.revoked => ('Revoked', BadgeTone.danger),
      };

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryColor(widget.app.colorIndex);
    final (label, tone) = _status;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/apps/${widget.app.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: _hover ? accent.withValues(alpha: 0.8) : AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(colors: [
                        accent.withValues(alpha: 0.9),
                        accent.withValues(alpha: 0.4),
                      ]),
                    ),
                    child: const Icon(Icons.apps_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.app.name,
                        style: const TextStyle(
                            color: AppColors.textHi,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StatusBadge(label, tone: tone),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.category_rounded,
                      size: 14, color: AppColors.textFaint),
                  const SizedBox(width: 6),
                  Text('${widget.app.productIds.length} products',
                      style: const TextStyle(
                          color: AppColors.textFaint, fontSize: 13)),
                  const SizedBox(width: 16),
                  const Icon(Icons.vpn_key_rounded,
                      size: 14, color: AppColors.textFaint),
                  const SizedBox(width: 6),
                  Text('${widget.app.credentials.length} keys',
                      style: const TextStyle(
                          color: AppColors.textFaint, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 72),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(Icons.apps_rounded, size: 40, color: AppColors.textFaint),
          const SizedBox(height: 16),
          Text('No apps yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Register your first application to get API keys.',
              style: TextStyle(color: AppColors.textLo)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Register app'),
          ),
        ],
      ),
    );
  }
}
