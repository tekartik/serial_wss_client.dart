import 'dart:async';

import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

abstract class WebSocketChannelServerFactory {
  Future<WebSocketChannelServer> serve({var address, int port});
}

abstract class WebSocketChannelServer {
  // assigned port
  int get port;

  String get url;

  Stream<WebSocketChannel> get stream;

  Future close();
}
