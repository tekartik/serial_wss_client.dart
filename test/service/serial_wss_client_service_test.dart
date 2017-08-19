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
    test('start_stop', () async {
      var server = await SerialServer.start(port: 0);
      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          url: getSerialWssUrl(port: server.port));
      var completer = new Completer();

      service.start();
      service.onConnected.listen((bool connected) async {
        if (connected) {
          expect(service.isConnected, isTrue);

          await service.stop();
          completer.complete();
        }
      });

      await completer.future;
      await server.close();
    });

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
