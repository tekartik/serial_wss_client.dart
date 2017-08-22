#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/message.dart \
  lib/constant.dart \
  lib/serial_wss_client.dart \
  lib/service/serial_stream_channel_service.dart \
  lib/service/serial_wss_client_service.dart \
  lib/channel/io.dart \
  lib/channel/memory.dart \
  lib/channel/native.dart \
  lib/channel/web_socket_channel.dart \
  lib/channel/client/io.dart \
  lib/channel/client/memory.dart \
  lib/channel/client/browser.dart \
  lib/channel/client/web_socket_channel.dart \
  lib/channel/server/io.dart \
  lib/channel/server/memory.dart \
  lib/channel/server/web_socket_channel_server.dart \

pub run test -p vm,firefox,chrome -j 1