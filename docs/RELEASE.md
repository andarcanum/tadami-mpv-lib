# Release process

The AAR is released from this repository as a GitHub Release. There is no JitPack and no
binary committed to git. The app consumes the release through an Ivy repository (see the
root [`README.md`](../README.md)).

## Version scheme

- Version/tag: `1.19.t` (continues the upstream `1.18.n` scheme; the `t` suffix marks the
  Tadami fork).
- Release candidate: `1.19.t-rc1`. The workflow publishes `-rc*` tags as **prereleases**.
- A version bump changes `app/build.gradle` (`versionCode`, `versionName`) and
  `gradle/aniyomi.versions.toml` in the consuming app.
- Never move or rewrite a published tag. A bad release is superseded by a new version
  (for example `1.19.t.1`), not by deleting the old tag.

## Preconditions

1. `buildscripts/include/depinfo.sh` pins every native dependency (mpv commit, FFmpeg tag,
   libplacebo/libass/dav1d tags, mbedtls version). No `git clone` of a floating branch.
2. `app/build.gradle` has the intended `versionCode` and `versionName`.
3. `docs/RELEASE_NOTES.md` describes the release (it becomes the release body).
4. `SOURCES.md` and `docs/LICENSE-NOTICE.md` are up to date with the pinned sources.
5. Native verification from [`BUILD.md`](BUILD.md) passes, including the FFmpeg symbol
   check against `ffmpeg-kit:1.18`.
6. The consuming app builds and the QA matrix passes on a physical arm64 device and an
   x86_64 emulator (see the app repository's plan).
7. Commit, push, tag and release are explicitly approved by the maintainer in the current
   session.

## Dry run (no release)

Use `workflow_dispatch` on the release workflow:

```text
Actions → Release → Run workflow → branch: feature/mpv-0.41.0
```

- Builds the same four ABI AAR and packages `ivy.xml`, `.sha256` and the source tarball.
- `VERSION=0.0.0-dev`; no GitHub Release is created.
- The packaged assets are uploaded as a workflow artifact for inspection.

This is the recommended first run before creating any tag.

## Release candidate / final release

```bash
git switch feature/mpv-0.41.0
git pull --ff-only
git tag -a 1.19.t-rc1 -m "tadami-mpv-lib 1.19.t-rc1"
git push origin 1.19.t-rc1
```

The tag push starts `.github/workflows/build_release.yml`. After the rc passes QA:

```bash
git tag -a 1.19.t -m "tadami-mpv-lib 1.19.t"
git push origin 1.19.t
```

The workflow:

1. Checks out the tag, sets up JDK 17.
2. Restores the SDK/deps/prefix cache (keyed by `depinfo.sh`, build scripts, patches and the
   workflow file).
3. Builds `x86`, `x86_64`, `arm64` `libmpv` targets, then the default `armv7l` + AAR build.
4. Copies `app/build/outputs/aar/app-default-release.aar` to
   `out/tadami-mpv-lib-<version>.aar`.
5. Generates `out/ivy.xml` with the version and the `default` configuration.
6. Writes `out/tadami-mpv-lib-<version>.aar.sha256`.
7. Creates `out/tadami-mpv-lib-<version>-sources.tar.gz` from the tagged tree plus
   `SOURCES.md` (no build outputs).
8. Creates a GitHub Release with those four assets and `docs/RELEASE_NOTES.md` as the body.
   Tags containing `-rc` are marked as prereleases.

## Release assets

```text
tadami-mpv-lib-1.19.t.aar
tadami-mpv-lib-1.19.t.aar.sha256
ivy.xml
tadami-mpv-lib-1.19.t-sources.tar.gz
```

`ivy.xml` must contain the `default` configuration and declare the AAR with
`conf="default"`; otherwise Gradle may look for a JAR.

## Post-release verification

```bash
curl -fL https://github.com/andarcanum/tadami-mpv-lib/releases/download/1.19.t/ivy.xml
curl -fL -o /tmp/tadami.aar \
  https://github.com/andarcanum/tadami-mpv-lib/releases/download/1.19.t/tadami-mpv-lib-1.19.t.aar
sha256sum /tmp/tadami.aar
unzip -l /tmp/tadami.aar | grep 'jni/'
```

Check:

- all four ABIs are present;
- the AAR contains only `libmpv.so`, `libplayer.so`, `libpostproc.so`, `libxml2.so` per ABI
  (no `libav*.so`, no `libsw*.so`, no `libc++_shared.so`);
- the `.sha256` matches the downloaded AAR;
- the app resolves `com.github.andarcanum:tadami-mpv-lib:1.19.t` from the Ivy repository and
  still builds.

## Rollback

- **Before a release is consumed:** delete the draft/prerelease in GitHub if it was created
  by mistake; do not reuse the tag.
- **After the app adopted the release:** revert the app's version catalog and Ivy
  repository change to the previous `1.18.n` dependency in one commit. The old JitPack
  coordinate remains available.
- **Broken native ABI:** publish a fixed patch version and update the app; do not rewrite
  the broken tag.
- Keep the previous AAR and its `.sha256` for at least one release cycle.

## Manual release (fallback)

If CI is unavailable, build the AAR from the exact tag using [`BUILD.md`](BUILD.md),
generate `ivy.xml`/`.sha256`/source tarball with the same names, and create the GitHub
Release manually. The source tarball must be built from the tagged tree, not from a dirty
working copy. Document the reason in the release notes.
