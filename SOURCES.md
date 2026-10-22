# Source code

This file lists the exact upstream sources used by the `1.19.t` release. Commit URLs are
immutable; tag URLs are listed for convenience. The release source tarball contains this
repository at the release tag plus this file and the build patches.

## This repository

- Repository: <https://github.com/andarcanum/tadami-mpv-lib>
- Release tag: `1.19.t`
- Source tarball asset: `tadami-mpv-lib-1.19.t-sources.tar.gz`
- Build scripts: `buildscripts/`
- FFmpeg patch: `buildscripts/patches/ffmpeg_force_mpegts.patch`
- JNI/Java/Kotlin code: `app/src/main/`

## Native dependencies

| Component | Version | Source |
|---|---|---|
| mpv | `v0.41.0` / `41f6a645068483470267271e1d09966ca3b9f413` | <https://github.com/mpv-player/mpv/archive/41f6a645068483470267271e1d09966ca3b9f413.tar.gz> |
| FFmpeg | `n7.1.4` / `9abe92e3af7fa7becc8f7f742b1457b4c28220a6` | <https://github.com/FFmpeg/FFmpeg/archive/9abe92e3af7fa7becc8f7f742b1457b4c28220a6.tar.gz> |
| libplacebo | `v7.351.0` / `3188549fba13bbdf3a5a98de2a38c2e71f04e21e` | <https://github.com/haasn/libplacebo/archive/3188549fba13bbdf3a5a98de2a38c2e71f04e21e.tar.gz> |
| libass | `0.17.4` / `bbb3c7f1570a4a021e52683f3fbdf74fe492ae84` | <https://github.com/libass/libass/releases/download/0.17.4/libass-0.17.4.tar.xz> |
| dav1d | `1.5.4` / `54706fc6bc0cdecab7e9593974a4039cc038fca7` | <https://github.com/videolan/dav1d/archive/54706fc6bc0cdecab7e9593974a4039cc038fca7.tar.gz> |
| mbedtls | `3.6.7` | <https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-3.6.7/mbedtls-3.6.7.tar.bz2> |
| freetype | `2-13-3` / tag `VER-2-13-3` | <https://gitlab.freedesktop.org/freetype/freetype/-/tree/VER-2-13-3> |
| fribidi | `1.0.16` | <https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz> |
| harfbuzz | `10.1.0` | <https://github.com/harfbuzz/harfbuzz/releases/download/10.1.0/harfbuzz-10.1.0.tar.xz> |
| libunibreak | `6.1` | <https://github.com/adah1972/libunibreak/releases/download/libunibreak_6_1/libunibreak-6.1.tar.gz> |
| lua | `5.2.4` | <https://www.lua.org/ftp/lua-5.2.4.tar.gz> |
| libxml2 | `2.13.5` | <https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.13.5/libxml2-v2.13.5.tar.gz> |

`libplacebo` and `freetype` are built with git submodules. To reproduce their exact trees:

```bash
git clone --recursive https://github.com/haasn/libplacebo.git
git -C libplacebo checkout 3188549fba13bbdf3a5a98de2a38c2e71f04e21e
git -C libplacebo submodule update --init --recursive

git clone --recurse-submodules https://gitlab.freedesktop.org/freetype/freetype.git
git -C freetype checkout VER-2-13-3
git -C freetype submodule update --init --recursive
```

## Toolchain

- Android NDK: `r27c` / `27.2.12479018` — <https://dl.google.com/android/repository/android-ndk-r27c-linux.zip>
- Android SDK command-line tools: `11076708_latest` — <https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip>
- SDK platform: `34`; build-tools: `34.0.0`
- JDK: 17 (Temurin in CI)

`buildscripts/include/download-sdk.sh` downloads the SDK/NDK; `download-deps.sh` downloads
the sources. `gas-preprocessor.pl` is fetched from
<https://github.com/FFmpeg/gas-preprocessor> (upstream script fetches `master`; it is a
build-time helper, not linked into the AAR).

## FFmpeg at runtime

The AAR does **not** ship FFmpeg. `libmpv.so` is dynamically linked against the
`libav*.so`/`libsw*.so` provided by the consuming app's `ffmpeg-kit:1.18` (FFmpeg 7.1.4,
`Lavc61.19.100`). The source for those binaries is distributed by the app's
`ffmpeg-kit` project, not by this AAR; see that project's source and license notices.

## Release source tarball

The CI creates the source tarball from the tagged tree:

```bash
git archive --format=tar.gz \
  --prefix=tadami-mpv-lib-1.19.t/ \
  -o tadami-mpv-lib-1.19.t-sources.tar.gz \
  1.19.t
```

It contains the build scripts, patches and `SOURCES.md`, but not the downloaded
`buildscripts/deps/`, `buildscripts/prefix/` or build outputs. Use the URLs above to fetch
the exact upstream sources.
