import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'dart:async';
import 'package:synchronized/synchronized.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'serial_wss_client_service.dart';

class _SerialStreamChannelServiceSink implements StreamSink<List<int>> {
  final SerialStreamChannelService service;

  _SerialStreamChannelServiceSink(this.service);

  @override
  void add(List<int> data) {
    if (service._currentChannel != null) {
      service._currentChannel.sink.add(data);
    }
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    if (service._currentChannel != null) {
      service._currentChannel.sink.addError(error, stackTrace);
    }
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    Completer completer = new Completer();
    stream.listen((data) => add(data)).onDone(() {
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future get done => service.done;

  @override
  Future close() async {
    await service._close();
  }
}

class _SerialStreamChannel extends StreamChannelMixin<List<int>> {
  final SerialStreamChannelService service;

  _SerialStreamChannel(this.service);

  @override
  StreamSink<List<int>> get sink => service.sink;

  @override
  Stream<List<int>> get stream => service.stream;

  @override
  String toString() => "${service.currentChannel}";
}

class SerialStreamChannelService {
  static DevFlag debug = new DevFlag("SerialStreamChannelService debug");

  // this only happens on close
  Completer _doneCompleter = new Completer();

  Future get done => _doneCompleter.future;
  SynchronizedLock _lock = new SynchronizedLock();
  SynchronizedLock _openCloseLock = new SynchronizedLock();
  ConnectionOptions _connectionOptions;

  String _path;
  Duration _retryDelay;

  bool _isStarted = false;
  bool get isStarted => _isStarted;
  bool _shouldStop = false;

  // The exported channel that never closes
  StreamChannel<List<int>> get channel => _channel;
  _SerialStreamChannel _channel;

  // current channel if any
  SerialStreamChannel _currentChannel;
  SerialStreamChannel get currentChannel => _currentChannel;

  bool get isOpened => _currentChannel != null;
  final SerialWssClientService _serialWssClientService;

  final StreamController _onOpenErrorController;

  // Listen to get the last error
  Stream get onOpenError => _onOpenErrorController.stream;

  final StreamController<bool> _onOpenedController;

  // listen to know when being opened
  Stream<bool> get onOpened => _onOpenedController.stream;

  // exposed to send test data
  StreamController<List<int>> _streamController = new StreamController();
  StreamController<List<int>> get streamController => _streamController;

  // The stream to listen to
  Stream<List<int>> get stream => _streamController.stream;

  // The sink to post to
  StreamSink<List<int>> get sink => _sink;
  StreamSink<List<int>> _sink;

  SerialStreamChannelService(SerialWssClientService serialWssClientService,
      {ConnectionOptions connectionOptions, String path, Duration retryDelay})
      : _connectionOptions = connectionOptions,
        _path = path,
        _onOpenedController = new StreamController.broadcast(),
        _onOpenErrorController = new StreamController.broadcast(),
        _serialWssClientService = serialWssClientService {
    this._retryDelay = retryDelay ?? new Duration(seconds: 3);
    _sink = new _SerialStreamChannelServiceSink(this);
    _channel = new _SerialStreamChannel(this);
    _serialWssClientService.onConnected.listen(_onConnected);
  }

  // The service won't be used anymore
  terminate() async {
    stop();
    await _sink.close();
  }

  // Called when
  _onConnected(bool connected) {
    //devPrint('[SerialStreamChannelService] onConnected($connected)');
    if (connected) {
      if (_isStarted) {
        _tryOpen();
      }
    } else {
      // Mark the channel closed

      _close();
    }
  }

  _onClose() {
    if (debug.on) {
      print('[SerialStreamChannelService] onClose $_channel');
    }
    // Simple setting the channel to null mark it as closed
    _currentChannel = null;
    _onOpenedController.add(false);
    _retryIfNeeded();
  }

  void _retryIfNeeded() {
    if (!_shouldStop) {
      sleep(_retryDelay.inMilliseconds).then((_) {
        _tryOpen();
      });
    }
  }

  // must be started explicitely
  void start() {
    if (!_isStarted) {
      _isStarted = true;
      _tryOpen();
    }
  }

  Future stop() async {
    _shouldStop = true;
    await _stop();
  }

  Future _stop() async {
    if (_isStarted) {
      await _lock.synchronized(() async {
        if (_isStarted) {
          _isStarted = false;
          await _close();
        }
      });
    }
  }

  _tryOpen() async {
    if (_isStarted && _serialWssClientService.isConnected && !isOpened) {
      await _openCloseLock.synchronized(() async {
        if (!isOpened) {
          try {
            await _open();
          } catch (e) {
            print(e);
          }
          //devPrint('[SerialStreamChannelService] opening done');
        }
      });
    }
  }

  Future _close() async {
    //devPrint('[SerialStreamChannelService] _close($_channel)');
    if (isOpened) {
      await _openCloseLock.synchronized(() async {
        if (isOpened) {
          if (debug.on) {
            print('[SerialStreamChannelService] closing...');
          }
          var channel = _currentChannel;
          _onClose();

          try {
            await channel.close();
          } catch (e) {
            print(e);
          }
          if (debug.on) {
            print('[SerialStreamChannelService] closing done');
          }
        }
      });
    }
    //devPrint('[SerialStreamChannelService] _close2(isOpened = $isOpened)');
  }

  _open() async {
    if (!isOpened) {
      await _lock.synchronized(() async {
        if (!isOpened) {
          SerialStreamChannel channel;
          try {
            if (debug.on) {
              print(
                  '[SerialStreamChannelService] creating channel ($_path, $_connectionOptions)...');
            }
            //devPrint('[SerialStreamChannelService] creating channel...');

            channel = await _serialWssClientService.serial
                .createChannel(_path, options: _connectionOptions);

            // Add input stream
            // nothing to do for output stream
            channel.stream.listen((List<int> data) {
              _streamController.add(data);
            });

            // notify callers
            _onOpenedController.add(true);

            _currentChannel = channel;

            if (debug.on) {
              print(
                  '[SerialStreamChannelService] creating channel done ${_currentChannel}');
            }
          } catch (e) {
            if (debug.on) {
              print('[SerialStreamChannelService] creating channel error $e');
            }
            // Try to reconnect automatically
            _retryIfNeeded();
            _onOpenErrorController.add(e);
          }
        }
      });
    }
  }

  Future changeConnection(String path, {ConnectionOptions options}) async {
    _path = path;
    _connectionOptions = options;
    await _close();
    // try connecting right away
    await _tryOpen();
  }

  Future waitForOpen(bool opened) async {
    if (isOpened == opened) {
      return new Future.value();
    }
    StreamSubscription subscription;
    var completer = new Completer();
    subscription = onOpened.listen((bool opened_) async {
      if (opened_ == opened) {
        subscription.cancel();
        completer.complete();
      }
    });
    return completer.future;
  }
}
