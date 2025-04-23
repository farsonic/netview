#!/bin/bash

# Usage: ./make-bridges.sh <bridge_count> <dummy_per_bridge> [prefix] [mode]
# Example: ./make-bridges.sh 3 2 testbr linux
# Modes: linux (default), ovs, all

set -e

BR_COUNT=$1
DUMMY_PER_BRIDGE=$2
PREFIX=${3:-testbr}
MODE=${4:-linux}

if [[ -z "$BR_COUNT" || -z "$DUMMY_PER_BRIDGE" ]]; then
  echo "Usage: $0 <bridge_count> <dummy_per_bridge> [bridge_prefix] [linux|ovs|all]"
  exit 1
fi

create_linux_bridge() {
  local br_name=$1
  ip link add name "$br_name" type bridge
  ip link set "$br_name" up
}

create_ovs_bridge() {
  local br_name=$1
  ovs-vsctl add-br "$br_name"
  ip link set "$br_name" up
}

create_dummy_and_attach() {
  local br_name=$1
  local dummy_name=$2
  ip link add "$dummy_name" type dummy
  ip link set "$dummy_name" up
  ip link set "$dummy_name" master "$br_name" 2>/dev/null || ovs-vsctl add-port "$br_name" "$dummy_name"
}

for ((i = 0; i < BR_COUNT; i++)); do
  BR_NAME="${PREFIX}$i"

  if [[ "$MODE" == "linux" || "$MODE" == "all" ]]; then
    echo "Creating Linux bridge: $BR_NAME"
    create_linux_bridge "$BR_NAME"
  fi

  if [[ "$MODE" == "ovs" || "$MODE" == "all" ]]; then
    echo "Creating OVS bridge: $BR_NAME"
    create_ovs_bridge "$BR_NAME"
  fi

  for ((j = 0; j < DUMMY_PER_BRIDGE; j++)); do
    DUMMY_ID=$((i * DUMMY_PER_BRIDGE + j))
    DUMMY_IF="dummy_${PREFIX}_${DUMMY_ID}"
    echo "  Adding dummy interface: $DUMMY_IF to $BR_NAME"
    create_dummy_and_attach "$BR_NAME" "$DUMMY_IF"
  done
done

echo "✅ Created $BR_COUNT $MODE bridge(s) with $DUMMY_PER_BRIDGE dummy interfaces each (prefix: $PREFIX)"
