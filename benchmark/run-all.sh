#!/bin/bash
set -euo pipefail

# =============================================================================
# run-all.sh — Orchestrates benchmark + correctness tests for both engines
#
# Reads config from ~/.opensearch-env:
#   DATAFUSION_HOST              — DataFusion OpenSearch private IP
#   LUCENE_HOST                  — Lucene OpenSearch private IP (empty if disabled)
#   WORKLOAD_PATH_DATAFUSION     — Path to datafusion clickbench workload
#   WORKLOAD_PATH_LUCENE         — Path to lucene clickbench workload
#
# Usage: Called automatically by user-data, or manually:
#   bash benchmark/run-all.sh
# =============================================================================

source "$HOME/.opensearch-env"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "============================================"
echo "  OpenSearch Test Automation"
echo "  DataFusion host: ${DATAFUSION_HOST}"
echo "  Lucene host:     ${LUCENE_HOST:-not enabled}"
echo "============================================"

# --- DataFusion benchmark ---
echo ""
echo ">>> Running DataFusion benchmark..."
bash "$REPO_DIR/benchmark/run-benchmark.sh" \
  --host "$DATAFUSION_HOST" \
  --engine datafusion \
  --workload "$WORKLOAD_PATH_DATAFUSION" \
  2>&1 | tee "$HOME/benchmark-datafusion.log"

# --- Lucene benchmark ---
if [ -n "${LUCENE_HOST:-}" ]; then
  echo ""
  echo ">>> Running Lucene benchmark..."
  bash "$REPO_DIR/benchmark/run-benchmark.sh" \
    --host "$LUCENE_HOST" \
    --engine lucene \
    --workload "$WORKLOAD_PATH_LUCENE" \
    2>&1 | tee "$HOME/benchmark-lucene.log"
else
  echo "Lucene instance not enabled, skipping Lucene benchmark."
fi

# --- DataFusion correctness test ---
echo ""
echo ">>> Running DataFusion correctness test..."
bash "$REPO_DIR/correctness/run-correctness-test.sh" "$DATAFUSION_HOST" "datafusion" \
  2>&1 | tee "$HOME/correctness-datafusion.log"

# --- Lucene correctness test ---
if [ -n "${LUCENE_HOST:-}" ]; then
  echo ""
  echo ">>> Running Lucene correctness test..."
  bash "$REPO_DIR/correctness/run-correctness-test.sh" "$LUCENE_HOST" "lucene" \
    2>&1 | tee "$HOME/correctness-lucene.log"
fi

echo ""
echo "============================================"
echo "  All tests complete!"
echo "  Benchmark results:    ~/benchmark-results/"
echo "  Correctness results:  ~/correctness-results/"
echo "============================================"
