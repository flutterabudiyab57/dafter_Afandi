import 'package:material_ui/material_ui.dart';

import 'status_banner.dart';

/// A banner at the top of a form for a failed save or a rule that blocks
/// saving (research R11). It scrolls itself into view when it appears or
/// its message changes, so it is seen even when Save is far below.
class FormErrorBanner extends StatefulWidget {
  const FormErrorBanner({
    required this.title,
    this.tone = StatusTone.error,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final StatusTone tone;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<FormErrorBanner> createState() => _FormErrorBannerState();
}

class _FormErrorBannerState extends State<FormErrorBanner> {
  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(FormErrorBanner old) {
    super.didUpdateWidget(old);
    if (old.title != widget.title || old.message != widget.message) _reveal();
  }

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    Scrollable.ensureVisible(
      context,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
    );
  });

  @override
  Widget build(BuildContext context) => StatusBanner(
    tone: widget.tone,
    title: widget.title,
    message: widget.message,
    actionLabel: widget.actionLabel,
    onAction: widget.onAction,
  );
}
