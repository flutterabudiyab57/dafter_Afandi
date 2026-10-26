import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Loads under this show nothing, so fast screens don't flicker (SC-006).
const Duration kSkeletonDelay = Duration(milliseconds: 300);

/// Placeholder rows the height of real list rows, shown only once a load
/// takes longer than [kSkeletonDelay]. Screen readers skip it.
class SkeletonList extends StatefulWidget {
  const SkeletonList({this.rows = 4, super.key});

  final int rows;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: 1,
  );
  late final Timer _delay;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _delay = Timer(kSkeletonDelay, () {
      setState(() => _visible = true);
      _animate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate();
  }

  /// Shimmers only once visible, and never with animations turned off.
  void _animate() {
    if (!_visible || MediaQuery.disableAnimationsOf(context)) {
      _shimmer
        ..stop()
        ..value = 1;
    } else if (!_shimmer.isAnimating) {
      _shimmer.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _delay.cancel();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final tokens = context.tokens;
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    // A two-line list row is 72 design px: a 56 block, 8 above and below.
    final block = tokens.spaceXl + tokens.spaceLg;
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1).animate(_shimmer),
        child: Column(
          children: [
            for (var i = 0; i < widget.rows; i++)
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.spaceMd,
                  vertical: tokens.spaceSm,
                ),
                child: Container(
                  height: block,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
