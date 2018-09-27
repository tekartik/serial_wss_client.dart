#!/bin/bash

# Fast fail the script on failures.
set -e

dartanalyzer --fatal-warnings .

pub run test -p vm,firefox,chrome -j 1

# test build support support
pub run build_runner build example_web