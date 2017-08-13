# Serial Wss Client

[Serial Web Socket Server](https://github.com/tekartik/serial_wss) client for dart

# Usage

Simplest is to use the SerialWssClientService

## Connecting to the Serial Web Socket server

### Console app

    import 'package:tekartik_serial_wss_client/service/io.dart';
    
    SerialWssClientService service = new SerialWssClientService(ioWebSocketChannelFactory);
    service.start();
    
### Browser app

    import 'package:tekartik_serial_wss_client/service/io.dart';
    
    SerialWssClientService service = new SerialWssClientService(browserWebSocketChannelFactory);
    service.start();

## Wait for connection

You can use:

    service.connected.listen((bool connected) {
      if (connected) {
        print("connected");
      } else {
        print("disconnected");
      }
    });
    
## Get the list of serial port

    List<DeviceInfo> deviceInfos = await serial.getDevices();
        
## Connecting a serial port

Simplest is to create a stream channel

    SerialStreamChannel serialStreamChannel = await serial.createChannel(deviceInfo.path);
    
## Sending data

    serialStreamChannel.sink.add("hello\r".codeUnits);
    
## Receiving data
    
    serialStreamChannel.stream.listen((List<int> data) {
       print('received ${data}');
    });
    
## Terminating

### Closing the serial stream

    await serialStreamChannel.close();
    
### Terminating the service
    
    await service.stop();

