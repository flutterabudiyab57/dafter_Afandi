import 'package:package_info_plus/package_info_plus.dart';

import '../domain/app_version.dart';

final class PackageInfoAppVersionSource implements AppVersionSource {
  const PackageInfoAppVersionSource();

  @override
  Future<AppVersion> read() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(name: info.version, build: info.buildNumber);
  }
}
