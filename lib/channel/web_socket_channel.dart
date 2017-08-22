import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';

abstract class WebSocketChannel extends StreamChannelMixin {}

abstract class WebSocketChannelFactory {
  String get scheme;
  WebSocketChannelFactory(this.server, this.client);

  WebSocketClientChannelFactory client;
  WebSocketChannelServerFactory server;
}

String webSocketUrlScheme = "ws";
