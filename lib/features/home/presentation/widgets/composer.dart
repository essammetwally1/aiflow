import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class Composer extends StatefulWidget {
  final void Function(String) onSend;
  final bool isSending;
  const Composer({super.key, required this.onSend, required this.isSending});

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final _c = TextEditingController();
  final _focus = FocusNode();

  void _submit() {
    final t = _c.text.trim();
    if (t.isEmpty || widget.isSending) return;
    widget.onSend(t);
    _c.clear();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: theme.brightness == Brightness.dark ? 0 : 2,
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? AppTheme.primary.withValues(alpha: .25)
                : AppTheme.primary.withValues(alpha: .35),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _c,
                focusNode: _focus,
                minLines: 1,
                maxLines: 6,
                enabled: !widget.isSending,
                style: theme.textTheme.titleMedium,
                cursorColor: AppTheme.primary,
                decoration: const InputDecoration(
                  hintText: 'Ask AiFlow…',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isSending
                  ? const SizedBox(
                      key: ValueKey('sending'),
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Tooltip(
                      key: const ValueKey('send'),
                      message: 'Send',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _submit,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: AppTheme.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
