# Data Artifex QSV Docker Image (`dartfx/qsv`)

A high-performance, multi-architecture (`linux/amd64` and `linux/arm64`) Docker distribution of the [QSV tabular data-wrangling toolkit](https://github.com/dathere/qsv) bundling the **full feature set**.

---

## Why this image exists

Official prebuilt binaries for Linux distributed on GitHub omit major computational commands on ARM64 and Musl targets (Polars SQL engine, Luau embedded scripting, format conversions, geocoding, etc.).

`dartfx/qsv` compiles QSV from source with static linking, providing all 78 non-GUI commands across both `amd64` and `arm64`:

| Category | Commands Included |
| :--- | :--- |
| **Polars Engine** | `sqlp`, `joinp`, `pivotp`, `scoresql` |
| **Embedded Scripting** | `luau` |
| **Format Conversions** | `to` (Parquet, XLSX, SQLite, ODS), `readstat`, `writestat` (SAS, SPSS, Stata) |
| **Geocoding & Spatial** | `geocode`, `geoconvert` |
| **Data Profiling & Viz**| `profile`, `viz`, `synthesize`, `sniff` |
| **Streaming Operations** | `count`, `dedup`, `search`, `slice`, `sort`, `validate`, `stats`, and 60+ more |

---

## Usage

### 1. Standalone CLI Tool
Run any `qsv` command against your local data by mounting your current working directory:

```bash
docker run --rm -v $(pwd):/data dartfx/qsv count my_data.csv
docker run --rm -v $(pwd):/data dartfx/qsv sqlp my_data.csv "SELECT * FROM _t_1 WHERE score > 80"
```

### 2. Multi-Stage Build Dependency
To bundle a full, static `qsv` binary into any other container image (Alpine, Debian, Ubuntu, etc.):

```dockerfile
FROM dartfx/qsv:latest AS qsv-source

FROM your-base-image
COPY --from=qsv-source /usr/local/bin/qsv /usr/local/bin/qsv
```

---

## Local Development & Publishing

### Verification
```bash
./verify_image.sh dartfx/qsv:latest
```

### Publishing Multi-Arch
```bash
# Staging pre-release
./publish_image.sh --staging -q 27.0.1

# Production release
./publish_image.sh -q 27.0.1
```
