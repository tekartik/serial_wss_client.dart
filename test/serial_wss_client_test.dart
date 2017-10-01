import 'package:dev_test/test.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';

main() {
  group('serial_wss_client', () {
    test('connection_options', () {
      ConnectionOptions options = new ConnectionOptions()..bitrate = 115200;
      expect(options.toMap(), {'bitrate': 115200});
    });
  });
}
