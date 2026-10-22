# Tadami mpv library 1.19.t

Native dependency refresh for the `is.xyz.mpv` AAR. **No public API changes**; the player
code and UI in the consuming app are unchanged.

## Native updates

| Component | Version |
|---|---|
| mpv | `v0.41.0` |
| FFmpeg | `n7.1.4` |
| libplacebo | `v7.351.0` |
| libass | `0.17.4` |
| dav1d | `1.5.4` |
| mbedtls | `3.6.7` |
| NDK | `r27c` (`27.2.12479018`) |

## Compatibility

- The AAR does **not** bundle FFmpeg. It requires the app's `ffmpeg-kit:1.18`
  (FFmpeg 7.1.4, `Lavc61.19.100`) to provide `libav*.so`/`libsw*.so`.
- FFmpeg 8 is not used and is not compatible without rebuilding `ffmpeg-kit`.
- Supported ABIs: `armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64`.
- 16 KB page size compatible (`-Wl,-z,max-page-size=16384`, flexible page sizes).
- Built without Vulkan, as before.

## Artifacts

- `tadami-mpv-lib-1.19.t.aar`
- `tadami-mpv-lib-1.19.t.aar.sha256`
- `ivy.xml`
- `tadami-mpv-lib-1.19.t-sources.tar.gz`

Verify the AAR with the accompanying `.sha256` file. The source tarball contains the tagged
tree and `SOURCES.md` with exact upstream revisions and URLs.

## Licensing

The native build uses FFmpeg with `--enable-gpl --enable-version3`; `libmpv.so` is
distributed under **GPLv3**. See `docs/LICENSE-NOTICE.md` and `SOURCES.md` in the source
tarball. This release is a fork of `aniyomiorg/aniyomi-mpv-lib`; upstream copyrights remain
with their authors.
