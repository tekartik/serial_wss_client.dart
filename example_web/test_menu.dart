library test_menu;

import 'dart:typed_data';

import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
//import 'package:tekartik_test_menu/src/common_import.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';
import 'package:tekartik_web_socket_browser/web_socket_browser.dart';
import 'package:web_socket_channel/html.dart';

import 'terminal_menu.dart';
import 'wss_client_service_menu.dart';
import 'wss_stream_channel_service_menu.dart';

void serverMenu() {
  item('connect', () {
    //bkhihefblpdldecdffhliielibdiaeac
  });
}

void serialMenu() {
  Serial serial;
  var logData = false;

  Future _connect() async {
    try {
      if (serial == null) {
        var url = 'ws://localhost:8988';
        write('connecting $url');
        var channel = HtmlWebSocketChannel.connect(url);
        /*
      channel.stream.listen((message) {
        write('message $message');
      }, onError: (e) => write('error $e'), onDone: () => write('done'));
      */
        serial = Serial(channel,
            clientInfo: SerialClientInfo()
              ..name = 'serial_wss_client_test_menu'
              ..version = Version(0, 1, 0), onDataReceived: (data) {
          if (logData) {
            write('recv ${data.runtimeType} $data');
          }
        }, onDataSent: (data) {
          if (logData) {
            write('send ${data.runtimeType} $data');
          }
        }, onError: (error) {
          write('connect error: $error');
        }, onDone: () {
          write('connect done');
          serial = null;
        });
        var connected = await serial.connected;
        write('connected $connected');
      }
    } catch (e) {
      //write(e);
      rethrow;
    }
  }

  item('toggle log', () {
    logData = !logData;
    write('logs ${logData ? 'on' : 'off'}');
  });
  item('connect', () async {
    await _connect();
  });

  item('close', () async {
    await _connect();
    serial.close();
  });

  item('getDevices', () async {
    await _connect();
    var deviceInfos = await serial.getDevices();
    write('${deviceInfos.length} devices${deviceInfos.isNotEmpty ? ':' : ''}');
    for (var deviceInfo in deviceInfos) {
      write(deviceInfo.toMap());
    }
  });

  item('connect_disconnect_first', () async {
    await _connect();
    var deviceInfos = await serial.getDevices();
    if (deviceInfos.isNotEmpty) {
      var connectionInfo = await serial.connect(deviceInfos.first.path);
      write('connect: ${connectionInfo.toMap()}');

      var result = await serial.disconnect(connectionInfo.connectionId);
      write('disconnect: $result');
    } else {
      write('no devices');
    }
  });

  SerialStreamChannel serialStreamChannel;

  item('serial connect_first', () async {
    await _connect();
    var deviceInfos = await serial.getDevices();
    if (deviceInfos.isNotEmpty) {
      serialStreamChannel = await serial.createChannel(deviceInfos.first.path);
      write('connected: ${serialStreamChannel.connectionInfo.toMap()}');
    } else {
      write('no devices');
    }
  });

  item('serial send data', () async {
    if (serialStreamChannel != null) {
      serialStreamChannel.sink
          .add(Uint8List.fromList('hello from client'.codeUnits));
    } else {
      write('not connected');
    }
  });

  item('flush', () async {
    if (serialStreamChannel != null) {
      await serial.flush(serialStreamChannel.connectionInfo.connectionId);
    } else {
      write('not connected');
    }
  });

  item('serial disconnect', () async {
    if (serialStreamChannel != null) {
      var result = await serial
          .disconnect(serialStreamChannel.connectionInfo.connectionId);
      write('disconnect: $result');
      //connectionInfo = null;
    } else {
      write('not connected');
    }
  });

  SerialStreamChannel serialStreamChannelA;
  Future _disconnectNullA() async {
    if (serialStreamChannelA != null) {
      var result = await serial
          .disconnect(serialStreamChannelA.connectionInfo.connectionId);
      write('disconnected: $result');
      serialStreamChannelA = null;
    }
  }

  item('connect null_a', () async {
    await _connect();
    //_disconnectNullA();
    serialStreamChannelA = await serial.createChannel('/null/a');
    write('connect: ${serialStreamChannelA.connectionInfo.toMap()}');
  });

  item('disconnect null_a', () async {
    await _connect();
    await _disconnectNullA();
  });

  item('send null_a', () async {
    await _connect();
    if (serialStreamChannelA != null) {
      await serial.send(serialStreamChannelA.connectionInfo.connectionId,
          Uint8List.fromList(utf8.encode('hello from a')));
    }
  });

  item('send/recv channel null_a', () async {
    await _connect();
    if (serialStreamChannelA != null) {
      serialStreamChannelA.sink.add('channel_send'.codeUnits);
      serialStreamChannelA.stream.listen((List<int> data) {
        write('channel_recv: $data');
      });
    }
  });

  SerialStreamChannel serialStreamChannelB;
  Future _disconnectNullB() async {
    if (serialStreamChannelB != null) {
      var result = await serial
          .disconnect(serialStreamChannelB.connectionInfo.connectionId);
      write('disconnected: $result');
      serialStreamChannelB = null;
    }
  }

  item('connect null_b', () async {
    await _connect();
    //_disconnectNullA();
    serialStreamChannelB = await serial.createChannel('/null/b');
    write('connect: ${serialStreamChannelB.connectionInfo.toMap()}');
  });

  item('disconnect null_b', () async {
    await _connect();
    await _disconnectNullB();
  });

  item('send null_b', () async {
    await _connect();
    if (serialStreamChannelB != null) {
      await serial.send(serialStreamChannelB.connectionInfo.connectionId,
          Uint8List.fromList('hello from a'.codeUnits));
    }
  });
}

Future main() async {
  await initTestMenuBrowser(); //js: ['test_menu.js']);
  menu('serial', serialMenu);
  menu('terminal', terminalMenu);
  menu('wss client service', () {
    wssClientServiceMenu(webSocketClientChannelFactoryBrowser);
  });

  menu('wss stream channel service', () {
    wssStreamChannelServiceMenu(webSocketClientChannelFactoryBrowser);
  });
}
