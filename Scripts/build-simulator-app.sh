#!/usr/bin/env bash
#
# Builds a Bitwarden iOS app for the iOS Simulator and packages it as a zip that can be
# shared and installed without any Apple signing credentials. Optionally installs and
# launches the app on a local simulator.
#
# Usage:
#
#   $ ./Scripts/build-simulator-app.sh [--app Bitwarden|Authenticator] [--destination <destination>]
#                                      [--install] [--device <simulator name or ID>]
#
# Examples:
#   $ ./Scripts/build-simulator-app.sh
#   $ ./Scripts/build-simulator-app.sh --app Authenticator
#   $ ./Scripts/build-simulator-app.sh --install --device "iPhone 17 Pro"
#
# Output:
#   build/<App>-Simulator.zip containing <App>.app, which can be installed on any booted
#   simulator with `xcrun simctl install booted <App>.app`.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
repo_root=$(dirname "$script_dir")
cd "$repo_root"

APP="Bitwarden"
DESTINATION="generic/platform=iOS Simulator"
INSTALL=false
DEVICE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --app) APP="$2"; shift 2 ;;
    --destination) DESTINATION="$2"; shift 2 ;;
    --install) INSTALL=true; shift ;;
    --device) DEVICE="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo >&2 "Unknown argument: $1"; exit 1 ;;
  esac
done

case "$APP" in
  "Bitwarden") PROJECT_FILE="project-pm.yml" ;;
  "Authenticator") PROJECT_FILE="project-bwa.yml" ;;
  *) echo >&2 "Invalid app: $APP (must be Bitwarden or Authenticator)"; exit 1 ;;
esac

BUILD_DIR="build"
DERIVED_DATA_PATH="${BUILD_DIR}/DerivedData"
APP_PATH="${DERIVED_DATA_PATH}/Build/Products/Debug-iphonesimulator/${APP}.app"
ZIP_PATH="${BUILD_DIR}/${APP}-Simulator.zip"

echo "🌱 Generating Xcode projects"
mint run xcodegen --spec "project-bwk.yml"
mint run xcodegen --spec "${PROJECT_FILE}"

echo "🔨 Building ${APP} for ${DESTINATION}"
mkdir -p "${BUILD_DIR}"
xcrun xcodebuild \
  -workspace Bitwarden.xcworkspace \
  -scheme "${APP}" \
  -configuration Debug \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  -quiet

echo "📦 Packaging ${APP_PATH} into ${ZIP_PATH}"
rm -f "${ZIP_PATH}"
ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

if [ "$INSTALL" = true ]; then
  bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${APP_PATH}/Info.plist")
  target="${DEVICE:-booted}"
  if [ -n "$DEVICE" ]; then
    xcrun simctl boot "$DEVICE" 2> /dev/null || true
  fi
  echo "📲 Installing ${bundle_id} on simulator ${target}"
  xcrun simctl install "$target" "${APP_PATH}"
  xcrun simctl launch "$target" "$bundle_id"
fi

echo "🎉 ${APP} simulator app ready at ${ZIP_PATH}"
