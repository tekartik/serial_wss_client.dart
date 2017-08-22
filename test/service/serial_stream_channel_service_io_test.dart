@TestOn("vm")
library _;

import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/channel/io.dart';

import 'serial_wss_client_service_test.dart';

main() {
  test_main(ioWebSocketChannelFactory);

}
