import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BrowserWebSocketChannelFactory extends WebSocketChannelFactory {
  @override
  WebSocketChannel create(String url) {
    return new HtmlWebSocketChannel.connect(url);
  }
}

final BrowserWebSocketChannelFactory browserWebSocketChannelFactory =
    new BrowserWebSocketChannelFactory();
