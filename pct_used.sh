#!/usr/bin/env bash
# Usage: ./pct_used.sh /mnt/store1/001

set -euo pipefail

MOUNT_PATH="${1:-}"

# Check if argument is provided
if [[ -z "$MOUNT_PATH" ]]; then
  echo "Usage: $0 <mount_path>" >&2
  exit 2
fi

# Check if argument is provided
if [[ ! -d "$MOUNT_PATH" ]]; then
  echo "Path not found: $MOUNT_PATH" >&2
  exit 3
fi

# Get percentage used via df; NR==2 = the data row
# +0 forces numeric output (strips '%')
pct_used="$(df -P "$MOUNT_PATH" 2>/dev/null | awk 'NR==2{print $5+0}')"

# Validate: empty or not numeric?
if [[ -z "$pct_used" || ! "$pct_used" =~ ^[0-9]+$ ]]; then
  echo "Unable to read usage for: $MOUNT_PATH" >&2
  exit 4
fi

# Output only the number to stdout (for Telegraf)
echo "$pct_used"