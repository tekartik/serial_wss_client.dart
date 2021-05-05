import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'package:tekartik_web_socket/web_socket.dart';

void main() {
  testMain(webSocketChannelFactoryMemory);
}

void testMain(WebSocketChannelFactory channelFactory) {
  group('serial_stream_channel', () {
    /*
    test('depends', () async {
      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 300));
      service.start();
      for (int i = 0; i < 100; i++) {
        await sleep(100);
        print("connected: ${service.isConnected}");
      }
      await service.stop();
      print("connected: ${service.isConnected}");
      await sleep(2000);
    });
    */

    test('open_close', () async {
      var server = await SerialServer.start(channelFactory.server, port: 0);
      var serial = Serial(channelFactory.client.connect(server.url));
      await serial.connected;

      var channel = await serial.createChannel(serialWssSimMasterPortPath);
      await channel.close();

      await server.close();
    });

    test('open_kill_server_close', () async {
      //SerialServer.debug = true;
      //Serial.debug = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      var serial = Serial(channelFactory.client.connect(server.url));
      await serial.connected;

      var channel = await serial.createChannel(serialWssSimMasterPortPath);
      await server.close();

      await channel.close();
    });
  });
}
