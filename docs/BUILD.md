# Building

This document describes how to build the AAR locally. The release build is produced by
`.github/workflows/build_release.yml` on `ubuntu-24.04`; CI is the source of truth for
released artifacts.

## Supported environment

- **Linux x86_64** (Ubuntu 24.04 is what CI uses) — supported.
- **WSL2 on an ext4 filesystem** (`~/src/...`) — best effort. Upstream does not officially
  support WSL; building on `/mnt/c` usually breaks due to symlinks, permissions and file
  locking, so keep the checkout and `buildscripts/deps` inside the Linux filesystem.
- **Docker / Linux container** — supported alternative if the host lacks `sudo` or the
  required packages.
- **Windows native** — not supported by the build scripts.

Requirements:

- JDK 17 (`javac` must be on `PATH`);
- `bash`, `git`, `wget`, `unzip`, `pkg-config`, `make`;
- `meson >= 1.3`, `ninja`, `nasm` (x86 assembler), plus `autoconf`/`libtool` for some
  dependencies;
- the Android SDK/NDK are downloaded by `download.sh` (NDK `r27c`, SDK platform 34);
- at least ~10–15 GB of free disk space for sources and four ABI prefixes.

## Bootstrap

```bash
cd buildscripts
./download.sh
```

`download.sh` installs the Android SDK/NDK and clones the pinned sources. On
Debian/Ubuntu it also tries `sudo apt-get install` for host packages. If `sudo` is not
available, install the packages manually (or use a container) and run:

```bash
IN_CI=1 ./download.sh   # skip the apt step; SDK/NDK and sources are still downloaded
```

## Build

Build `libmpv.so` for each ABI first, then build the AAR (this also builds the armv7l
`libmpv.so` and runs `ndk-build` + Gradle):

```bash
./buildall.sh --arch x86 mpv
./buildall.sh --arch x86_64 mpv
./buildall.sh --arch arm64 mpv
./buildall.sh
```

The result is:

```
app/build/outputs/aar/app-default-release.aar
```

`./buildall.sh` uses the `mpv-android` target: it runs `ndk-build` and Gradle
`assembleDebug assembleRelease` (and `bundleRelease` only if `ANDROID_SIGNING_KEY` is set).
The AAR contains `libmpv.so`, `libplayer.so`, `libpostproc.so` and `libxml2.so` for every
ABI that was built. FFmpeg `libav*.so`/`libsw*.so` and `libc++_shared.so` are excluded by
`app/build.gradle`; the consuming app supplies them through `ffmpeg-kit`.

### Clean builds

```bash
./buildall.sh --clean
rm -rf prefix          # also drop shared dependency prefixes
rm -rf deps            # force re-download of sources
```

To rebuild a single component without its dependencies:

```bash
./buildall.sh -n ffmpeg
```

## Verify the native output

`libmpv.so` must be loaded against the **FFmpeg 7.1** (`n7.1`) libraries shipped by the app's
`ffmpeg-kit:1.18` (`Lavc61.19.100`). The AAR does not contain FFmpeg.

```bash
# DT_NEEDED / SONAME
readelf -d app/src/main/jniLibs/arm64-v8a/libmpv.so | grep -E 'NEEDED|SONAME'

# 16 KB page size (all LOAD segments should be 0x4000-aligned)
readelf -l app/src/main/jniLibs/arm64-v8a/libmpv.so | grep LOAD

# Versions embedded in the binary
strings app/src/main/jniLibs/arm64-v8a/libmpv.so | grep -E '0\.41\.0|n7\.1|7\.351\.0'
```

`DT_NEEDED` must list the FFmpeg names **without** a version suffix (`libavcodec.so`, not
`libavcodec.so.61`), plus `libc++_shared.so`.

### FFmpeg symbol check against `ffmpeg-kit`

Extract the app's FFmpeg libs from a universal APK and compare the undefined FFmpeg symbols
in `libmpv.so` with the symbols defined by `libav*.so` + `libsw*.so`:

```bash
unzip -o app-universal-debug.apk \
  'lib/arm64-v8a/libav*.so' 'lib/arm64-v8a/libsw*.so' -d /tmp/appff

NM=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-nm

"$NM" -D --undefined-only app/src/main/jniLibs/arm64-v8a/libmpv.so \
  | awk '{print $2}' | grep -E '^(av|sws|swr)' | sort -u > /tmp/mpv_undef.txt

for f in /tmp/appff/lib/arm64-v8a/libav*.so /tmp/appff/lib/arm64-v8a/libsw*.so; do
  "$NM" -D --defined-only "$f" | awk '{print $3}'
done | grep -E '^(av|sws|swr)' | sort -u > /tmp/ff_defined.txt

comm -23 /tmp/mpv_undef.txt /tmp/ff_defined.txt
```

The `comm` output must be empty. A non-empty result means the app's FFmpeg build is missing
a symbol used by this `libmpv.so`; do not tag a release.

### FFmpeg version gate (hard requirement)

mpv checks the FFmpeg library versions during `mpv_initialize()` and calls `exit(1)` if
`libmpv.so` was built against a newer FFmpeg than the one loaded at runtime. This code path
uses a null logger, so the process dies without an error line in logcat.

Build against the same FFmpeg release as the app's `ffmpeg-kit:1.18` — `n7.1`
(`Lavc61.19.100`). Do not bump to `n7.1.x`: patch releases bump `LIBAVCODEC_VERSION_MICRO`
(e.g. `n7.1.4` is `Lavc61.19.101`, `libavfilter` 10.5.100, `libavformat` 61.7.102) and will
abort at `MPVLib.init()` even though the ABI is otherwise compatible.

## Troubleshooting

- **`sudo: a password is required`** — either install the packages manually, run in a
  container, or use CI; `IN_CI=1 ./download.sh` skips the apt step.
- **`meson: command not found`** — `python3 -m pip install --user meson ninja`, then add
  `~/.local/bin` to `PATH` (or install `meson`/`ninja-build` via apt).
- **WSL build fails on `/mnt/c`** — move the checkout to `~/src` and rebuild there.
- **OOM during FFmpeg/LLVM** — limit parallelism: `cores=4 ./buildall.sh ...` or
  `MAKEFLAGS=-j4`.
- **Stale objects after changing a pin** — `rm -rf prefix` and rerun with `--clean`.
- **`git apply` fails on `ffmpeg_force_mpegts.patch`** — the patch context changed; rebase
  it against the pinned `n7.1` tree without changing its semantics.

## CI

The workflow builds four ABIs, copies the AAR, generates `ivy.xml`, writes a `.sha256`
file and a source tarball, and (on a tag) creates a GitHub Release. A manual
`workflow_dispatch` run builds the same artifacts with `VERSION=0.0.0-dev` and uploads them
as a workflow artifact only. See [`RELEASE.md`](RELEASE.md).
