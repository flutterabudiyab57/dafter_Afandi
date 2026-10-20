import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Shows the bundled font's OFL license on the licenses page. The file is
/// read only when that page asks for it.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'IBM Plex Sans Arabic',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
}
