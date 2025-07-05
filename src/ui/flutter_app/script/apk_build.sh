
#!/bin/bash

# 跳转到项目根目录
cd "$(dirname "$0")/../" || exit

# 从 pubspec.yaml 读取版本号
VERSION_LINE=$(grep '^version:' pubspec.yaml | head -1)
VERSION_NAME=$(echo "$VERSION_LINE" | awk '{print $2}' | cut -d'+' -f1)
VERSION_CODE=$(echo "$VERSION_LINE" | awk '{print $2}' | cut -d'+' -f2)

flutter build apk --release --obfuscate --split-debug-info=build/debug-info

APK_DIR="build/app/outputs/flutter-apk"
OLD_NAME="app-release.apk"
NEW_NAME="ThreeLine_V${VERSION_NAME}_${VERSION_CODE}pre.apk"

mv "${APK_DIR}/${OLD_NAME}" "${APK_DIR}/${NEW_NAME}"

echo "✅ APK renamed to: ${APK_DIR}/${NEW_NAME}"

# 打开输出目录
open ./build/app/outputs/flutter-apk/
