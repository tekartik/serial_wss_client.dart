@TestOn("vm")
library _;

import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/channel/io.dart';

import 'channel_test.dart';
//import 'package:tekartik_serial_wss_client/channel/channel.dart';

main() {
  channel_test_main(ioWebSocketChannelFactory);
}
