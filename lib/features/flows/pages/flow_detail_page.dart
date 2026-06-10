import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/content_wrap.dart';
import '../cubit/flow_detail_cubit.dart';

class FlowDetailPage extends StatelessWidget {
  const FlowDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlowDetailCubit, FlowDetailState>(
      builder: (context, state) {
        if (state.status == FlowDetailStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.scenario == null) {
          return Center(
              child: Text('Could not load flow.\n${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textFaint)));
        }
        final f = state.scenario!;
        final accent = AppColors.categoryColor(f.colorIndex);
        final isInternal = f.kind == FlowKind.internal;
        return SingleChildScrollView(
          child: ContentWrap(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                TextButton.icon(
                  onPressed: () => context.go('/flows'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Flows'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMid,
                      padding: EdgeInsets.zero),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Flexible(
                      child: Text(f.name,
                          style: Theme.of(context).textTheme.displaySmall),
                    ),
                    const SizedBox(width: 14),
                    StatusBadge(isInternal ? 'Internal' : 'External',
                        tone: isInternal ? BadgeTone.info : BadgeTone.accent),
                  ],
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(f.summary,
                      style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 16,
                          height: 1.5)),
                ),
                const SizedBox(height: 24),
                _Controls(state: state, accent: accent),
                const SizedBox(height: 28),
                for (var i = 0; i < f.steps.length; i++)
                  _StepTile(
                    index: i,
                    step: f.steps[i],
                    done: i < state.shownSteps,
                    running: i == state.shownSteps && state.running,
                    isLast: i == f.steps.length - 1,
                    accent: accent,
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

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.accent});
  final FlowDetailState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final f = state.scenario!;
    final cubit = context.read<FlowDetailCubit>();
    final progress = state.shownSteps / f.steps.length;
    return Container(
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  state.isComplete
                      ? 'Transfer complete'
                      : 'Step ${state.shownSteps + 1} of ${f.steps.length}',
                  style: const TextStyle(
                      color: AppColors.textHi,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
              if (state.isComplete)
                OutlinedButton.icon(
                  onPressed: cubit.reset,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Run again'),
                )
              else
                FilledButton.icon(
                  onPressed: state.running ? null : cubit.advance,
                  icon: state.running
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(state.running
                      ? 'Calling ${f.steps[state.shownSteps].apiName}…'
                      : 'Run step ${state.shownSteps + 1}'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceRaised,
              valueColor: AlwaysStoppedAnimation(
                  state.isComplete ? AppColors.success : accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.step,
    required this.done,
    required this.running,
    required this.isLast,
    required this.accent,
  });

  final int index;
  final FlowStep step;
  final bool done;
  final bool running;
  final bool isLast;
  final Color accent;

  Color get _methodColor => switch (step.method) {
        'GET' => AppColors.info,
        'POST' => AppColors.success,
        'PATCH' || 'PUT' => AppColors.warn,
        'DELETE' => AppColors.danger,
        _ => AppColors.textLo,
      };

  @override
  Widget build(BuildContext context) {
    final active = done || running;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // rail
          Column(
            children: [
              _circle(),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: done ? AppColors.success : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: active ? 1 : 0.55,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                        color: running
                            ? accent.withValues(alpha: 0.7)
                            : AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title,
                          style: const TextStyle(
                              color: AppColors.textHi,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _methodTag(),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(step.path,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: AppColors.textHi)),
                          ),
                          const SizedBox(width: 10),
                          _apiChip(),
                        ],
                      ),
                      if (active && step.request.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _code('Request', step.request),
                      ],
                      if (done) ...[
                        const SizedBox(height: 12),
                        _code('Response', step.response, success: true),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.subdirectory_arrow_right_rounded,
                                size: 15, color: AppColors.textFaint),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(step.note,
                                  style: const TextStyle(
                                      color: AppColors.textLo,
                                      fontSize: 13.5,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                      ] else if (!active) ...[
                        const SizedBox(height: 8),
                        const Text('Awaiting the previous step',
                            style: TextStyle(
                                color: AppColors.textFaint, fontSize: 12.5)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle() {
    if (done) {
      return _badge(AppColors.success,
          child: const Icon(Icons.check_rounded, size: 18, color: Colors.white));
    }
    if (running) {
      return _badge(accent,
          child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)));
    }
    return _badge(AppColors.surfaceRaised,
        border: AppColors.line,
        child: Text('${index + 1}',
            style: const TextStyle(
                color: AppColors.textFaint,
                fontWeight: FontWeight.w700,
                fontSize: 14)));
  }

  Widget _badge(Color color, {Color? border, required Widget child}) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border != null ? Border.all(color: border) : null,
      ),
      child: child,
    );
  }

  Widget _methodTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _methodColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(step.method,
          style: TextStyle(
              color: _methodColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4)),
    );
  }

  Widget _apiChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(step.apiName,
          style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 11.5,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _code(String label, String json, {bool success = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvasAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.toUpperCase(),
                  style: TextStyle(
                      color: success ? AppColors.success : AppColors.textFaint,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const Spacer(),
              InkWell(
                onTap: () => Clipboard.setData(ClipboardData(text: json)),
                child: const Icon(Icons.copy_rounded,
                    size: 14, color: AppColors.textFaint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(json,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.textMid)),
        ],
      ),
    );
  }
}
