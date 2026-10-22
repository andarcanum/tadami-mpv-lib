# Tadami mpv library

Fork of [`aniyomiorg/aniyomi-mpv-lib`](https://github.com/aniyomiorg/aniyomi-mpv-lib),
packaged as an Android library (AAR) for Tadami/Aniyomi. The public Java/Kotlin API is
`is.xyz.mpv.*` and stays compatible with the upstream library: no player, UI or API changes
are introduced by this fork.

> **FFmpeg is not bundled.** `libmpv.so` dynamically links against `libavcodec.so`,
> `libavdevice.so`, `libavfilter.so`, `libavformat.so`, `libavutil.so`, `libswresample.so`
> and `libswscale.so`, which are supplied by the consuming app's `ffmpeg-kit`. This
> release is built against **FFmpeg 7.1** (`n7.1`, `Lavc61.19.100`) and requires the app's
> `ffmpeg-kit:1.18`. It will not load with an app that ships a different FFmpeg ABI.

## Versions

| AAR | mpv | FFmpeg | libplacebo | libass | dav1d | mbedtls | NDK |
|---|---|---|---|---|---|---|---|
| `1.19.t` | `v0.41.0` | `n7.1` | `v7.351.0` | `0.17.4` | `1.5.4` | `3.6.7` | `r27c` |

The AAR contains `libmpv.so`, `libplayer.so`, `libpostproc.so` and `libxml2.so` for
`armeabi-v7a`, `arm64-v8a`, `x86` and `x86_64`. FFmpeg and `libc++_shared` are intentionally
excluded: the app provides them.

## Using the library

The artifacts are published as GitHub Release assets. There is no JitPack and no AAR in git.
Gradle resolves the module through a small Ivy repository:

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        // ... your existing repositories
        ivy {
            name = "TadamiMpvLib"
            url = uri("https://github.com/andarcanum/tadami-mpv-lib/releases/download/")
            patternLayout {
                ivy("[revision]/ivy.xml")
                artifact("[revision]/[artifact]-[revision].[ext]")
            }
            metadataSources {
                ivyDescriptor()
            }
            content {
                includeModule("com.github.andarcanum", "tadami-mpv-lib")
            }
        }
    }
}
```

```toml
# gradle/aniyomi.versions.toml
[versions]
aniyomi-mpv-lib = "1.19.t"

[libraries]
aniyomi-mpv = { module = "com.github.andarcanum:tadami-mpv-lib", version.ref = "aniyomi-mpv-lib" }
```

Each release contains:

- `tadami-mpv-lib-<version>.aar`
- `tadami-mpv-lib-<version>.aar.sha256`
- `ivy.xml`
- `tadami-mpv-lib-<version>-sources.tar.gz`

The `ivy.xml` is required so Gradle knows the artifact is an AAR (not a JAR).

## Building from source

See [`docs/BUILD.md`](docs/BUILD.md). The short version, on Linux (or WSL2 on an ext4
filesystem):

```bash
cd buildscripts
./download.sh
./buildall.sh --arch x86 mpv
./buildall.sh --arch x86_64 mpv
./buildall.sh --arch arm64 mpv
./buildall.sh
```

The AAR is written to `app/build/outputs/aar/app-default-release.aar`.

## Releasing

See [`docs/RELEASE.md`](docs/RELEASE.md). Releases are built by
`.github/workflows/build_release.yml` on a `1.19.*` tag, or manually via
`workflow_dispatch` (artifact only, no release).

## Licensing

The native build uses FFmpeg with `--enable-gpl --enable-version3`, so the resulting
`libmpv.so` is distributed under **GPLv3**. See [`docs/LICENSE-NOTICE.md`](docs/LICENSE-NOTICE.md)
and [`SOURCES.md`](SOURCES.md) for component licenses, source locations and the exact
upstream revisions. This is a fork; all upstream copyrights remain with their authors.

## Credits

Built on [mpv](https://github.com/mpv-player/mpv), [FFmpeg](https://github.com/FFmpeg/FFmpeg),
[libplacebo](https://github.com/haasn/libplacebo), [libass](https://github.com/libass/libass),
[dav1d](https://github.com/videolan/dav1d), [mbedtls](https://github.com/Mbed-TLS/mbedtls)
and the upstream [`aniyomi-mpv-lib`](https://github.com/aniyomiorg/aniyomi-mpv-lib) /
[`mpv-android`](https://github.com/mpv-android/mpv-android) projects.
