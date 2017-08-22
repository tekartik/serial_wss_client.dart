import 'package:tekartik_serial_wss_client/channel/client/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/memory.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

class _MemoryWebSocketChannelFactory extends WebSocketChannelFactory {
  String get scheme => webSocketUrlMemoryScheme;
  _MemoryWebSocketChannelFactory()
      : super(memoryWebSocketChannelServerFactory,
            memoryWebSocketClientChannelFactory);
}

final _MemoryWebSocketChannelFactory memoryWebSocketChannelFactory =
    new _MemoryWebSocketChannelFactory();

String webSocketUrlMemoryScheme = "memory";
