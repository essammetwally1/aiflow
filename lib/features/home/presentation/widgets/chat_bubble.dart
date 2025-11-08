import 'package:aiflow/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/provider/setting_provider.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDark;
    final isUser = msg.role == ChatRole.user;
    final textTheme = Theme.of(context).textTheme;

    // Background color respects user role and theme mode
    final bg = isUser
        ? AppTheme.primary
        : isDark
        ? AppTheme.backgroundDark.withValues(alpha: .65)
        : AppTheme.white;

    // Text color always taken from titleMedium but adapted for roles
    final fg = isUser
        ? AppTheme.white
        : (isDark
              ? AppTheme.white.withValues(alpha: .9)
              : textTheme.titleMedium?.color ?? AppTheme.black);

    // Subtle border only for assistant messages
    final border = isUser
        ? null
        : Border.all(
            color: AppTheme.primary.withValues(alpha: isDark ? .25 : .3),
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: border,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: .25)
                  : Colors.black.withValues(alpha: .06),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 40, 12),
              child: _MessageBody(
                text: msg.content,
                isStreaming: msg.isStreaming,
                // Always use titleMedium base style from theme
                style: textTheme.titleMedium!.copyWith(color: fg),
              ),
            ),
            if (!isUser && !msg.isStreaming && msg.content.trim().isNotEmpty)
              Positioned(
                right: 4,
                bottom: 2,
                child: IconButton(
                  splashRadius: 18,
                  tooltip: 'Copy',
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: fg.withValues(alpha: .8),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: msg.content));
                    if (context.mounted) {
                      Utils.showSuccessMessage('Copied');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  final String text;
  final bool isStreaming;
  final TextStyle style;

  const _MessageBody({
    required this.text,
    required this.isStreaming,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final showDots = isStreaming && text.isEmpty;
    if (showDots) return const _TypingDots();
    return SelectableText(
      text.isEmpty && isStreaming ? '…' : text,
      style: style,
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.watch<SettingsProvider>().isDark
        ? AppTheme.white
        : Theme.of(context).textTheme.titleMedium!.color ?? AppTheme.black;

    final dot = Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final active = (t * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Opacity(opacity: i == active ? 1 : .35, child: dot),
          ),
        );
      },
    );
  }
}
