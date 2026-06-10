import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reveal/copy field for a secret value (consumer key or secret).
class CredentialField extends StatefulWidget {
  const CredentialField({
    super.key,
    required this.label,
    required this.value,
    this.alwaysVisible = false,
  });

  final String label;
  final String value;
  final bool alwaysVisible;

  @override
  State<CredentialField> createState() => _CredentialFieldState();
}

class _CredentialFieldState extends State<CredentialField> {
  late bool _revealed = widget.alwaysVisible;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final display =
        _revealed ? widget.value : '•' * widget.value.length.clamp(0, 36);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(),
            style: const TextStyle(
                color: AppColors.textFaint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
          decoration: BoxDecoration(
            color: AppColors.canvasAlt,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  display,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13.5,
                      color: AppColors.textHi),
                ),
              ),
              if (!widget.alwaysVisible)
                IconButton(
                  tooltip: _revealed ? 'Hide' : 'Reveal',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _revealed = !_revealed),
                  icon: Icon(
                      _revealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 17,
                      color: AppColors.textFaint),
                ),
              IconButton(
                tooltip: _copied ? 'Copied' : 'Copy',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.value));
                  setState(() => _copied = true);
                  await Future<void>.delayed(const Duration(seconds: 2));
                  if (mounted) setState(() => _copied = false);
                },
                icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                    color: _copied ? AppColors.success : AppColors.textFaint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
