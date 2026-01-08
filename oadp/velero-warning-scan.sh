#!/bin/bash

# Usage: ./velero-warning-scan.sh <restore-name> [namespace]
# Default namespace is openshift-adp

RESTORE_NAME="$1"
NAMESPACE="${2:-openshift-adp}"

if [[ -z "$RESTORE_NAME" ]]; then
  echo "❌ Usage: $0 <restore-name> [namespace]"
  exit 1
fi

echo "🔍 Analyzing warnings for restore: $RESTORE_NAME (namespace: $NAMESPACE)"
echo "------------------------------------------------------------"

# Run velero restore logs and filter warnings
velero restore logs "$RESTORE_NAME" -n "$NAMESPACE" 2>/dev/null | \
  grep -i "warning" | \
  sed -E 's/^.*msg="([^"]+)".*restore=([^ ]+).*/[WARN] \1  (Restore: \2)/' | \
  sort | uniq

EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "⚠️ No logs found or restore is still in progress. Please check the restore status."
  exit $EXIT_CODE
else
  echo "✅ Warning scan complete."
fi

