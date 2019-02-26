@TestOn("vm")

import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart' as web_socket;

import 'serial_stream_channel_test.dart';

void main() {
  testMain(webSocketChannelFactoryIo);
  test('open_close', () async {
    var server =
        await SerialServer.start(webSocketChannelFactoryIo.server, port: 0);
    Serial serial = Serial(web_socket.webSocketChannelClientFactoryIo.connect(
        //getSerialWssUrl(port: server.port)));
        server.url));
    await serial.connected;

    SerialStreamChannel channel =
        await serial.createChannel(serialWssSimMasterPortPath);
    await channel.close();

    await server.close();
  });
}
