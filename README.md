# POC2 Audit Access

A proof-of-concept repository demonstrating automated audit access tracking and monitoring pipeline with GitHub Actions.

## 📋 Objectives

This repository serves as a proof of concept for:

- **Automated Audit Pipeline**: Implement a complete CI/CD pipeline with setup, testing, summarization, and artifact management
- **Access Tracking**: Demonstrate audit-ready access logging and monitoring capabilities
- **GitHub-Native Solution**: Utilize GitHub Actions exclusively without external tools
- **Artifact Management**: Systematically collect, organize, and preserve pipeline execution data
- **Compliance Readiness**: Establish patterns for audit-compliant development workflows

## 🏗️ Architecture

### Repository Structure

```
poc2-audit-access/
├── .github/
│   ├── workflows/         # GitHub Actions workflows
│   │   └── pipeline.yml   # Main audit access pipeline
│   └── agents/            # Custom agent configurations
│       └── README.md
├── scripts/               # Automation scripts
│   ├── run-tests.sh      # Validation test suite
│   └── generate-summary.sh # Summary generation script
├── config/                # Configuration files
│   └── settings.yml      # Pipeline settings
├── .gitignore            # Git ignore patterns
├── LICENSE               # MIT License
└── README.md             # This file
```

### Pipeline Stages

The automated pipeline consists of four sequential stages:

#### 1. **Setup** 🔧
- Environment initialization
- Timestamp generation
- Repository metadata collection
- Setup artifact creation

#### 2. **Test** ✅
- Configuration validation
- Directory structure verification
- Workflow file validation
- Script validation
- Git repository checks
- Documentation validation

#### 3. **Summarize** 📊
- Results aggregation
- Report generation
- Metadata compilation
- Test result analysis

#### 4. **Upload Artifacts** 📦
- Artifact consolidation
- Archive creation
- Final artifact upload
- Completion summary

## 🚀 How to Trigger the Pipeline

### Automatic Triggers

The pipeline runs automatically on:

1. **Push to main branch**
   ```bash
   git push origin main
   ```

2. **Push to copilot branches**
   ```bash
   git push origin copilot/feature-name
   ```

3. **Pull Request to main**
   - Create a PR targeting the `main` branch
   - Pipeline runs automatically on PR creation and updates

### Manual Trigger

You can manually trigger the pipeline from GitHub:

1. Navigate to the **Actions** tab in the repository
2. Select **Audit Access Pipeline** from the workflows list
3. Click **Run workflow** button
4. Select the branch to run against
5. Click **Run workflow** to start execution

### Command Line Trigger

Using GitHub CLI (`gh`):

```bash
gh workflow run pipeline.yml --ref main
```

## 📥 Accessing Pipeline Results

### Viewing Pipeline Runs

1. Go to the **Actions** tab in the GitHub repository
2. Click on a specific workflow run to see details
3. View logs for each job (Setup, Test, Summarize, Upload Artifacts)

### Downloading Artifacts

Artifacts are available for 90 days after pipeline execution:

1. Navigate to a completed workflow run
2. Scroll to the **Artifacts** section at the bottom
3. Download available artifacts:
   - `setup-results` - Environment setup information
   - `test-results` - Test execution results
   - `final-report-{timestamp}` - Comprehensive pipeline report
   - `all-artifacts-{timestamp}` - Consolidated archive of all outputs

### Available Artifacts

| Artifact | Description | Retention |
|----------|-------------|-----------|
| setup-results | Setup phase outputs and environment info | 30 days |
| test-results | Test execution results and summaries | 30 days |
| final-report-{timestamp} | Complete pipeline execution report | 90 days |
| all-artifacts-{timestamp} | Consolidated archive (tar.gz) | 90 days |

## 🔍 Validation Tests

The pipeline includes comprehensive validation tests:

- ✅ Configuration file validation
- ✅ Directory structure verification
- ✅ Workflow definition checks
- ✅ Script existence and permissions
- ✅ Git repository validation
- ✅ Documentation completeness

## 📊 Pipeline Outputs

### Setup Phase Output
- Timestamp of execution
- Run ID
- Environment information
- Repository metadata

### Test Phase Output
- Test execution summary
- Validation results
- Pass/fail status for each test

### Summary Report
A comprehensive markdown report including:
- Pipeline metadata (Run ID, timestamp, commit info)
- Setup phase details
- Test execution results
- Final status and completion time

## 🛠️ Local Testing

To run tests locally:

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Run validation tests
./scripts/run-tests.sh

# Generate summary
./scripts/generate-summary.sh
```

## 📋 Configuration

Pipeline behavior can be customized via `config/settings.yml`:

```yaml
pipeline:
  stages: [setup, test, summarize, upload]
  timeout_minutes: 30
  retention_days: 90

artifacts:
  compression: true
  format: tar.gz
  retention_days: 90
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Pipeline URLs

After running the pipeline, you can access:

- **Actions Tab**: `https://github.com/infra-neo/poc2-audit-access/actions`
- **Latest Run**: `https://github.com/infra-neo/poc2-audit-access/actions/workflows/pipeline.yml`
- **Workflow File**: `.github/workflows/pipeline.yml`

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Artifact Upload/Download](https://github.com/actions/upload-artifact)

## 🤝 Contributing

This is a proof-of-concept repository. For contributions or suggestions, please follow standard GitHub workflow:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📞 Support

For issues or questions related to this POC, please open an issue in the repository.