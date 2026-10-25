import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// The 19 scenes in `assets/illustrations/{light,dark}/` (research R4).
enum AppIllustration {
  welcome,
  emptyProducts,
  emptySales,
  emptyCustomers,
  emptySuppliers,
  emptyPurchases,
  emptySearch,
  emptyReports,
  emptyArchive,
  successSale,
  successPayment,
  successSaved,
  errorGeneric,
  errorDatabase,
  warningLowStock,
  warningUnsaved,
  dataSafety,
  updateRequired,
  infoTip;

  /// The 1x file; Flutter picks `2.0x/` or `3.0x/` by pixel ratio.
  String assetPath(Brightness brightness) {
    final folder = brightness == Brightness.dark ? 'dark' : 'light';
    final file = name.replaceAllMapped(
      RegExp('[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}',
    );
    return 'assets/illustrations/$folder/$file.png';
  }
}

/// A decorative scene that follows the theme's brightness. Screen readers
/// skip it; the text next to it says what it means.
class Illustration extends StatelessWidget {
  const Illustration(this.kind, {super.key, this.width});

  /// Height is always width × 200 / 240.
  static const double aspectRatio = 240 / 200;

  final AppIllustration kind;

  /// Defaults to `context.tokens.illustrationWidth`.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width ?? context.tokens.illustrationWidth;
    final h = w / aspectRatio;
    return Image.asset(
      kind.assetPath(Theme.of(context).brightness),
      width: w,
      height: h,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => SizedBox(width: w, height: h),
    );
  }
}
