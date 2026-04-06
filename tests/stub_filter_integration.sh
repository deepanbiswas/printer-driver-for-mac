#!/usr/bin/env bash
# Integration test: pipe empty payload into stub filter with CUPS-like arguments.
set -euo pipefail
FILTER="${1:?path to g3010_filter required}"
printf '' | "$FILTER" 1 testuser "Test Job" 1 "" -
