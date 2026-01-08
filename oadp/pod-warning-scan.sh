#!/bin/bash

# velero-warning-scan.sh
# - oc logs 로 출력된 로그에서 warning + error 메시지 추출 + 시간 포함

POD_NAME=""
NAMESPACE=""
CONTAINER=""

usage() {
  echo "Usage:"
  echo "  $0 --pod <pod-name> --namespace <namespace> [--container <container-name>]"
  exit 1
}

# 파라미터 처리
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --pod)
      POD_NAME="$2"
      shift 2
      ;;
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    --container)
      CONTAINER="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$POD_NAME" || -z "$NAMESPACE" ]]; then
  echo "❌ Error: --pod and --namespace are required."
  usage
fi

echo "🔍 Scanning 'error' and 'warning' logs for pod: $POD_NAME (namespace: $NAMESPACE)"
echo "------------------------------------------------------------"

# 로그 호출
if [[ -n "$CONTAINER" ]]; then
  LOG_OUTPUT=$(oc logs "$POD_NAME" -n "$NAMESPACE" -c "$CONTAINER" --timestamps 2>/dev/null)
else
  LOG_OUTPUT=$(oc logs "$POD_NAME" -n "$NAMESPACE" --timestamps 2>/dev/null)
fi

if [[ -z "$LOG_OUTPUT" ]]; then
  echo "⚠️ No logs found or Pod not accessible."
  exit 1
fi

# 경고/에러 라인 필터링 및 포맷
echo "$LOG_OUTPUT" | grep -Ei "warning|error" | \
  awk '
  {
    timestamp=$1;
    level="";
    message="";
    for (i=2; i<=NF; i++) {
      if ($i ~ /level=(warning|error)/) {
        split($i, a, "=");
        level=toupper(a[2]);
      }
      if ($i ~ /^msg=/) {
        msg_start=i;
        break;
      }
    }
    # 메시지 추출
    for (j=msg_start; j<=NF; j++) {
      message = message $j " ";
    }
    # msg="..." 안에서 메시지만 추출
    gsub(/^msg="/, "", message);
    gsub(/"$/, "", message);
    printf "[%s] [%s] %s\n", level, timestamp, message;
  }
  '

echo "✅ Log scan complete."

