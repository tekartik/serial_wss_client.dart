import 'package:tekartik_serial_wss_client/channel/client/memory.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/server/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/src/memory/memory_web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

class _MemoryWebSocketChannelFactory extends WebSocketChannelFactory {
  _MemoryWebSocketChannelFactory() : super(memoryWebSocketChannelServerFactory, memoryWebSocketClientChannelFactory);

}
final _MemoryWebSocketChannelFactory memoryWebSocketChannelFactory = new _MemoryWebSocketChannelFactory();

String webSocketUrlMemoryScheme = "memory";