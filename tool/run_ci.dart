import 'package:dev_test/package.dart';
import 'package:process_run/shell_run.dart';

Future main() async {
  await ioPackageRunCi('.');
  // Build
  await run('pub run build_runner build example_web');
}
