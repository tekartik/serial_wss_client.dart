// Copyright (c) 2017, alex. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Support for doing something awesome.
///
/// More dartdocs go here.
library serial_wss_client;

import 'dart:async';
import 'dart:typed_data';
import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/message.dart';
import 'package:func/func.dart';
import 'package:tekartik_common_utils/json_utils.dart';
import 'package:tekartik_common_utils/bool_utils.dart';
import 'package:event_bus/event_bus.dart';
import 'package:tekartik_common_utils/hex_utils.dart';

// Minimum expected server version
// Best is however 0.6.0 at this point
Version minVersion = new Version(0, 5, 0);

const int _maxQueryId = 10000;
const Duration requestTimeoutDuration = const Duration(milliseconds: 5000);

// Broadcast when serial is done
class _SerialDoneEvent {}

// Data broadcasted to listener
class _SerialDataMapEvent {
  Map<String, dynamic> data;
  _SerialDataMapEvent(this.data);
}

class DeviceInfo {
  String path;
  int vendorId;
  int productId;
  String displayName;

  fromMap(Map map) {
    path = map["path"];
    vendorId = map["vendorId"];
    productId = map["productId"];
    displayName = map["displayName"];
  }

  toMap() {
    Map map = {};
    if (path != null) {
      map['path'] = path;
    }
    if (vendorId != null) {
      map['vendorId'] = vendorId;
    }
    if (path != null) {
      map['productId'] = productId;
    }
    if (path != null) {
      map['displayName'] = displayName;
    }
    return map;
  }

  @override
  toString() {
    return displayName ?? path;
  }
}

// "dataBits":"eight","name":"","parityBit":"no","paused":false,"persistent":false,"receiveTimeout":0,"sendTimeout":0,"stopBits":"one"}

// ConnectionOptions
/*
boolean	(optional) persistent
Flag indicating whether or not the connection should be left open when the application is suspended (see Manage App Lifecycle). The default value is "false." When the application is loaded, any serial connections previously opened with persistent=true can be fetched with getConnections.

string	(optional) name
An application-defined string to associate with the connection.

integer	(optional) bufferSize
The size of the buffer used to receive data. The default value is 4096.

integer	(optional) bitrate
The requested bitrate of the connection to be opened. For compatibility with the widest range of hardware, this number should match one of commonly-available bitrates, such as 110, 300, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200. There is no guarantee, of course, that the device connected to the serial port will support the requested bitrate, even if the port itself supports that bitrate. 9600 will be passed by default.

DataBits	(optional) dataBits
"eight" will be passed by default.

ParityBit	(optional) parityBit
"no" will be passed by default.

StopBits	(optional) stopBits
"one" will be passed by default.

boolean	(optional) ctsFlowControl
Flag indicating whether or not to enable RTS/CTS hardware flow control. Defaults to false.

integer	(optional) receiveTimeout
The maximum amount of time (in milliseconds) to wait for new data before raising an onReceiveError event with a "timeout" error. If zero, receive timeout errors will not be raised for the connection. Defaults to 0.

integer	(optional) sendTimeout
The maximum amount of time (in milliseconds) to wait for a send operation to complete before calling the callback with a "timeout" error. If zero, send timeout errors will not be triggered. Defaults to 0.
 */
class ConnectionOptions {
  bool persistent;
  String name;
  int bufferSize;
  int bitrate;
  String dataBits;
  String parityBit;
  String stopBits;
  bool ctsFlowControl;
  int receiveTimeout;
  int sendTimeout;

  fromMap(Map map) {
    if (map != null) {
      persistent = parseBool(map["persistent"]);
      name = map["name"]?.toString();
      bufferSize = parseInt(map["bufferSize"]);
      bitrate = parseInt(map["bitrate"]);
      dataBits = map["dataBits"]?.toString();
      parityBit = map["parityBit"];
      stopBits = map["stopBits"]?.toString();
      dataBits = map["dataBits"]?.toString();
      ctsFlowControl = parseBool(map["ctsFlowControl"]);
      receiveTimeout = parseInt(map["receiveTimeout"]);
      sendTimeout = parseInt(map["sendTimeout"]);
    }
  }

  Map toMap() {
    Map map = {};
    if (name != null) {
      map['name'] = name;
    }
    if (persistent != null) {
      map['persistent'] = persistent;
    }
    if (bufferSize != null) {
      map['bufferSize'] = bufferSize;
    }
    if (bitrate != null) {
      map['bitrate'] = bitrate;
    }
    if (dataBits != null) {
      map['dataBits'] = dataBits;
    }
    if (parityBit != null) {
      map['parityBit'] = parityBit;
    }
    if (stopBits != null) {
      map['stopBits'] = stopBits;
    }
    if (ctsFlowControl != null) {
      map['ctsFlowControl'] = ctsFlowControl;
    }
    if (receiveTimeout != null) {
      map['receiveTimeout'] = receiveTimeout;
    }
    if (sendTimeout != null) {
      map['sendTimeout'] = sendTimeout;
    }
    return map;
  }

  toString() => toMap().toString();
}

// ConnectionInfo
/*
integer	connectionId
The id of the serial port connection.

boolean	paused
Flag indicating whether the connection is blocked from firing onReceive events.

boolean	persistent
See ConnectionOptions.persistent

string	name
See ConnectionOptions.name

integer	bufferSize
See ConnectionOptions.bufferSize

integer	receiveTimeout
See ConnectionOptions.receiveTimeout

integer	sendTimeout
See ConnectionOptions.sendTimeout

integer	(optional) bitrate
See ConnectionOptions.bitrate. This field may be omitted or inaccurate if a non-standard bitrate is in use, or if an error occurred while querying the underlying device.

DataBits	(optional) dataBits
See ConnectionOptions.dataBits. This field may be omitted if an error occurred while querying the underlying device.

ParityBit	(optional) parityBit
See ConnectionOptions.parityBit. This field may be omitted if an error occurred while querying the underlying device.

StopBits	(optional) stopBits
See ConnectionOptions.stopBits. This field may be omitted if an error occurred while querying the underlying device.

boolean	(optional) ctsFlowControl
See ConnectionOptions.ctsFlowControl. This field may be omitted if an error occurred while querying the underlying device.
 */
class ConnectionInfo extends ConnectionOptions {
  int connectionId;

  fromMap(Map map) {
    super.fromMap(map);
    connectionId = parseInt(map["connectionId"]);
  }

  Map toMap() {
    Map map = super.toMap();
    if (connectionId != null) {
      map["connectionId"] = connectionId;
    }
    return map;
  }

  toString() => '${toMap()}';
}

/*
  /*
  The callback parameter should be a function that looks like this:

function(object sendInfo) {...};
object	sendInfo
integer	bytesSent
The number of bytes sent.

enum of "disconnected", "pending", "timeout", or "system_error"

	(optional) error
An error code if an error occurred.
disconnected: The connection was disconnected.
pendin: A send was already pending.
timeout: The send timed out.
system_error: A system error occurred and the connection may be unrecoverable.

   */
 */
class SendInfo {
  int bytesSent;
  String error;

  fromMap(Map map) {
    bytesSent = map["bytesSent"];
    error = map["error"];
  }

  Map toMap() {
    Map map = {};
    map['bytesSent'] = bytesSent;
    if (error != null) {
      map['error'] = error;
    }
    return map;
  }

  toString() => '${toMap()}';
}

class SerialServerVersionException implements Exception {
  final Version serverVersion;

  SerialServerVersionException(this.serverVersion);

  String toString() {
    return "SerialServerVersionException: Server version ${serverVersion} not supported. Version min ${minVersion} required";
  }
}

class SerialClientInfo {
  String name;
  Version version;
  Map toMap() {
    var map = {"name": name, "version": version?.toString()};
    return map;
  }
}

class _SerialStreamSink implements StreamSink<List<int>> {
  final SerialStreamChannel channel;

  Completer doneCompleter = new Completer();
  _SerialStreamSink(this.channel);

  @override
  void add(List<int> data) {
    channel._serial.send(
        channel.connectionInfo.connectionId, new Uint8List.fromList(data));
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    // ignore?
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
  Future get done => doneCompleter.future;

  Future _close() async {
    if (!doneCompleter.isCompleted) {
      doneCompleter.complete();
    }
  }

  @override
  Future close() async {
    try {
      await channel._serial.disconnect(channel.connectionInfo.connectionId);
    } catch (e) {
      print("close error: $e");
    }
    await _close();
  }
}

// helper to get a direct channel from the
// serial connection
class SerialStreamChannel extends StreamChannelMixin<List<int>> {
  final Serial _serial;
  final String path;
  final ConnectionInfo connectionInfo;
  StreamController<List<int>> _streamController = new StreamController();

  _SerialStreamSink _sink;

  SerialStreamChannel._(this._serial, this.path, this.connectionInfo) {
    _sink = new _SerialStreamSink(this);
  }

  @override
  StreamSink<List<int>> get sink => _sink;

  @override
  Stream<List<int>> get stream => _streamController.stream;

  Future close() async {
    await sink.close();
  }

  _close() async {
    await _streamController.close();
    _sink._close();
  }

  int get connectionId => connectionInfo.connectionId;

  @override
  String toString() => "$path $connectionInfo";
}

class Serial {
  static DevFlag debug = new DevFlag("Serial debug");

  StreamChannel _streamChannel;
  bool _done = false;

  int _lastRequestId = 0;
  int get _nextRequestId {
    if (++_lastRequestId > _maxQueryId) {
      _lastRequestId = 1;
    }
    return _lastRequestId;
  }

  // receiving data
  StreamSubscription _receiveSubscription;
  // receiving info - first step
  StreamSubscription _infoSubscription;
  Completer<bool> _connectedCompleter = new Completer();
  EventBus _eventBus = new EventBus();
  bool _connected = false;

  bool get isConnected => _connected;

  Duration commandTimeOutDuration = new Duration(seconds: 5);

  //StreamController<List<int>> _onReceiveController = new StreamController();
  //Stream<List<int>> get onReceive => _onReceiveController.stream;

  Map<int, SerialStreamChannel> _serialStreamChannels = {};

  Func1 _onDataReceived;
  Func1 _onDataSent;

  Version serverVersion;

  // Step1 of connection wait for server info
  // bool _serverInfoReceived;
  // Step2 of connection wait for init request
  // Connect and handle error
  Serial(StreamChannel streamChannel,
      {SerialClientInfo clientInfo,
      // for debugging, show json prc messages
      void onDataReceived(var data),
      // for debugging, show json prc messages
      void onDataSent(var data),
      void onError(var error),
      void onDone()})
      : _streamChannel = streamChannel {
    _onDataReceived = onDataReceived;
    _onDataSent = onDataSent;

    _infoSubscription = _eventBus.on(_SerialDataMapEvent)
        // ignore: strong_mode_uses_dynamic_as_bottom
        .listen((event) async {
      Map map = event.data;

      //devPrint(map);
      // extra completed validation
      if (!_connectedCompleter.isCompleted) {
        try {
          Message message = Message.parseMap(map);
          if (message is Notification) {
            if (message.method == methodInfo) {
              Map info = message.params;
              var package = info["package"];
              if (package is String) {
                if (package.startsWith(serialWssPackagePrefix)) {
                  String versionText = info["version"];
                  if (versionText is String) {
                    serverVersion = parseVersion(versionText);

                    // Check version, for now >= 0.1
                    if (serverVersion < minVersion) {
                      _connectedCompleter.completeError(
                          new SerialServerVersionException(serverVersion));
                      return;
                    } else {
                      // stop info subscription and send init
                      _stopInfoSubscription();
                      await _init(clientInfo);
                      //devPrint("inited");
                      if (!_connectedCompleter.isCompleted) {
                        _startReceiveSubscription();
                        _connectedCompleter.complete(true);
                        _connected = true;
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (e) {}
      }
    });

    _streamChannel.stream.listen((data) {
      if (debug.on) {
        print("[Serial] recv($data)");
      }
      //devPrint("recv: $data");

      if (_onDataReceived != null) {
        _onDataReceived(data);
      }
      // fire event when receiving map info
      Map<String, dynamic> map;
      try {
        map = parseJsonObject(data);
      } catch (e) {
        print(e);
      }
      if (map != null) {
        //devPrint("firing $map");
        _eventBus.fire(new _SerialDataMapEvent(map));
      }
    }, onError: (error) {
      if (debug.on) {
        print("[Serial] onError($error)");
      }
      //devError(error);
      if (onError != null) {
        onError(error);
      }
      if (!_connectedCompleter.isCompleted) {
        _connectedCompleter.completeError(error);
      }
    }, onDone: () {
      if (debug.on) {
        print("[Serial] onDone");
      }
      _eventBus.fire(new _SerialDoneEvent());
      _done = true;
      _connected = false;
      if (onDone != null) {
        onDone();
      }
      if (!_connectedCompleter.isCompleted) {
        _connectedCompleter.completeError("done");
      }

      _stopInfoSubscription();
      _receiveSubscription?.cancel();
      _receiveSubscription = null;
      //_onReceiveController.close();
    });
  }

  _stopInfoSubscription() {
    _infoSubscription?.cancel();
    _infoSubscription = null;
  }

  _startReceiveSubscription() {
    _receiveSubscription =
        // ignore: strong_mode_uses_dynamic_as_bottom
        _eventBus.on(_SerialDataMapEvent).listen((event) {
      Map map = event.data;
      //devPrint("recv data $map");
      Message message = Message.parseMap(map);
      if (message is Notification) {
        if (message.method == methodReceive) {
          int connectionId = message.params['connectionId'];
          var _serialStreamChannel = _serialStreamChannels[connectionId];
          if (_serialStreamChannel != null) {
            var data = message.params['data'];
            if (data is String) {
              _serialStreamChannel._streamController.add(parseHexString(data));
            } else if (data is List) {
              _serialStreamChannel._streamController.add(data);
            } else {
              print('data ${data.runtimeType} not supported');
            }
          } else {
            print('nobody to listen to received data');
          }
        } else if (message.method == methodError) {
          int connectionId = message.params['connectionId'];
          var _serialStreamChannel = _serialStreamChannels[connectionId];
          if (_serialStreamChannel != null) {
            var error = message.params['error'];
            _serialStreamChannel._streamController.addError(error);
          } else {
            print('nobody to listen to error');
          }
        } else if (message.method == methodDisconnected) {
          int connectionId = message.params['connectionId'];
          var _serialStreamChannel = _serialStreamChannels[connectionId];
          if (_serialStreamChannel != null) {
            _serialStreamChannel._close();
            _serialStreamChannels[connectionId] = null;
          } else {
            print('nobody to listen to disconnect');
          }
        }
      }
    });
  }

  // Bind to a websocket channel, either succeed, in which case
  Future<bool> get connected => _connectedCompleter.future;

  sendMessage(Message message) {
    if (debug.on) {
      print("[Serial] send: ${JSON.encode(message.toMap())}");
    }
    String data = JSON.encode(message.toMap());
    if (_onDataSent != null) {
      _onDataSent(data);
    }
    _streamChannel.sink.add(data);
    //if (debug.on) {
    //  print("[Serial] sent: ${message.toMap()}");
    //}
  }

  close() {
    if (!_done) {
      try {
        _streamChannel.sink.close();
      } catch (e) {
        print(e);
      }
    }
  }

  Map<int, Request> connectionIdPendingSendRequests = {};
  Future<Response> _sendRequest(Request request) async {
    if (!_connected) {
      if (request.method != methodInit) {
        throw "client not connected";
      }
    }

    Completer<Response> completer = new Completer();
    StreamSubscription<Map> subscription;

    // Support when serial is done globally...
    StreamSubscription doneSubscription =
        _eventBus.on(_SerialDoneEvent).listen((_) {
      if (!completer.isCompleted) {
        completer.completeError("serial_done");
      }
    });
    subscription =
        // ignore: strong_mode_uses_dynamic_as_bottom
        _eventBus.on(_SerialDataMapEvent).listen((event) {
      if (!completer.isCompleted) {
        Map map = event.data;
        //devPrint("got $map");
        Message message = Message.parseMap(map);

        if (message is Response) {
          if (message.id == request.id) {
            completer.complete(message);
            subscription.cancel();
            subscription = null;
          }
        } else if (message is ErrorResponse) {
          if (message.id == request.id) {
            completer.completeError(message.error);
            subscription.cancel();
            subscription = null;
          }
        }
      }
    });
    try {
      sendMessage(request);
      return await completer.future.timeout(requestTimeoutDuration);
    } finally {
      if (subscription != null) {
        subscription.cancel();
      }
      doneSubscription.cancel();
    }
  }

  Future<bool> _init(SerialClientInfo clientInfo) async {
    // --> {"jsonrpc": "2.0","id": 1,"method": "init"}
    // <-- {"jsonrpc": "2.0","id": 1,"result": true}
    Request request =
        new Request(_nextRequestId, methodInit, clientInfo?.toMap());
    Response response = await _sendRequest(request);

    return response.result;
  }

  Future<List<DeviceInfo>> getDevices() async {
    // --> {"jsonrpc":"2.0","id":2,"method":"getDevices"}
    // <-- {"jsonrpc":"2.0","id":1,"result":[{"path":"/dev/ttyUSB0","vendorId":1027,"productId":24577,"displayName":"FT232R_USB_UART"}]}
    Request request = new Request(_nextRequestId, methodGetDevices);
    Response response = await _sendRequest(request);

    List<DeviceInfo> list = [];
    List<Map> deviceInfoMaps = response.result;
    for (Map deviceInfoMap in deviceInfoMaps) {
      list.add(new DeviceInfo()..fromMap(deviceInfoMap));
    }
    return list;
  }

  Future<SerialStreamChannel> createChannel(String path,
      {ConnectionOptions options}) async {
    ConnectionInfo info = await connect(path, options: options);

    var serialStreamChannel = new SerialStreamChannel._(this, path, info);
    _serialStreamChannels[info.connectionId] = serialStreamChannel;
    return serialStreamChannel;
  }

  Future<ConnectionInfo> connect(String path,
      {ConnectionOptions options}) async {
    // --> {"jsonrpc":"2.0","id":2,"method":"connect","params":{"path":"/dev/ttyUSB0"}}",
    // <-- {"jsonrpc":"2.0","id":20,"result":{"connectionId":7}}
    Map params = {"path": path};
    if (options != null) {
      params["options"] = options.toMap();
    }
    Request request = new Request(_nextRequestId, methodConnect, params);
    Response response = await _sendRequest(request);

    ConnectionInfo info = new ConnectionInfo()..fromMap(response.result);
    if (info.connectionId == null) {
      throw new Exception("connection failed");
    }
    return info;
  }

  Future<bool> disconnect(int connectionId) async {
    // --> {"jsonrpc":"2.0","id":18,"method":"disconnect","params":{"connectionId":6}},
    // <-- {"jsonrpc":"2.0","id":21,"result":true}
    Map params = {"connectionId": connectionId};
    Request request = new Request(_nextRequestId, methodDisconnect, params);
    Response response = await _sendRequest(request);

    // clean channel
    var serialStreamChannel = _serialStreamChannels[connectionId];
    serialStreamChannel._close();
    _serialStreamChannels[connectionId] = null;

    return response.result;
  }

  Future<bool> flush(int connectionId) async {
    // --> {"jsonrpc":"2.0","id":18,"method":"disconnect","params":{"connectionId":6}},
    // <-- {"jsonrpc":"2.0","id":21,"result":true}
    Map params = {"connectionId": connectionId};
    Request request = new Request(_nextRequestId, methodFlush, params);
    Response response = await _sendRequest(request);

    return response.result;
  }

  Future<SendInfo> send(int connectionId, List<int> data) async {
    // send String {"jsonrpc":"2.0","id":5,"method":"send","params":{"connectionId":4,"data":"68656C6C6F2066726F6D20636C69656E74"}}
    // recv String {"jsonrpc":"2.0","id":5,"result":{"bytesSent":17,"error":"pending"}}
    // recv String {"jsonrpc":"2.0","id":5,"result":{"bytesSent":0,"error":"pending"}}
    //Map params = {"connectionId": connectionId, "data": toHexString(data)};
    Request request = new DataSendRequest(_nextRequestId, connectionId, data);
    Response response = await _sendRequest(request);

    SendInfo info = new SendInfo()..fromMap(response.result);

    return info;
  }
}
