# ==============================================================================
# Dockerfile: Data Artifex Full QSV Distribution Image
# ==============================================================================
# Builds a comprehensive, static musl release of the QSV data-wrangling toolkit
# with full feature support across both linux/amd64 and linux/arm64:
#   - Polars SQL and vector engine (sqlp, joinp, pivotp, scoresql)
#   - Luau embedded scripting engine (luau)
#   - Format conversions (to: Parquet/XLSX/ODS/SQLite, readstat/writestat: SAS/SPSS/Stata)
#   - Geocoding and spatial conversions (geocode, geoconvert)
#   - Profiling, synthesis, and all streaming operations (78 commands)
#
# Published as: dartfx/qsv:<tag>
# Consumed by:
#   - dartfx/base (COPY --from=dartfx/qsv /usr/local/bin/qsv /usr/local/bin/qsv)
#   - dartfx/n8n         (COPY --from=dartfx/qsv /usr/local/bin/qsv /usr/local/bin/qsv)
#   - Standalone CLI container (docker run --rm -it dartfx/qsv --help)
# ==============================================================================

ARG QSV_VERSION="27.0.1"

# --- Stage 1: Build full multi-arch QSV from source ---
FROM rust:alpine AS builder

ARG QSV_VERSION
ENV QSV_VERSION=${QSV_VERSION}

# Install compilation toolchains and build dependencies
RUN apk add --no-cache \
    musl-dev \
    gcc \
    g++ \
    make \
    cmake \
    git \
    clang-dev \
    llvm-dev \
    pkgconf \
    zlib-dev \
    zstd-dev \
    libstdc++

WORKDIR /build

# Clone exact release tag from GitHub
RUN git clone --depth 1 --branch "${QSV_VERSION#v}" https://github.com/dathere/qsv.git /build/qsv

WORKDIR /build/qsv

# Disable LTO to avoid massive 2,000+ unit thin-LTO cross-crate expansion on Polars
# Link with -lgcc so that aarch64 musl resolves __clear_cache from Luau JIT CodeAllocator
ENV RUSTFLAGS="-C link-arg=-lgcc" \
    CARGO_PROFILE_RELEASE_LTO="off" \
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS="16" \
    CARGO_PROFILE_RELEASE_LUAU_LTO="off" \
    CARGO_PROFILE_RELEASE_LUAU_CODEGEN_UNITS="16"

# Compile full-featured QSV using release-luau profile with BuildKit cache mounts
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/build/qsv/target \
    cargo build --profile release-luau --locked --bin qsv \
    --no-default-features \
    --features feature_capable,apply,fetch,foreach,geocode,get,luau,mcp,polars,profile,readstat,synthesize,to,viz \
    && install -m 0755 target/release-luau/qsv /usr/local/bin/qsv \
    && /usr/local/bin/qsv --version

# --- Stage 2: Minimal Published Image ---
FROM alpine:3.21

LABEL maintainer="Data Artifex <support@dartfx.com>"
LABEL description="Full-featured, multi-architecture distribution of the QSV tabular data-wrangling toolkit"

RUN apk add --no-cache ca-certificates libstdc++ tzdata

COPY --from=builder /usr/local/bin/qsv /usr/local/bin/qsv
COPY --from=builder /build/qsv/LICENSE-MIT /usr/share/licenses/qsv/LICENSE-MIT
COPY --from=builder /build/qsv/README.md /usr/share/doc/qsv/README.md

# Verify execution on target platform
RUN /usr/local/bin/qsv --version

WORKDIR /data

ENTRYPOINT ["/usr/local/bin/qsv"]
CMD ["--help"]
