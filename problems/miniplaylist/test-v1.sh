#!/usr/bin/env bash

# mini-playlist SPEC test script
# Author: Ahmet TANGAZ
# Project: mini-playlist

set -e

PASS_COUNT=0
FAIL_COUNT=0

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  cd "$(dirname "$0")"
  rm -rf testenv
}

######################################
# Setup
######################################
cleanup
mkdir testenv
cd testenv

# Create a dummy script so python commands work inside testenv
cat << 'EOF' > minipl.py
import sys, os
sys.path.insert(0, os.path.abspath('..'))
import solution_v1 as app
if __name__ == "__main__":
    app.main()
EOF

######################################
# Test 1: init creates directory
######################################
if python3 minipl.py init | grep -q "initialized successfully" && [ -d .miniplaylist ]; then
  pass "init creates .miniplaylist directory"
else
  fail "init creates .miniplaylist directory"
fi

######################################
# Test 2: init duplicate
######################################
if python3 minipl.py init | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: add song
######################################
if python3 minipl.py add "Dark Red" "Steve Lacy" "Dark Red" | grep -q "Successfully"; then
  pass "add song appends to list"
else
  fail "add song appends to list"
fi

######################################
# Test 4: show songs
######################################
if python3 minipl.py show | grep -q "Dark Red"; then
  pass "show displays added songs"
else
  fail "show displays added songs"
fi

######################################
# Test 5: remove song
######################################
python3 minipl.py remove 1 >/dev/null 2>&1
if python3 minipl.py show | grep -q "List is empty" || ! python3 minipl.py show | grep -q "Dark Red"; then
  pass "remove deletes the song"
else
  fail "remove deletes the song"
fi

######################################
# Cleanup & Summary
######################################
cd ..
rm -rf testenv

echo ""
echo "========================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL:  $((PASS_COUNT + FAIL_COUNT))"
echo "========================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "ALL V1 TESTS PASSED"
  exit 0
else
  exit 1
fi