import 'dart:async';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/native.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

class BrowserWebSocketChannelClientFactory extends WebSocketClientChannelFactory {
  @override
  WebSocketChannel connect(String url) {
    return new NativeWebSocketChannel(new HtmlWebSocketChannel.connect(url));
  }
}

final BrowserWebSocketChannelClientFactory browserWebSocketChannelClientFactory =
    new BrowserWebSocketChannelClientFactory();
