import 'dart:async';
import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/constant.dart' as swss;
import 'package:tekartik_serial_wss_client/message.dart' as swss;
@TestOn("vm")
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';

// Need real server running
main() {
  group('with_real_server', () {
    test('start_stop', () async {
      //Serial.debug.on = true;

      var completer = new Completer();
      SerialWssClientService wssService =
          new SerialWssClientService(ioWebSocketClientChannelFactory);
      wssService.start();
      wssService.onConnected.listen((bool connected) async {
        if (connected) {
          expect(wssService.isConnected, isTrue);

          /*
          List<DeviceInfo> deviceInfos = await wssService.serial.getDevices();
          print(deviceInfos);
          */

          completer.complete();
        }
      });

      await completer.future;
      await wssService.stop();
    });

    test('busy_error', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;

      var completer = new Completer();

      SerialWssClientService wssService =
          new SerialWssClientService(ioWebSocketClientChannelFactory);
      wssService.start();
      wssService.onConnected.listen((bool connected) async {
        if (connected) {
          List<DeviceInfo> deviceInfos = await wssService.serial.getDevices();
          if (deviceInfos.isEmpty) {
            print('no serial port available');
            completer.complete();
          } else {
            String path = deviceInfos.first.path;
            SerialStreamChannelService service1 =
                new SerialStreamChannelService(wssService, path: path);
            service1.start();

            SerialStreamChannelService service2 =
                new SerialStreamChannelService(wssService, path: path);
            service2.start();

            service2.onOpened.listen((bool opened) {
              completer.completeError("should not open");
            });
            service2.onOpenError.listen((swss.Error error) {
              expect(error.code, swss.errorCodePortBusy);
              service1.stop();
              service2.stop();
              completer.complete();
            });
          }
        }
      });

      await completer.future;
    });

    test('busy_then_available', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;

      var completer = new Completer();

      SerialWssClientService wssService =
          new SerialWssClientService(ioWebSocketClientChannelFactory);
      wssService.start();
      wssService.onConnected.listen((bool connected) async {
        if (connected) {
          List<DeviceInfo> deviceInfos = await wssService.serial.getDevices();
          if (deviceInfos.isEmpty) {
            print('no serial port available');
            completer.complete();
          } else {
            String path = deviceInfos.first.path;
            SerialStreamChannelService service1 =
                new SerialStreamChannelService(wssService, path: path);
            service1.start();

            SerialStreamChannelService service2 =
                new SerialStreamChannelService(wssService,
                    path: path, retryDelay: new Duration(milliseconds: 100));
            service2.start();

            bool wasBusy;
            service2.onOpened.listen((bool opened) async {
              if (!wasBusy) {
                completer.completeError("should not open");
              } else {
                await service2.stop();
                completer.complete();
              }
            });
            service2.onOpenError.listen((swss.Error error) {
              expect(error.code, swss.errorCodePortBusy);
              wasBusy = true;

              // Stopping the service1 should free the port
              service1.stop();
            });
          }
        }
      });

      await completer.future;
    });
  });
}
