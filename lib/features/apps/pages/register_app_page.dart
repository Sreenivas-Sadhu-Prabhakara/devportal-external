import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/auth_cubit.dart';
import '../../../widgets/content_wrap.dart';
import '../cubit/register_cubit.dart';

class RegisterAppPage extends StatefulWidget {
  const RegisterAppPage({super.key});

  @override
  State<RegisterAppPage> createState() => _RegisterAppPageState();
}

class _RegisterAppPageState extends State<RegisterAppPage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _selected = <String>{};
  bool _showNameError = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool _restrictedSelected(RegisterState state) => state.products
      .where((p) => _selected.contains(p.id))
      .any((p) => p.visibility != ProductVisibility.public);

  void _submit(RegisterState state) {
    if (_name.text.trim().isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    if (_selected.isEmpty) return;
    context.read<RegisterCubit>().submit(
          developerEmail: context.read<AuthCubit>().state.email,
          name: _name.text.trim(),
          description: _description.text.trim(),
          productIds: _selected.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (p, c) => c.status == RegisterStatus.success,
      listener: (context, state) {
        if (state.created != null) context.go('/apps/${state.created!.id}');
      },
      builder: (context, state) {
        if (state.status == RegisterStatus.loadingProducts) {
          return const Center(child: CircularProgressIndicator());
        }
        final submitting = state.status == RegisterStatus.submitting;
        return SingleChildScrollView(
          child: ContentWrap(
            maxWidth: 760,
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
                Text('Register an app',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                const Text(
                  'Create an application to receive API credentials. Public '
                  'products are approved instantly.',
                  style: TextStyle(color: AppColors.textLo, fontSize: 16),
                ),
                const SizedBox(height: 32),
                _label('App name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  onChanged: (_) {
                    if (_showNameError) setState(() => _showNameError = false);
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. Aurora Mobile',
                    errorText: _showNameError ? 'App name is required' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _label('Description (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'What does this app do?',
                  ),
                ),
                const SizedBox(height: 28),
                _label('Select API products'),
                const SizedBox(height: 4),
                const Text('Choose which APIs this app can call.',
                    style:
                        TextStyle(color: AppColors.textFaint, fontSize: 13)),
                const SizedBox(height: 14),
                for (final p in state.products) _productRow(p),
                if (_restrictedSelected(state)) ...[
                  const SizedBox(height: 16),
                  _approvalNotice(),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    FilledButton(
                      onPressed: (submitting || _selected.isEmpty)
                          ? null
                          : () => _submit(state),
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Create app & get keys'),
                    ),
                    const SizedBox(width: 14),
                    if (_selected.isEmpty)
                      const Flexible(
                        child: Text('Select at least one product',
                            style: TextStyle(
                                color: AppColors.textFaint, fontSize: 13)),
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

  Widget _productRow(ApiProduct p) {
    final selected = _selected.contains(p.id);
    final restricted = p.visibility != ProductVisibility.public;
    final accent = AppColors.categoryColor(p.colorIndex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          if (selected) {
            _selected.remove(p.id);
          } else {
            _selected.add(p.id);
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
                color: selected ? accent : AppColors.line,
                width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected ? accent : AppColors.textFaint,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textHi,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Text(p.version,
                            style: const TextStyle(
                                color: AppColors.textFaint, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(p.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textLo, fontSize: 13)),
                  ],
                ),
              ),
              if (restricted) ...[
                const SizedBox(width: 12),
                const StatusBadge('Approval', tone: BadgeTone.warn),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _approvalNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warn.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.warn.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.gpp_maybe_rounded, color: AppColors.warn, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'One or more selected products require approval. Your app will be '
              'created in a pending state and keys issued once the API team '
              'approves it.',
              style: TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textHi, fontSize: 14, fontWeight: FontWeight.w700));
}
