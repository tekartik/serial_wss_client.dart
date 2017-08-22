import 'dart:core' hide Error;

@TestOn("vm")
import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/channel/io.dart';
import 'package:tekartik_serial_wss_client/channel/memory.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'serial_stream_channel_test.dart';

void main() {
  test_main(ioWebSocketChannelFactory);
  test('open_close', () async {
    var server = await SerialServer.start(ioWebSocketChannelFactory.server, port: 0);
    Serial serial = new Serial(
        ioWebSocketClientChannelFactory.connect(
            //getSerialWssUrl(port: server.port)));
          server.url));
    await serial.connected;

    SerialStreamChannel channel =
    await serial.createChannel(serialWssSimMasterPortPath);
    await channel.close();

    await server.close();
  });
}
