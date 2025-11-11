#!/bin/bash

# run-tests.sh - Execute validation tests for the audit access pipeline

set -e

echo "=========================================="
echo "Starting Validation Tests"
echo "=========================================="

# Test 1: Configuration validation
echo ""
echo "Test 1: Validating configuration files..."
if [ -f "config/settings.yml" ]; then
    echo "✓ Configuration file exists"
else
    echo "⚠ Configuration file not found, using defaults"
fi

# Test 2: Directory structure validation
echo ""
echo "Test 2: Validating directory structure..."
REQUIRED_DIRS=(".github/workflows" ".github/agents" "scripts" "config")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ Directory exists: $dir"
    else
        echo "✗ Missing directory: $dir"
        exit 1
    fi
done

# Test 3: Workflow file validation
echo ""
echo "Test 3: Validating workflow files..."
if [ -f ".github/workflows/pipeline.yml" ]; then
    echo "✓ Pipeline workflow exists"
    # Check if workflow has required jobs
    if grep -q "jobs:" .github/workflows/pipeline.yml; then
        echo "✓ Workflow has jobs defined"
    else
        echo "✗ Workflow missing jobs"
        exit 1
    fi
else
    echo "✗ Pipeline workflow not found"
    exit 1
fi

# Test 4: Script validation
echo ""
echo "Test 4: Validating scripts..."
SCRIPTS=("scripts/run-tests.sh" "scripts/generate-summary.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "✓ Script exists: $script"
        if [ -x "$script" ]; then
            echo "✓ Script is executable: $script"
        else
            echo "⚠ Script not executable: $script"
        fi
    else
        echo "✗ Missing script: $script"
        exit 1
    fi
done

# Test 5: Git repository validation
echo ""
echo "Test 5: Validating Git repository..."
if [ -d ".git" ]; then
    echo "✓ Git repository initialized"
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "  Current branch: $BRANCH"
else
    echo "✗ Not a Git repository"
    exit 1
fi

# Test 6: Documentation validation
echo ""
echo "Test 6: Validating documentation..."
if [ -f "README.md" ]; then
    echo "✓ README.md exists"
    if [ $(wc -l < README.md) -gt 10 ]; then
        echo "✓ README.md has substantial content"
    else
        echo "⚠ README.md is minimal"
    fi
else
    echo "✗ README.md not found"
    exit 1
fi

if [ -f "LICENSE" ]; then
    echo "✓ LICENSE file exists"
else
    echo "⚠ LICENSE file not found"
fi

echo ""
echo "=========================================="
echo "All Tests Passed Successfully!"
echo "=========================================="
echo "Total tests run: 6"
echo "Status: PASS"
echo "Timestamp: $(date)"
