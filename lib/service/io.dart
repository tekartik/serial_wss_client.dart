import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IoWebSocketChannelFactory extends WebSocketChannelFactory {

  @override
  WebSocketChannel create(String url) {
    return new IOWebSocketChannel.connect(url);
  }
}

final IoWebSocketChannelFactory ioWebSocketChannelFactory = new IoWebSocketChannelFactory();

