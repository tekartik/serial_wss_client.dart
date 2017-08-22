import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/channel/server/io.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

class _IoWebSocketChannelFactory extends WebSocketChannelFactory {
  String get scheme => webSocketUrlScheme;
  _IoWebSocketChannelFactory()
      : super(ioWebSocketChannelServerFactory, ioWebSocketClientChannelFactory);
}

final _IoWebSocketChannelFactory ioWebSocketChannelFactory =
    new _IoWebSocketChannelFactory();
