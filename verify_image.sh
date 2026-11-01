#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:-dartfx/qsv:latest}"

echo "=== Verifying Docker Image: ${IMAGE_NAME} ==="

# 1. Check version string
echo -n "Checking qsv binary execution... "
VERSION_OUTPUT=$(docker run --rm "${IMAGE_NAME}" --version)
echo "OK (${VERSION_OUTPUT})"

# 2. Check installed commands count
echo -n "Checking command palette... "
COMMANDS_LIST=$(docker run --rm "${IMAGE_NAME}" --list)
TOTAL_COMMANDS=$(echo "${COMMANDS_LIST}" | grep -E '^[[:space:]]+[a-z0-9]+[[:space:]]+' | wc -l | tr -d '[:space:]')
echo "Found ${TOTAL_COMMANDS} commands"

# 3. Verify presence of critical advanced commands
REQUIRED_COMMANDS=(
  "sqlp"
  "joinp"
  "pivotp"
  "luau"
  "to"
  "geocode"
  "readstat"
  "writestat"
  "profile"
  "viz"
  "synthesize"
  "get"
  "fetch"
)

echo "Verifying presence of full-feature commands:"
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  echo -n "  - Checking '${cmd}'... "
  if echo "${COMMANDS_LIST}" | grep -E "^[[:space:]]+${cmd}[[:space:]]+" >/dev/null; then
    echo "OK"
  else
    echo "FAILED (command '${cmd}' is missing from binary!)"
    exit 1
  fi
done

# 4. Functional test: Run an actual sqlp query via stdin
echo -n "Running functional test: Polars SQL query (sqlp)... "
SQLP_RESULT=$(printf "name,score\nAlice,95\nBob,82\n" | docker run -i --rm "${IMAGE_NAME}" sqlp - "SELECT name, score * 2 as double_score FROM _t_1 WHERE score > 90")
EXPECTED="Alice,190"
if echo "${SQLP_RESULT}" | grep -q "${EXPECTED}"; then
  echo "OK (received: $(echo "${SQLP_RESULT}" | tr '\n' ' '))"
else
  echo "FAILED (unexpected output: ${SQLP_RESULT})"
  exit 1
fi

echo "=== All checks passed successfully! Image is 100% full-featured. ==="
