#!/bin/bash
# Rebuild IchthysFiles from the Fossify forks in ~/git/ichthys-files and copy the APK here.
#   Commons      ~/git/ichthys-files/Commons       (branch ichthys, published as 6.1.6-ichthys)
#   File-Manager ~/git/ichthys-files/File-Manager  (branch ichthys, APP_ID org.ichthys.files)
# The APK is built unsigned; the AOSP build signs it with the platform key (Android.bp).
set -euo pipefail
SRC="${ICHTHYS_FILES_SRC:-$HOME/git/ichthys-files}"
export JAVA_HOME="${JAVA_HOME:-$(cd "$(dirname "$0")/../../.." && pwd)/prebuilts/jdk/jdk21/linux-x86}"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export VERSION=6.1.6-ichthys
GRADLE_ARGS=(--no-daemon --max-workers="${GRADLE_WORKERS:-4}" -q)

(cd "$SRC/Commons" && ./gradlew "${GRADLE_ARGS[@]}" :commons:publishReleasePublicationToMavenLocal)
(cd "$SRC/File-Manager" && ./gradlew "${GRADLE_ARGS[@]}" assembleFossRelease)
cp "$SRC/File-Manager/app/build/outputs/apk/foss/release/"*-foss-release-unsigned.apk \
    "$(dirname "$0")/IchthysFiles.apk"
echo "IchthysFiles.apk from File-Manager $(git -C "$SRC/File-Manager" rev-parse --short HEAD)," \
    "Commons $(git -C "$SRC/Commons" rev-parse --short HEAD)"
