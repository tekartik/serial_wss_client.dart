#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings .

pub run test -p vm,firefox,chrome -j 1

# test dartdevc support
pub build example/menu_web --web-compiler=dartdevc