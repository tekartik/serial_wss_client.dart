@TestOn("vm")
import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/service/io.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';

main() {
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
      var server = await SerialServer.start(port: 0);
      Serial serial = new Serial(
          ioWebSocketChannelFactory.create(getSerialWssUrl(port: server.port)));
      await serial.connected;

      SerialStreamChannel channel =
          await serial.createChannel(serialWssSimMasterPortPath);
      await channel.close();

      await server.close();
    });

    test('open_kill_server_close', () async {
      //SerialServer.debug = true;
      //Serial.debug = true;
      var server = await SerialServer.start(port: 0);
      Serial serial = new Serial(
          ioWebSocketChannelFactory.create(getSerialWssUrl(port: server.port)));
      await serial.connected;

      SerialStreamChannel channel =
          await serial.createChannel(serialWssSimMasterPortPath);
      await server.close();

      await channel.close();
    });
  });
}
