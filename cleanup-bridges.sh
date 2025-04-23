#!/bin/bash

# Usage: ./cleanup-bridges.sh <bridge_count> <dummy_per_bridge> [prefix] [mode]
# Modes: linux (default), ovs, all

set -e

BR_COUNT=$1
DUMMY_PER_BRIDGE=$2
PREFIX=${3:-testbr}
MODE=${4:-linux}

for ((i = 0; i < BR_COUNT; i++)); do
  BR_NAME="${PREFIX}$i"

  for ((j = 0; j < DUMMY_PER_BRIDGE; j++)); do
    DUMMY_ID=$((i * DUMMY_PER_BRIDGE + j))
    DUMMY_IF="dummy_${PREFIX}_${DUMMY_ID}"
    echo "Deleting dummy interface: $DUMMY_IF"
    ip link delete "$DUMMY_IF" type dummy || true
  done

  echo "Deleting bridge: $BR_NAME"
  if [[ "$MODE" == "ovs" || "$MODE" == "all" ]]; then
    ovs-vsctl del-br "$BR_NAME" || true
  fi
  if [[ "$MODE" == "linux" || "$MODE" == "all" ]]; then
    ip link delete "$BR_NAME" type bridge || true
  fi
done

echo "🧹 Cleanup complete (prefix: $PREFIX, mode: $MODE)"
