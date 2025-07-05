#!/bin/bash

# 获取当前脚本的路径
SCRIPT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 获取 Scripts 目录路径
SCRIPTS_DIR=$(dirname "$SCRIPT_PATH")

# 获取项目根路径
WORKSPACE=$SCRIPTS_DIR
cd ${WORKSPACE}
flutter build ipa  --export-method ad-hoc --obfuscate --split-debug-info=build/ios_debug_info
#flutter build ios --release --obfuscate --split-debug-info=build/ios_debug_info
