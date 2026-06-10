import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';

/// A minimal Markdown renderer (headings, paragraphs, bullets, fenced code,
/// inline `code`) — enough for product docs without a heavy dependency.
class MarkdownLite extends StatelessWidget {
  const MarkdownLite(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    final lines = source.split('\n');
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      if (line.trim().startsWith('```')) {
        final buf = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          buf.add(lines[i]);
          i++;
        }
        i++; // closing fence
        widgets.add(_codeBlock(buf.join('\n')));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: Text(line.substring(4),
              style: const TextStyle(
                  color: AppColors.textHi,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ));
        i++;
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(line.substring(3),
              style: const TextStyle(
                  color: AppColors.textHi,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
        ));
        i++;
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, right: 10),
                child: Icon(Icons.circle, size: 5, color: AppColors.accent),
              ),
              Expanded(child: _inline(line.substring(2))),
            ],
          ),
        ));
        i++;
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        i++;
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _inline(line),
        ));
        i++;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _codeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvasAlt,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
          color: AppColors.textMid,
        ),
      ),
    );
  }

  Widget _inline(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('`');
    for (var j = 0; j < parts.length; j++) {
      final isCode = j.isOdd;
      spans.add(TextSpan(
        text: parts[j],
        style: isCode
            ? const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.accentSoft,
                backgroundColor: AppColors.surfaceRaised,
              )
            : const TextStyle(
                color: AppColors.textLo, fontSize: 15, height: 1.6),
      ));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }
}
