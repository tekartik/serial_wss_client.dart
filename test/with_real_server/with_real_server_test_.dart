@TestOn("vm")

import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';

import 'package:tekartik_serial_wss_client/message.dart' as swss;
import 'package:tekartik_serial_wss_client/constant.dart' as swss;

import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/service/io.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';

// Need real server running
main() {
  group('with_real_server', () {
    test('start_stop', () async {
      //Serial.debug.on = true;

      var completer = new Completer();
      SerialWssClientService wssService =
          new SerialWssClientService(ioWebSocketChannelFactory);
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
      Serial.debug.on = true;

      var completer = new Completer();

      SerialWssClientService wssService =
          new SerialWssClientService(ioWebSocketChannelFactory);
      wssService.start();
      wssService.onConnected.listen((bool connected) async {
        if (connected) {
          List<DeviceInfo> deviceInfos = await wssService.serial.getDevices();
          if (deviceInfos.isEmpty) {
            print('no serial port available');
          } else {
            String path = deviceInfos.first.path;
            SerialStreamChannelService service1 =
                new SerialStreamChannelService(wssService, path: path);
            service1.start();

            SerialStreamChannelService service2 =
                new SerialStreamChannelService(wssService, path: path);
            service2.start();

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
  });
}
