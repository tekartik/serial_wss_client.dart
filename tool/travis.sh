#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings \
  lib/message.dart \
  lib/constant.dart \
  lib/serial_wss_client.dart \
  lib/service/browser.dart \
  lib/service/io.dart \
  lib/service/serial_wss_client_service.dart \

pub run test -p vm,firefox,chrome