#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="PopUpBot"
APP_BUNDLE="$PROJECT_DIR/build/${APP_NAME}.app"
INSTALL_DIR="$HOME/Applications"
EXECUTABLE="$PROJECT_DIR/.build/release/${APP_NAME}"

echo "=== Building ${APP_NAME} ==="
cd "$PROJECT_DIR"
swift build -c release

echo "=== Creating app bundle ==="
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
cp "$PROJECT_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/"

if [ -f "$PROJECT_DIR/Resources/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
fi

cat > "$APP_BUNDLE/Contents/PkgInfo" << 'EOF'
APPL????
EOF

echo "=== Code signing ==="
codesign --force --deep --sign - "$APP_BUNDLE"

echo "=== Installing to ~/Applications/ ==="
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/${APP_NAME}.app"
cp -r "$APP_BUNDLE" "$INSTALL_DIR/"

echo "=== Done ==="
echo "설치 완료: $INSTALL_DIR/${APP_NAME}.app"
echo "실행: open \"$INSTALL_DIR/${APP_NAME}.app\""
