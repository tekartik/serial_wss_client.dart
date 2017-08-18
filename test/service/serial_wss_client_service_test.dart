@TestOn("vm")
import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/service/io.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';

main() {
  group('client_service', () {
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

    test('service', () async {
      var server = await SerialServer.start(port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 300),
          url: getSerialWssUrl(port: port));
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 50; i++) {
            await sleep(50);
            print("connected: ${service.isConnected}");
          }
        }(),
        () async {
          await sleep(500);
          expect(service.isConnected, isFalse);
          server = await SerialServer.start(port: port);
          await sleep(500);
          expect(service.isConnected, isTrue);
          print("closing server");
          await server.close();
          print("server closed");
          await sleep(500);
          expect(service.isConnected, isFalse);
          server = await SerialServer.start(port: port);
          await sleep(500);
          expect(service.isConnected, isTrue);
          await server.close();
        }(),
      ]);
    });

    int timeScale = 50;
    test('change_port', () async {
      var server1 = await SerialServer.start(port: 0);
      var server2 = await SerialServer.start(port: 0);

      SerialWssClientService service =
          new SerialWssClientService(ioWebSocketChannelFactory,
              //retryDelay: new Duration(milliseconds: timeScale * 2),
              url: getSerialWssUrl(port: server1.port));
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 50; i++) {
            await sleep(timeScale);
            print("connected: ${service.isConnected}");
          }
        }(),
        () async {
          await sleep(timeScale * 10);
          expect(service.isConnected, isTrue);
          print("closing server");
          await server1.close();
          print("server closed");
          await sleep(timeScale * 10);
          expect(service.isConnected, isFalse);
          print("changing url");
          service.changeUrl(getSerialWssUrl(port: server2.port));
          await sleep(20);
          expect(service.isConnected, isTrue);
          await server2.close();
        }(),
      ]);
    });
  });
}
