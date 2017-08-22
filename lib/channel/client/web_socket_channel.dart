import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';

abstract class WebSocketClientChannelFactory {
  WebSocketChannel connect(String url);
}
