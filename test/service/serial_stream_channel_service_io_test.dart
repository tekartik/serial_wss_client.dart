@TestOn("vm")

import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';

import 'serial_wss_client_service_test.dart';

void main() {
  testMain(webSocketChannelFactoryIo);
}
