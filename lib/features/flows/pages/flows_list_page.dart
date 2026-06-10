import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/content_wrap.dart';
import '../cubit/flows_cubit.dart';

class FlowsListPage extends StatelessWidget {
  const FlowsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlowsCubit, FlowsState>(
      builder: (context, state) {
        if (state.status == FlowsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: ContentWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('End-to-end flows',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                const Text(
                  'Walk through how the BIAN Payment Initiation, Order and '
                  'Execution APIs chain together to move money.',
                  style: TextStyle(color: AppColors.textLo, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    for (final f in state.flows) _FlowCard(scenario: f),
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

class _FlowCard extends StatefulWidget {
  const _FlowCard({required this.scenario});
  final FlowScenario scenario;

  @override
  State<_FlowCard> createState() => _FlowCardState();
}

class _FlowCardState extends State<_FlowCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.scenario;
    final accent = AppColors.categoryColor(f.colorIndex);
    final isInternal = f.kind == FlowKind.internal;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go('/flows/${f.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: _hover ? accent.withValues(alpha: 0.8) : AppColors.line),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: 0.16), AppColors.surface],
              stops: const [0, 0.7],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: accent.withValues(alpha: 0.22),
                    ),
                    child: Icon(
                        isInternal
                            ? Icons.sync_alt_rounded
                            : Icons.public_rounded,
                        color: accent,
                        size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(f.name,
                        style: const TextStyle(
                            color: AppColors.textHi,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                  ),
                  StatusBadge(isInternal ? 'Internal' : 'External',
                      tone: isInternal ? BadgeTone.info : BadgeTone.accent),
                ],
              ),
              const SizedBox(height: 14),
              Text(f.summary,
                  style: const TextStyle(
                      color: AppColors.textLo, fontSize: 14, height: 1.55)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text('${f.steps.length} steps',
                      style: const TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('Walk through',
                      style: TextStyle(
                          color: accent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700)),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
