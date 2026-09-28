#!/bin/sh
D=$(cd "$(dirname "$0")" && pwd)
export LD_LIBRARY_PATH="$D/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="$D/bin"
export QML_IMPORT_PATH="$D/qml"
export QML2_IMPORT_PATH="$D/qml"
export PROJ_DATA="$D/share/input/qgis-data/proj"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"
exec "$D/bin/MerginMaps" "$@"
