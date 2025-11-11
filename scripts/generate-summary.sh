#!/bin/bash

# generate-summary.sh - Generate comprehensive summary of pipeline execution

set -e

echo "=========================================="
echo "Generating Pipeline Summary"
echo "=========================================="

# Summary header
echo ""
echo "Pipeline Execution Summary"
echo "Generated at: $(date)"
echo ""

# Environment information
echo "--- Environment Information ---"
echo "Operating System: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo ""

# Repository information
echo "--- Repository Information ---"
if [ -d ".git" ]; then
    echo "Current Branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "Latest Commit: $(git rev-parse --short HEAD)"
    echo "Commit Message: $(git log -1 --pretty=%B | head -n1)"
    echo "Author: $(git log -1 --pretty=%an)"
    echo "Date: $(git log -1 --pretty=%ad)"
else
    echo "Not a Git repository"
fi
echo ""

# Test results
echo "--- Test Results ---"
if [ -d "test-results" ]; then
    echo "Test artifacts found:"
    find test-results -type f | while read file; do
        echo "  - $(basename $file)"
    done
    
    if [ -f "test-results/test-summary.txt" ]; then
        echo ""
        echo "Test Summary:"
        cat test-results/test-summary.txt | sed 's/^/  /'
    fi
else
    echo "No test results directory found"
fi
echo ""

# Directory structure
echo "--- Directory Structure ---"
echo "Project structure:"
tree -L 2 -a 2>/dev/null || find . -maxdepth 2 -type d | grep -v ".git" | sed 's|^\./|  |'
echo ""

# File statistics
echo "--- File Statistics ---"
echo "Total files: $(find . -type f | grep -v ".git" | wc -l)"
echo "Total directories: $(find . -type d | grep -v ".git" | wc -l)"
echo "Workflow files: $(find .github/workflows -type f 2>/dev/null | wc -l)"
echo "Script files: $(find scripts -type f 2>/dev/null | wc -l)"
echo "Config files: $(find config -type f 2>/dev/null | wc -l)"
echo ""

# Summary footer
echo "=========================================="
echo "Summary Generation Complete"
echo "=========================================="
echo "Status: SUCCESS"
echo "Completed at: $(date)"
