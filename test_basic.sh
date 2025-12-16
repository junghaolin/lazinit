#!/bin/bash
# 测试脚本

set -e

echo "Test 1: Basic"
echo "OK"

echo "Test 2: Variables"
OS="linux"
echo "OS=$OS"

echo "Test 3: Function"
test_func() {
    echo "In function"
    return 0
}
test_func
echo "Function OK"

echo "Test 4: Conditional"
TEST=true
if [ "$TEST" = true ]; then
    echo "Conditional OK"
fi

echo "All tests passed!"
