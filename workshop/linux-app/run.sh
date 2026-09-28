#!/bin/sh
D=$(cd "$(dirname "$0")" && pwd)

# CI build hardcodes its data dir and overrides QGIS_QUICK_DATA_PATH at startup.
# Link that path to the bundled qgis-data (proj, resources) and its projects/ to the workshop folder.
DATA=/home/runner/work/mobile/mobile/build-mm/app/android/assets/qgis-data
BUNDLED="$D/share/input/qgis-data"
PROJECTS="$HOME/workshop_mm_laax/field/projects"
mkdir -p "$PROJECTS"
if [ "$(readlink -f "$BUNDLED/projects" 2>/dev/null)" != "$PROJECTS" ]; then
  rm -rf "$BUNDLED/projects" && ln -s "$PROJECTS" "$BUNDLED/projects"
fi
if [ "$(readlink -f "$DATA" 2>/dev/null)" != "$BUNDLED" ]; then
  if [ -e "$DATA" ] && [ ! -L "$DATA" ]; then
    echo "$DATA exists and is not a symlink, move it away first" >&2; exit 1
  fi
  echo "Linking $DATA -> $BUNDLED (sudo, once)"
  sudo mkdir -p "$(dirname "$DATA")" && sudo rm -f "$DATA" && sudo ln -s "$BUNDLED" "$DATA" || exit 1
fi

export LD_LIBRARY_PATH="$D/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="$D/bin"
export QML_IMPORT_PATH="$D/qml"
export QML2_IMPORT_PATH="$D/qml"
export PROJ_DATA="$BUNDLED/proj"
# bundled PipeWire looks for its plugins at a vcpkg build path; the camera init aborts without these
export SPA_PLUGIN_DIR="$D/lib64/spa-0.2"
export PIPEWIRE_MODULE_DIR="$D/lib64/pipewire-0.3"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"
exec "$D/bin/MerginMaps" "$@"
