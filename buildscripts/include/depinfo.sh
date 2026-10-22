#!/bin/bash -e

## Dependency versions
# Make sure to keep v_ndk and v_ndk_n in sync, both are listed on the NDK download page

v_sdk=11076708_latest
v_ndk=r27c
v_ndk_n=27.2.12479018
v_sdk_platform=34
v_sdk_build_tools=34.0.0

v_lua=5.2.4
v_unibreak=6.1
v_harfbuzz=10.1.0
v_fribidi=1.0.16
v_freetype=2-13-3
v_mbedtls=3.6.7
v_libxml2=2.13.5

# mpv v0.41.0 (tag object 2c219aa8; commit below)
v_mpv=41f6a645068483470267271e1d09966ca3b9f413

# FFmpeg n7.1.4 — must match ffmpeg-kit 1.18 in the app (Lavc61.19.100)
v_ffmpeg=n7.1.4

# newly pinned (were master)
v_libplacebo=v7.351.0
v_libass=0.17.4
v_dav1d=1.5.4


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mbedtls=()
dep_libxml2=()
dep_dav1d=()
dep_ffmpeg=(mbedtls dav1d libxml2)
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_unibreak=()
dep_libass=(freetype2 fribidi harfbuzz unibreak)
dep_lua=()
dep_libplacebo=()
dep_mpv=(ffmpeg libass lua libplacebo)
dep_mpv_android=(mpv)


## for CI workflow

# pinned ffmpeg revision
v_ci_ffmpeg=n7.1.4

# filename used to uniquely identify a build prefix
ci_tarball="prefix-ndk-${v_ndk}-mpv-${v_mpv}-ffmpeg-${v_ci_ffmpeg}-lp-${v_libplacebo}-ass-${v_libass}-dav1d-${v_dav1d}-lua-${v_lua}-unibreak-${v_unibreak}-harfbuzz-${v_harfbuzz}-fribidi-${v_fribidi}-freetype-${v_freetype}-mbedtls-${v_mbedtls}-xml2-${v_libxml2}.tgz"
