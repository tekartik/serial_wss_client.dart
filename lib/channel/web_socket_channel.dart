import 'package:stream_channel/stream_channel.dart';

import 'dart:async';
import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

export 'src/common.dart';

abstract class WebSocketChannel extends StreamChannelMixin {

}


abstract class WebSocketChannelFactory {
  WebSocketChannelFactory(this.server, this.client);
  WebSocketClientChannelFactory client;
  WebSocketChannelServerFactory server;
}