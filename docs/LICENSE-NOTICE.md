# License notice

This repository is a fork of [`aniyomiorg/aniyomi-mpv-lib`](https://github.com/aniyomiorg/aniyomi-mpv-lib)
and is intended for use by Tadami/Aniyomi. It is **not legal advice**; consult counsel
before distributing the AAR or an app that embeds it.

## Repository code

The Java/Kotlin/JNI source in this repository is licensed under the MIT license; see
[`LICENSE`](../LICENSE). Upstream copyright notices are retained.

## Native binaries

The AAR contains `libmpv.so`, `libplayer.so`, `libpostproc.so` and `libxml2.so`. The build
links mpv and FFmpeg into `libmpv.so`; FFmpeg is configured with
`--enable-gpl --enable-version3` (`buildscripts/scripts/ffmpeg.sh`). The resulting
`libmpv.so` is distributed under **GPLv3**, and the AAR as a whole contains GPLv3 binaries.

| Component | License | Notes |
|---|---|---|
| mpv | GPL-2.0-or-later | `libmpv.so`; some parts may be LGPL |
| FFmpeg (`libav*`, `libsw*`, `libpostproc`) | GPL-3.0 (built with `--enable-gpl --enable-version3`) | supplied at runtime by the app's `ffmpeg-kit`; `libpostproc` ships in this AAR |
| libplacebo | LGPL-2.1-or-later | built with Vulkan disabled |
| libass | ISC | |
| dav1d | BSD-2-Clause | |
| mbedtls | Apache-2.0 | |
| freetype | FTL or GPL-2.0 | dual-licensed |
| fribidi | LGPL-2.1-or-later | |
| harfbuzz | MIT | |
| libunibreak | Zlib | |
| lua | MIT | |
| libxml2 | MIT | |

The AAR **does not contain** `libav*.so`, `libsw*.so` or `libc++_shared.so`; these are
provided by the consuming app (`ffmpeg-kit:1.18` / the Android NDK). The app's own
compliance for those libraries is separate from this AAR.

## Source availability

Exact upstream revisions, tags and download URLs are listed in [`SOURCES.md`](../SOURCES.md).
Each GitHub Release also publishes a source tarball of this repository at the release tag.
For GPL compliance, the corresponding source for the GPLv3 binaries must be made available
to recipients; `SOURCES.md` identifies the upstream sources, and the release source tarball
contains the build scripts and patches used for the build.

If you redistribute the AAR, keep the license texts, copyright notices and source
information with it, and satisfy the GPLv3 requirements for the native binaries.
