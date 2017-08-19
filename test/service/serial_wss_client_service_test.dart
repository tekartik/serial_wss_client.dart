@TestOn("vm")
import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/service/io.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';

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

    test('start_stop_start', () async {
      //SerialWssClientService.debug.on = true;
      var server = await SerialServer.start(port: 0);
      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          url: getSerialWssUrl(port: server.port));

      service.start();
      await service.waitForConnected(true);
      await service.stop();
      expect(service.isConnected, isFalse);
      await service.start();
      await service.waitForConnected(true);
      await service.stop();
      expect(service.isConnected, isFalse);

      await server.close();
    });

    test('service', () async {
      var server = await SerialServer.start(port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      service.start();

      await sleep(100);
      await service.waitForConnected(false);

      server = await SerialServer.start(port: port);
      await service.waitForConnected(true);
      expect(service.isConnected, isTrue);
      await server.close();
      await service.waitForConnected(false);
      expect(service.isConnected, isFalse);
      server = await SerialServer.start(port: port);
      await service.waitForConnected(true);
      expect(service.isConnected, isTrue);
      await server.close();
      await service.waitForConnected(false);
      expect(service.isConnected, isFalse);
    });

    test('change_port', () async {
      var server1 = await SerialServer.start(port: 0);
      var server2 = await SerialServer.start(port: 0);

      SerialWssClientService service =
          new SerialWssClientService(ioWebSocketChannelFactory,
              //retryDelay: new Duration(milliseconds: timeScale * 2),
              url: getSerialWssUrl(port: server1.port));
      service.start();

      await service.waitForConnected(true);
      expect(service.connectedUrl, getSerialWssUrl(port: server1.port));
      await server1.close();
      await service.waitForConnected(false);
      await service.changeUrl(getSerialWssUrl(port: server2.port));
      await service.waitForConnected(true);
      expect(service.connectedUrl, getSerialWssUrl(port: server2.port));
      await server2.close();

      server1 = await SerialServer.start(port: 0);
      await service.changeUrl(getSerialWssUrl(port: server1.port));
      await service.waitForConnected(true);
      expect(service.connectedUrl, getSerialWssUrl(port: server1.port));
      await server1.close();
    });
  });
}
