library test_menu;

import 'dart:typed_data';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';
import 'package:web_socket_channel/html.dart';
import 'terminal_menu.dart';

serverMenu() {
  item('connect', () {
    //bkhihefblpdldecdffhliielibdiaeac
  });
}

serialMenu() {
  Serial serial;
  bool logData = false;

  _connect() async {
    try {
      if (serial == null) {
        String url = "ws://localhost:8988";
        write("connecting $url");
        HtmlWebSocketChannel channel = new HtmlWebSocketChannel.connect(url);
        /*
      channel.stream.listen((message) {
        write('message $message');
      }, onError: (e) => write("error $e"), onDone: () => write("done"));
      */
        serial = new Serial(channel,
            clientInfo: new SerialClientInfo()
              ..name = "serial_wss_client_test_menu"
              ..version = new Version(0, 1, 0), onDataReceived: (data) {
          if (logData) {
            write('recv ${data.runtimeType} ${data}');
          }
        }, onDataSent: (data) {
          if (logData) {
            write('send ${data.runtimeType} ${data}');
          }
        }, onError: (error) {
          write('connect error: $error');
        }, onDone: () {
          write('connect done');
          serial = null;
        });
        bool connected = await serial.connected;
        write("connected $connected");
      }
    } catch (e) {
      //write(e);
      rethrow;
    }
  }

  item('toggle log', () {
    logData = !logData;
    write('logs ${logData ? "on" : "off"}');
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
    List<DeviceInfo> deviceInfos = await serial.getDevices();
    write("${deviceInfos.length} devices${deviceInfos.length > 0 ? ':' : ''}");
    for (DeviceInfo deviceInfo in deviceInfos) {
      write(deviceInfo.toMap());
    }
  });

  item('connect_disconnect_first', () async {
    await _connect();
    List<DeviceInfo> deviceInfos = await serial.getDevices();
    if (deviceInfos.length > 0) {
      ConnectionInfo connectionInfo =
          await serial.connect(deviceInfos.first.path);
      write("connect: ${connectionInfo.toMap()}");

      bool result = await serial.disconnect(connectionInfo.connectionId);
      write("disconnect: ${result}");
    } else {
      write("no devices");
    }
  });

  SerialStreamChannel serialStreamChannel;

  item('serial connect_first', () async {
    await _connect();
    List<DeviceInfo> deviceInfos = await serial.getDevices();
    if (deviceInfos.length > 0) {
      serialStreamChannel = await serial.createChannel(deviceInfos.first.path);
      write("connected: ${serialStreamChannel.info.toMap()}");
    } else {
      write("no devices");
    }
  });

  item('serial send data', () async {
    if (serialStreamChannel != null) {
      serialStreamChannel.sink
          .add(new Uint8List.fromList("hello from client".codeUnits));
    } else {
      write('not connected');
    }
  });

  item('flush', () async {
    if (serialStreamChannel != null) {
      await serial.flush(serialStreamChannel.info.connectionId);
    } else {
      write('not connected');
    }
  });

  item('serial disconnect', () async {
    if (serialStreamChannel != null) {
      bool result =
          await serial.disconnect(serialStreamChannel.info.connectionId);
      write("disconnect: ${result}");
      //connectionInfo = null;
    } else {
      write('not connected');
    }
  });

  SerialStreamChannel serialStreamChannelA;
  _disconnectNullA() async {
    if (serialStreamChannelA != null) {
      bool result =
          await serial.disconnect(serialStreamChannelA.info.connectionId);
      write("disconnected: ${result}");
      serialStreamChannelA = null;
    }
  }

  item('connect null_a', () async {
    await _connect();
    //_disconnectNullA();
    serialStreamChannelA = await serial.createChannel("/null/a");
    write("connect: ${serialStreamChannelA.info.toMap()}");
  });

  item('disconnect null_a', () async {
    await _connect();
    await _disconnectNullA();
  });

  item('send null_a', () async {
    await _connect();
    if (serialStreamChannelA != null) {
      serial.send(serialStreamChannelA.info.connectionId,
          new Uint8List.fromList(UTF8.encode("hello from a")));
    }
  });

  item('send/recv channel null_a', () async {
    await _connect();
    if (serialStreamChannelA != null) {
      serialStreamChannelA.sink.add("channel_send".codeUnits);
      serialStreamChannelA.stream.listen((List<int> data) {
        write("channel_recv: $data");
      });
    }
  });

  SerialStreamChannel serialStreamChannelB;
  _disconnectNullB() async {
    if (serialStreamChannelB != null) {
      bool result =
          await serial.disconnect(serialStreamChannelB.info.connectionId);
      write("disconnected: ${result}");
      serialStreamChannelB = null;
    }
  }

  item('connect null_b', () async {
    await _connect();
    //_disconnectNullA();
    serialStreamChannelB = await serial.createChannel("/null/b");
    write("connect: ${serialStreamChannelB.info.toMap()}");
  });

  item('disconnect null_b', () async {
    await _connect();
    await _disconnectNullB();
  });

  item('send null_b', () async {
    await _connect();
    if (serialStreamChannelB != null) {
      serial.send(serialStreamChannelB.info.connectionId,
          new Uint8List.fromList("hello from a".codeUnits));
    }
  });
}

main() async {
  await initTestMenuBrowser(); //js: ['test_menu.js']);

  menu('main', () {
    item("write hola", () async {
      write('Hola');
      //write('RESULT prompt: ${await prompt()}');
    });
    item("prompt", () async {
      write('RESULT prompt: ${await prompt('Some text please then [ENTER]')}');
    });
    item("js console.log", () {
      js_test('testConsoleLog');
    });
    item("print hi", () {
      print('hi');
    });
    item("crash", () {
      throw "Hi";
    });
    menu('sub', () {
      item("print hi", () => print('hi'));
    });

    menu('serial', serialMenu);
    menu('terminal', terminalMenu);
  });
}
