import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/src/memory/memory_web_socket_channel.dart';

final MemoryWebSocketClientChannelFactory memoryWebSocketClientChannelFactory =
    new MemoryWebSocketClientChannelFactory();

// The one to use
// will redirect memory: to memory
WebSocketClientChannelFactory smartWebSocketChannelClientFactory(
        WebSocketClientChannelFactory defaultFactory) =>
    new MergedWebSocketChannelClientFactory(defaultFactory);

String webSocketUrlMemoryScheme = "memory";
