import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';

/// Username/password sign-in. The hardcoded credential stands in for the
/// ForgeRock OIDC redirect used in production.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.from});

  final String? from;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<AuthCubit>().signIn(_username.text, _password.text);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => !prev.signedIn && curr.signedIn,
      listener: (context, state) => context.go(widget.from ?? '/dashboard'),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PortalMark(size: 40),
                  const SizedBox(height: 24),
                  Text('Sign in',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Access your apps, API keys and usage.',
                    style: TextStyle(color: AppColors.textLo, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _label('Username'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _username,
                    autofocus: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(hintText: 'admin'),
                  ),
                  const SizedBox(height: 16),
                  _label('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                            _obscure
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            size: 18,
                            color: AppColors.textFaint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.error.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 16, color: AppColors.danger),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(state.error,
                                      style: const TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: state.signingIn ? null : _submit,
                              child: state.signingIn
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Sign in'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _DemoHint(onFill: () {
                    _username.text = kPortalUsername;
                    _password.text = kPortalPassword;
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textHi, fontSize: 13, fontWeight: FontWeight.w700));
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.onFill});
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.canvasAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 15, color: AppColors.textFaint),
          const SizedBox(width: 10),
          const Expanded(
            child: SelectableText('Demo: admin / passWORD1234#',
                style: TextStyle(color: AppColors.textLo, fontSize: 12.5)),
          ),
          TextButton(
            onPressed: onFill,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Fill', style: TextStyle(fontSize: 12.5)),
          ),
          IconButton(
            tooltip: 'Copy password',
            visualDensity: VisualDensity.compact,
            onPressed: () => Clipboard.setData(
                const ClipboardData(text: kPortalPassword)),
            icon: const Icon(Icons.copy_rounded,
                size: 14, color: AppColors.textFaint),
          ),
        ],
      ),
    );
  }
}
