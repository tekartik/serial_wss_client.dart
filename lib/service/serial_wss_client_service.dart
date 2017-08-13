import 'dart:async';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketChannelFactory {
  WebSocketChannel create(String url);
}

class SerialWssClientService {
  Serial serial;
  final SerialClientInfo clientInfo;
  bool _shouldStop = false;
  Duration retryDelay;
  final WebSocketChannelFactory _factory;
  SynchronizedLock _lock = new SynchronizedLock();
  bool _isStarted = false;
  Completer _stopCompleter;

  bool get isStarted => _isStarted;

  bool get isConnected => serial != null;
  String _url;

  final StreamController<bool> _connectedController;
  Stream<bool> get connected => _connectedController.stream;

  SerialWssClientService(WebSocketChannelFactory factory,
      {String url, SerialClientInfo clientInfo, Duration retryDelay})
      : clientInfo = clientInfo,
        _factory = factory, _connectedController = new StreamController.broadcast() {
    _url = url ?? serialWssUrlDefault;
    this.retryDelay = retryDelay ?? new Duration(seconds: 3);
  }

  // must be started explicitely
  void start() {
    if (!_isStarted) {
      _isStarted = true;
      _tryConnect();
    }
  }

  _tryConnect() async {
    try {
      await _connect();
    } catch (e) {
      print(e);
    }
  }

  _onDisconnect() {
    print("_onDisconnect");
    if (!_shouldStop) {
      serial = null;
      if (_stopCompleter != null) {
        _stopCompleter.complete();
        _stopCompleter = null;
      }
      _connectedController.add(false);
      sleep(retryDelay.inMilliseconds).then((_) {
        _tryConnect();
      });
    }
  }

  _connect() async {
    if (!isConnected) {
      await _lock.synchronized(() async {
        WebSocketChannel wsChannel = _factory.create(_url);
        Serial serial = new Serial(wsChannel, clientInfo: clientInfo,
            onDataReceived: (data) {
          /*
      if (logJson) {
      bool _log = true;
      if (!logRecv) {
      swss.Message message =
      swss.Message.parseMap(parseJsonObject(data));
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
      */
        }, onDataSent: (data) {
          /*
      if (logJson) {
      write('send ${data.runtimeType} ${data}');
      }
      */
        }, onError: (error) {
          print('connect error: $error');
        }, onDone: _onDisconnect);
        await serial.connected;
        this.serial = serial;
        _connectedController.add(true);
        print("connected");
      });
    }
  }

  Future setUrl(String url) async {
    if (url != _url) {
      await _stop();
    }
  }

  Future _stop() async {
    if (isConnected) {
      await _lock.synchronized(() async {
        if (isConnected) {
          _stopCompleter = new Completer.sync();
          await serial.close();
          await _stopCompleter.future;
        }
      });
    }
  }

  Future stop() async {
    _shouldStop = true;
    await _stop();
  }
/*
serial = new Serial(channel,
clientInfo: new SerialClientInfo()
..name = "serial_wss_client_test_menu"
..version = new Version(0, 1, 0), onDataReceived: (data) {
if (logJson) {
bool _log = true;
if (!logRecv) {
swss.Message message =
swss.Message.parseMap(parseJsonObject(data));
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
  */
}
