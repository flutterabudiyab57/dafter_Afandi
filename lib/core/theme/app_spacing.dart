import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing in design px (design size 420×812).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Height of the logo on the welcome and blocking screens.
  static const double logo = 120;

  /// Width of an empty-state illustration; height is width × 200 / 240.
  static const double illustration = 192;
}

/// Content is capped and centered on tablets and in landscape (FR-019, K1).
const double kMaxContentWidth = 600;

/// The width scale for design px, clamped so tablets don't get doubled
/// spacing (research R7). Needs `ScreenUtilInit` above; 1 otherwise.
double designScale() {
  try {
    return ScreenUtil().scaleWidth.clamp(0.85, 1.20);
  } on Object {
    return 1;
  }
}
