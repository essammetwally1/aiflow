import 'package:aiflow/features/image/presentation/screens/screens/resize_image_screen.dart';
import 'package:aiflow/features/profile/presentation/widgets/app_drawer.dart';
import 'package:aiflow/features/profile/presentation/widgets/profile_drawer_provider.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message_stream.dart';
import '../provider/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/composer.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollC = ScrollController();

  void _scrollToBottom() {
    if (!_scrollC.hasClients) return;
    _scrollC.animateTo(
      _scrollC.position.maxScrollExtent + 10,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChatRepository>();
    // final UserModel? user = context.watch<AuthProvider>().user;
    final bool isDark = context.watch<SettingsProvider>().isDark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.sizeOf(context);

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(
        repo: repo,
        sendMessageStream: SendMessageStream(repo),
        sessionId: 'public',
      )..init(),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                isDark ? 'assets/logodark.png' : 'assets/logolight.png',
              ),
            ),
          ),
          title: const Text('AiFlow'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.settings_suggest, size: 35),
                tooltip: 'Open settings',
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: const ProfileDrawerProvider(),
        body: Stack(
          children: [
            Column(
              children: [
                // Message list
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (_, p, __) {
                      // Auto-scroll when new tokens arrive
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );

                      return LayoutBuilder(
                        builder: (ctx, constraints) {
                          // Center and constrain width for large screens
                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 820),
                              child: ListView.builder(
                                controller: _scrollC,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  88,
                                ),
                                itemCount: p.messages.length,
                                itemBuilder: (_, i) =>
                                    ChatBubble(msg: p.messages[i]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // const Divider(height: 1, color: AppTheme.primary),

                // Composer
              ],
            ),
            Positioned(
              top: 8,
              right: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear conversation button

                  // Resize Image button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      tooltip: 'Resize Image',
                      icon: const Icon(
                        Icons.label_important_rounded,
                        color: AppTheme.primary,
                      ), // Or use a custom icon
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(ResizeImageScreen.routeName),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.backgroundDark
                          : AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Consumer<ChatProvider>(
                      builder: (_, p, __) => IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        tooltip: 'Clear conversation',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.red,
                        ),
                        onPressed: p.isSending
                            ? null
                            : () async {
                                await p.clear();
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Consumer<ChatProvider>(
                builder: (_, p, __) => Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 820,
                      maxHeight: 80,
                    ),
                    child: Composer(
                      onSend: (t) {
                        p.send(t);
                        // smooth after send
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          _scrollToBottom,
                        );
                      },
                      isSending: p.isSending,
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
