import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/channel/io.dart';
@TestOn("vm")
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/message.dart' as swss;
import 'package:tekartik_serial_wss_client/constant.dart' as swss;
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'serial_wss_client_service_test.dart';

main() {
  test_main(ioWebSocketChannelFactory);
}
