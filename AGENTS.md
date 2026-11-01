# AGENTS INSTRUCTIONS

This project builds the official Data Artifex multi-architecture Docker image for `qsv` (`dartfx/qsv`).

## Core Purpose

`dartfx/qsv` provides a 100% full-featured, statically linked release of the [QSV data-wrangling toolkit](https://github.com/dathere/qsv) across both `linux/amd64` and `linux/arm64`.

It guarantees that all 78 non-GUI commands—including Polars SQL (`sqlp`, `joinp`, `pivotp`), embedded Luau scripting (`luau`), format conversions (`to`, `readstat`, `writestat`), geocoding (`geocode`), data profiling (`profile`), and visualization (`viz`)—are available.

## Downstream Consumers

1. **`dartfx/docker-base`**:
   Copies `/usr/local/bin/qsv` from `dartfx/qsv:<tag>`.
2. **`dartfx/n8n`**:
   Copies `/usr/local/bin/qsv` from `dartfx/qsv:<tag>` into `/usr/local/bin/qsv`.
3. **Standalone CLI**:
   Users can run `docker run --rm -v $(pwd):/data dartfx/qsv <command>`.

## Multi-Platform Support

All builds must target both `linux/amd64` and `linux/arm64` via Docker Buildx.
Verification is performed via `./verify_image.sh` and publishing via `./publish_image.sh`.
