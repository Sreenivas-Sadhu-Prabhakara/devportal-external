import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A mock "Try it" console. Builds a request against an endpoint and returns a
/// canned response. In the live build, Send hits the API through Apigee X.
class TryItConsole extends StatefulWidget {
  const TryItConsole({super.key, required this.product});

  final ApiProduct product;

  @override
  State<TryItConsole> createState() => _TryItConsoleState();
}

class _TryItConsoleState extends State<TryItConsole> {
  late ApiEndpoint _endpoint = widget.product.endpoints.first;
  final _keyController =
      TextEditingController(text: 'qC8kR2mNzVfP7tLxWd0aYb3HsJ4uE6oG');
  bool _sending = false;
  String? _response;
  int _status = 0;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Color _methodColor(String m) => switch (m) {
        'GET' => AppColors.info,
        'POST' => AppColors.success,
        'PATCH' => AppColors.warn,
        'DELETE' => AppColors.danger,
        _ => AppColors.textLo,
      };

  String get _url =>
      'https://api.example.com${widget.product.basePath}${_endpoint.path}';

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    setState(() {
      _sending = false;
      _status = 200;
      _response = widget.product.sampleResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Endpoint picker
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('ENDPOINT'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ApiEndpoint>(
                      value: _endpoint,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      items: [
                        for (final e in widget.product.endpoints)
                          DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                _MethodTag(e.method, _methodColor(e.method)),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    e.path,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13.5,
                                      color: AppColors.textHi,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (e) => setState(() {
                        _endpoint = e!;
                        _response = null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(_endpoint.summary,
                    style: const TextStyle(
                        color: AppColors.textFaint, fontSize: 13)),
                const SizedBox(height: 18),
                const _Label('AUTHORIZATION — API KEY'),
                const SizedBox(height: 8),
                TextField(
                  controller: _keyController,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 13.5),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.vpn_key_rounded, size: 18, color: AppColors.textFaint),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(_sending ? 'Sending…' : 'Send request'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _url,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          color: AppColors.textFaint,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Response
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.canvasAlt,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(AppRadii.md)),
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            padding: const EdgeInsets.all(20),
            child: _response == null
                ? const Text('Response will appear here.',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 13))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge('$_status OK', tone: BadgeTone.success),
                          const SizedBox(width: 10),
                          const Text('application/json',
                              style: TextStyle(
                                  color: AppColors.textFaint, fontSize: 12)),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Copy',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: _response!)),
                            icon: const Icon(Icons.copy_rounded,
                                size: 16, color: AppColors.textFaint),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _response!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textFaint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      );
}

class _MethodTag extends StatelessWidget {
  const _MethodTag(this.method, this.color);
  final String method;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
