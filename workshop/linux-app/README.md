# Mergin Maps app on Linux

Mergin Maps publishes the app for Android, iOS and Windows only, but its CI builds a Linux x86_64 version on every commit and keeps it as a workflow artifact. It runs fine on Ubuntu 24.04 and newer.

## Trainer: fetch the build (needs a GitHub login)

1. Open https://github.com/MerginMaps/mobile/actions/workflows/linux.yml
2. Click the latest successful run on `master`.
3. Under Artifacts, download `Mergin Maps <build> x86_64` (about 320 MB, a zip holding a `input-<build>-<date>-<run>.tar.gz`).
4. Put the zip on the USB stick next to `run.sh` from this folder.

Artifacts expire after 90 days, fetch a fresh one before each session.

## Participant: install and run

```sh
mkdir -p ~/workshop_mm_laax/merginmaps && cd ~/workshop_mm_laax/merginmaps
unzip ~/Downloads/Mergin\ Maps\ *\ x86_64.zip
tar -xzf input-*.tar.gz && rm input-*.tar.gz
cp /path/to/stick/run.sh . && chmod +x run.sh
./run.sh
```

A phone-shaped window opens. Profile icon top right, Log in, tap the server address at the bottom, enter `http://localhost:8080`, Confirm, log in as `field`.

## What run.sh does

The tarball is a plain install tree, not an AppImage, so a few environment variables are needed:

| Variable | Why |
|---|---|
| `LD_LIBRARY_PATH=lib64` | bundled Qt 6 and GDAL libraries |
| `QT_PLUGIN_PATH=bin`, `QML_IMPORT_PATH=qml` | Qt plugins and QML modules live next to the binary |
| `PROJ_DATA=share/input/qgis-data/proj` | otherwise `Cannot find proj.db` |
| `QT_QPA_PLATFORM=xcb` | the build has no Wayland plugin |
| `QT_QUICK_BACKEND=software` | the xcb plugin was built without GLX or EGL, so Qt Quick must render in software |

## Preset the server without the GUI

Settings live in a QGIS-style profile, not in `~/.config`:

```
~/.local/share/Lutra Consulting/Input/profiles/default/Lutra Consulting/Input.ini
```

After a first start, edit `apiRoot` and `mergin_url` to `http://localhost:8080`, restart the app. Useful when preparing a fleet of laptops.
