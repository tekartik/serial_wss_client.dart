@TestOn("vm")
import 'package:dev_test/test.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';

import 'channel_test.dart';
//import 'package:tekartik_serial_wss_client/channel/channel.dart';

void main() {
  channelTestMain(webSocketChannelFactoryIo);
}
