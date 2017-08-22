import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/channel/client/memory.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/server/io.dart';
import 'package:tekartik_serial_wss_client/channel/server/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/src/memory/memory_web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

class _IoWebSocketChannelFactory extends WebSocketChannelFactory {
  _IoWebSocketChannelFactory() : super(ioWebSocketChannelServerFactory, ioWebSocketClientChannelFactory);

}
final _IoWebSocketChannelFactory ioWebSocketChannelFactory = new _IoWebSocketChannelFactory();
