import 'dart:async';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_common_utils/dev_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketChannelFactory {
  WebSocketChannel create(String url);
}

class SerialWssClientService {
  static DevFlag debug = new DevFlag("SerialWssClientService debug");
  // the serial service when connected
  Serial get serial => _serial;

  Serial _serial;
  final SerialClientInfo clientInfo;
  bool _shouldStop = false;
  Duration _retryDelay;
  final WebSocketChannelFactory _factory;
  SynchronizedLock _lock = new SynchronizedLock();
  bool _isStarted = false;

  bool get isStarted => _isStarted;

  bool get isConnected => serial != null;
  String _url;
  String _connectedUrl;
  String get connectedUrl => serial == null ? null : _connectedUrl;

  final StreamController<bool> _onConnectedController;
  Stream<bool> get onConnected => _onConnectedController.stream;

  @deprecated
  Stream<bool> get connected => onConnected;

  SerialWssClientService(WebSocketChannelFactory factory,
      {String url, SerialClientInfo clientInfo, Duration retryDelay})
      : clientInfo = clientInfo,
        _factory = factory,
        _onConnectedController = new StreamController.broadcast() {
    _url = url ?? serialWssUrlDefault;
    this._retryDelay = retryDelay ?? new Duration(seconds: 3);
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
    if (debug.on) {
      print('[SerialWssClientService] _onDisconnect');
    }
    _serial = null;
    _onConnectedController.add(false);
    if (!_shouldStop) {
      sleep(_retryDelay.inMilliseconds).then((_) {
        _tryConnect();
      });
    }
  }

  _connect() async {
    if (!isConnected) {
      await _lock.synchronized(() async {
        if (!isConnected) {
          String url = _url;
          if (debug.on) {
            print("[SerialWssClientService] connecting $url");
          }
          WebSocketChannel wsChannel = _factory.create(url);
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
            if (debug.on) {
              print('[SerialWssClientService] connect error: $error');
            }
          }, onDone: _onDisconnect);
          await serial.connected;
          this._serial = serial;
          this._connectedUrl = url;

          _onConnectedController.add(true);
          if (debug.on) {
            print("[SerialWssClientService] connected");
          }
        }
      });
    }
  }

  Future changeUrl(String url) async {
    if (url != _url) {
      this._url = url;
      await _stop();
      // try connecting right away
      await _connect();
    }
  }

  Future _stop() async {
    if (isConnected) {
      await _lock.synchronized(() async {
        if (isConnected) {
          await serial.close();
          _serial = null;
        }
      });
    }
  }

  Future stop() async {
    _shouldStop = true;
    _isStarted = false;
    await _stop();
  }

  Future waitForConnected(bool connected) async {
    if (isConnected == connected) {
      return new Future.value();
    }
    StreamSubscription subscription;
    var completer = new Completer();
    subscription = onConnected.listen((bool connected_) async {
      if (connected_ == connected) {
        subscription.cancel();
        completer.complete();
      }
    });
    return completer.future;
  }
}
