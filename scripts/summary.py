#!/usr/bin/env python3
"""
Summary Report Generator
Generates a comprehensive summary report from test logs and registration results
"""

import sys
import json
import os
from datetime import datetime, timezone

def parse_log_file(log_file):
    """Parse the test log file and extract results"""
    results = {
        "tests_run": 0,
        "tests_passed": 0,
        "tests_failed": 0,
        "warnings": 0,
        "errors": []
    }
    
    if not os.path.exists(log_file):
        print(f"Warning: Log file {log_file} not found", file=sys.stderr)
        return results
    
    with open(log_file, 'r') as f:
        content = f.read()
        
        # Count test results
        results["tests_passed"] = content.count("[PASS]")
        results["tests_failed"] = content.count("[FAIL]")
        results["warnings"] = content.count("[WARNING]")
        results["tests_run"] = results["tests_passed"] + results["tests_failed"]
        
        # Extract errors
        for line in content.split('\n'):
            if "[FAIL]" in line or "[ERROR]" in line:
                results["errors"].append(line.strip())
    
    return results

def load_registration_data():
    """Load LXD registration results if available"""
    reg_file = "/tmp/lxd_registration.json"
    if os.path.exists(reg_file):
        try:
            with open(reg_file, 'r') as f:
                return json.load(f)
        except:
            return None
    return None

def generate_summary_report(log_file):
    """Generate the complete summary report"""
    print("=" * 60)
    print("  KASM WORKSPACES DEPLOYMENT - SUMMARY REPORT")
    print("=" * 60)
    print()
    
    # Timestamp
    print(f"Report Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print()
    
    # Parse test results
    print("-" * 60)
    print("TEST RESULTS")
    print("-" * 60)
    
    test_results = parse_log_file(log_file)
    print(f"Total Tests Run:     {test_results['tests_run']}")
    print(f"Tests Passed:        {test_results['tests_passed']}")
    print(f"Tests Failed:        {test_results['tests_failed']}")
    print(f"Warnings:            {test_results['warnings']}")
    
    if test_results['errors']:
        print("\nErrors/Failures:")
        for error in test_results['errors'][:5]:  # Show first 5 errors
            print(f"  - {error}")
    
    print()
    
    # LXD Registration Status
    print("-" * 60)
    print("LXD REGISTRATION STATUS")
    print("-" * 60)
    
    reg_data = load_registration_data()
    if reg_data:
        print(f"Registration Attempted: {'Yes' if reg_data.get('registration_attempted') else 'No'}")
        print(f"Registration Success:   {'Yes' if reg_data.get('success') else 'No'}")
        print(f"LXD Endpoint:          {reg_data.get('endpoint', 'N/A')}")
        if reg_data.get('instance_data'):
            instance = reg_data['instance_data']
            print(f"Hostname:              {instance.get('hostname', 'N/A')}")
            print(f"Local IP:              {instance.get('local_ip', 'N/A')}")
    else:
        print("Registration data not available")
    
    print()
    
    # Kasm Information
    print("-" * 60)
    print("KASM WORKSPACES INFORMATION")
    print("-" * 60)
    
    creds_file = "/tmp/kasm_credentials.txt"
    if os.path.exists(creds_file):
        with open(creds_file, 'r') as f:
            for line in f:
                if '=' in line:
                    key, value = line.strip().split('=', 1)
                    print(f"{key:20s}: {value}")
    else:
        print("Kasm credentials file not found")
        print("Default URL: https://localhost:443")
    
    print()
    
    # Overall Status
    print("-" * 60)
    print("OVERALL STATUS")
    print("-" * 60)
    
    overall_success = (test_results['tests_failed'] == 0 and 
                      test_results['tests_passed'] > 0)
    
    if overall_success:
        print("✓ DEPLOYMENT SUCCESSFUL")
        print("  Kasm Workspaces is ready for use")
        print("  API is accessible via Swagger interface")
    else:
        print("✗ DEPLOYMENT INCOMPLETE")
        print("  Some tests failed - review logs for details")
    
    print()
    print("=" * 60)
    print("  END OF REPORT")
    print("=" * 60)
    
    return 0 if overall_success else 1

def main():
    """Main execution function"""
    if len(sys.argv) < 2:
        print("Usage: python3 summary.py <log_file>", file=sys.stderr)
        sys.exit(1)
    
    log_file = sys.argv[1]
    sys.exit(generate_summary_report(log_file))

if __name__ == "__main__":
    main()
