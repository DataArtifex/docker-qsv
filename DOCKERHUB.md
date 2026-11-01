# dartfx/qsv

Full-featured, multi-architecture (`linux/amd64` and `linux/arm64`) Docker distribution of [QSV](https://github.com/dathere/qsv), the blazing-fast data-wrangling toolkit.

## Highlights
- **100% Feature-Complete**: Includes `sqlp`, `joinp`, `luau`, `to` (Parquet/XLSX), `geocode`, `readstat`, `viz`, and all 78 commands.
- **Multi-Platform**: Native binaries for both AMD64 and ARM64.
- **Statically Linked**: Runs seamlessly on Alpine, Debian, Ubuntu, CentOS, or Scratch.

## Quick Start
```bash
docker run --rm -v $(pwd):/data dartfx/qsv sqlp input.csv "SELECT * FROM _t_1 LIMIT 10"
```
