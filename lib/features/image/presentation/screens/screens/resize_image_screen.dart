import 'package:aiflow/core/services/image_picker/image_source_snack.dart';
import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/core/utils/utils.dart';
import 'package:aiflow/features/image/data/repositories/image_repository.dart';
import 'package:aiflow/features/image/presentation/provider/home_resize_provider.dart';
import 'package:aiflow/features/image/presentation/widgets/build_state_content.dart';
import 'package:aiflow/features/image/presentation/widgets/dimension_fields.dart';
import 'package:aiflow/features/image/presentation/widgets/preview_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResizeImageScreen extends StatefulWidget {
  static const routeName = '/resizeimage';
  const ResizeImageScreen({super.key});

  @override
  State<ResizeImageScreen> createState() => _ResizeImageScreenState();
}

class _ResizeImageScreenState extends State<ResizeImageScreen> {
  TextEditingController widthC = TextEditingController();
  TextEditingController heightC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widthC.dispose();
    heightC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeResizeProvider(ImageRepository()),
      child: _ResizeImageScreenContent(
        widthController: widthC,
        heightController: heightC,
      ),
    );
  }
}

class _ResizeImageScreenContent extends StatefulWidget {
  final TextEditingController widthController;
  final TextEditingController heightController;

  const _ResizeImageScreenContent({
    required this.widthController,
    required this.heightController,
  });

  @override
  State<_ResizeImageScreenContent> createState() =>
      _ResizeImageScreenContentState();
}

class _ResizeImageScreenContentState extends State<_ResizeImageScreenContent> {
  Color saveIconColor = AppTheme.primary;
  bool showFloatingButton = false;

  Future<void> pick() async {
    final source = await ImageSourceSnack.pickSource(context);
    if (source == null) return;
    // Use context from the content widget which has access to the provider
    await context.read<HomeResizeProvider>().pick(source);
    showFloatingButton = true;
  }

  @override
  Widget build(BuildContext context) {
    final HomeResizeProvider homeResizeProvider = context
        .watch<HomeResizeProvider>();
    final theme = Theme.of(context).textTheme;
    final isResizing = homeResizeProvider.status == HomeResizeStatus.resizing;

    if (widget.widthController.text != homeResizeProvider.width.toString()) {
      widget.widthController.text = homeResizeProvider.width.toString();
    }
    if (widget.heightController.text != homeResizeProvider.height.toString()) {
      widget.heightController.text = homeResizeProvider.height.toString();
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          homeResizeProvider.reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resize Image'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              homeResizeProvider.reset();
              Navigator.of(context).pop();
            },
          ),
        ),
        floatingActionButton: showFloatingButton
            ? FloatingActionButton(
                backgroundColor: AppTheme.primary,
                onPressed: isResizing ? null : pick,
                child: const Icon(Icons.add_a_photo),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Stack(
                children: [
                  PreviewCard(
                    showOverlay: isResizing,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: BuildStateContent(
                        p: homeResizeProvider,
                        theme: theme,
                        onPick: pick,
                      ),
                    ),
                  ),
                  if (homeResizeProvider.output != null &&
                      homeResizeProvider.status == HomeResizeStatus.done)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () async {
                          final ok = await homeResizeProvider
                              .saveOutputToGallery();
                          if (!mounted) return;
                          setState(() {
                            saveIconColor = AppTheme.green;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Saved to gallery' : 'Saving failed',
                                textAlign: TextAlign.center,
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ok
                                  ? AppTheme.green
                                  : AppTheme.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 50),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: saveIconColor, width: 5),
                            boxShadow: [BoxShadow(color: AppTheme.white)],
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: saveIconColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DimensionFields(
                widthC: widget.widthController,
                heightC: widget.heightController,
                busy: isResizing,
                onResize: () async {
                  saveIconColor = AppTheme.primary;
                  homeResizeProvider.setWidth(widget.widthController.text);
                  homeResizeProvider.setHeight(widget.heightController.text);
                  await homeResizeProvider.doResize();
                  if (!mounted) return;
                  if (homeResizeProvider.status == HomeResizeStatus.done) {
                    Utils.showSuccessMessage('Image resized successfully');
                  } else if (homeResizeProvider.status ==
                      HomeResizeStatus.error) {
                    Utils.showErrorMessage(
                      homeResizeProvider.message ?? 'Resize failed',
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
