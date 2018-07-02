library test_menu;

import 'dart:typed_data';
//import 'package:tekartik_serial_wss_client/message.dart';
import 'package:tekartik_serial_wss_client/message.dart' as swss;
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_test_menu/test_menu_mdl_browser.dart';
import 'package:web_socket_channel/html.dart';
//import 'package:dart2_constant/convert.dart';

terminalMenu() {
  Serial serial;
  bool logJson = false;
  bool logRecv = false;

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
          if (logJson) {
            bool _log = true;
            if (!logRecv) {
              swss.Message message =
                  swss.Message.parseMap(parseJsonObject(data as String));
              if (message is swss.Notification) {
                if (message.method == swss.methodReceive) {
                  _log = false;
                }
              }
            }
            if (_log) {
              write('recv ${data.runtimeType} ${data}');
            }
          }
        }, onDataSent: (data) {
          if (logJson) {
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

  item('toggle json log', () {
    logJson = !logJson;
    write('logs ${logJson ? "on" : "off"}');
  });

  item('toggle rcv log', () {
    logRecv = !logRecv;
    write('logs rcv ${logRecv ? "on" : "off"}');
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

  SerialStreamChannel serialStreamChannel;

  item('connect', () async {
    String path = await prompt("Enter serial port path");
    serialStreamChannel = await serial.createChannel(path);
    write(serialStreamChannel);
  });

  item('connect /dev/ttyUSB0', () async {
    await _connect();
    serialStreamChannel = await serial.createChannel('/dev/ttyUSB0');
    write(serialStreamChannel);
  });

  // for gps smart
  item('connect /dev/ttyUSB0 38400', () async {
    await _connect();
    ConnectionOptions options = new ConnectionOptions()..bitrate = 38400;
    serialStreamChannel =
        await serial.createChannel('/dev/ttyUSB0', options: options);
    write(serialStreamChannel);
  });

  item('connect /dev/ttyUSB1', () async {
    await _connect();
    serialStreamChannel = await serial.createChannel('/dev/ttyUSB1');
    write(serialStreamChannel);
  });

  StreamSubscription dataSubscription;

  item('toggle recv data lines log', () {
    if (dataSubscription != null) {
      dataSubscription.cancel();
      write("subscription cancelled");
      dataSubscription = null;
    } else if (serialStreamChannel != null) {
      serialStreamChannel.stream
          .transform(UTF8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        write('line: $line');
      });
      write("subscribed");
    } else {
      write("no connection");
    }
  });

  item('serial connect_first', () async {
    await _connect();
    List<DeviceInfo> deviceInfos = await serial.getDevices();
    if (deviceInfos.length > 0) {
      serialStreamChannel = await serial.createChannel(deviceInfos.first.path);
      write("connected: ${serialStreamChannel.connectionInfo.toMap()}");
    } else {
      write("no devices");
    }
  });

  item('serial send data', () async {
    if (serialStreamChannel != null) {
      write(
          "send: ${await serial.send(serialStreamChannel.connectionInfo.connectionId,
          new Uint8List.fromList("hello from client".codeUnits))}");
    } else {
      write('not connected');
    }
  });

  _send(String cmd) async {
    if (serialStreamChannel != null) {
      write(
          "send: ${await serial.send(serialStreamChannel.connectionInfo.connectionId,
          new Uint8List.fromList(cmd.codeUnits))}");
    } else {
      write('not connected');
    }
  }

  item('serial send AT+CGPSSTATUS?', () async {
    await _send("AT+CGPSSTATUS=?\r\n");
  });

  item('flush', () async {
    if (serialStreamChannel != null) {
      write(
          "flush: ${await serial.flush(serialStreamChannel.connectionInfo.connectionId)}");
    } else {
      write('not connected');
    }
  });

  item('serial disconnect', () async {
    if (serialStreamChannel != null) {
      bool result = await serial
          .disconnect(serialStreamChannel.connectionInfo.connectionId);
      write("disconnect: ${result}");
      //connectionInfo = null;
    } else {
      write('not connected');
    }
  });
}
