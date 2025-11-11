# POC2 Audit Access - Kasm Workspaces Deployment

[![Deploy & Test](https://github.com/infra-neo/poc2-audit-access/actions/workflows/deploy.yml/badge.svg)](https://github.com/infra-neo/poc2-audit-access/actions/workflows/deploy.yml)

Automated deployment pipeline for Kasm Workspaces with LXD instance registration capabilities.

## Overview

This project provides a complete CI/CD pipeline that:
1. ✅ Installs Kasm Workspaces via Docker on Ubuntu runners
2. ✅ Exposes Kasm API via Swagger UI (port 443/tcp)
3. ✅ Registers instances to LXD endpoint (`https://201.151.150.226:8443`)
4. ✅ Generates comprehensive test reports and logs
5. ✅ Maintains structured workflow: setup → test → summary → artifacts

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Setup Phase                                              │
│     └─ Install Kasm Workspaces (Docker-based)               │
│        └─ Configure API on port 443                          │
│                                                               │
│  2. Test Phase                                               │
│     └─ Validate Kasm containers                              │
│     └─ Test API endpoints                                    │
│     └─ Verify Swagger documentation                          │
│                                                               │
│  3. Registration Phase                                       │
│     └─ Connect to LXD endpoint                               │
│     └─ Register Kasm instance                                │
│                                                               │
│  4. Summary Phase                                            │
│     └─ Generate deployment report                            │
│     └─ Aggregate test results                                │
│                                                               │
│  5. Artifact Collection                                      │
│     └─ Upload logs and reports                               │
│     └─ Preserve credentials                                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Structure

### File Organization

```
.github/workflows/
└── deploy.yml              # Main workflow orchestration

scripts/
├── setup_kasm.sh          # Kasm Workspaces installation
├── test_kasm.sh           # API and service validation
├── lxd_register.py        # LXD endpoint registration
├── summary.py             # Report generation
└── cleanup.sh             # Resource cleanup
```

### Workflow Stages

1. **Setup** - Installs Kasm Workspaces v1.15.0 using Docker
2. **Test** - Validates installation, API endpoints, and services
3. **Register** - Connects to LXD management endpoint
4. **Summary** - Generates comprehensive deployment report
5. **Cleanup** - Stops services and preserves artifacts
6. **Artifacts** - Uploads logs, reports, and credentials

## Kasm Workspaces API Connection

### Accessing the Swagger API

Once Kasm is deployed, the API is available at:

```
URL: https://localhost:443/api/public/swagger
```

**Default Credentials:**
- Username: `admin@kasm.local` (or check deployment artifacts)
- Password: Generated during installation (check credentials artifact)

### API Endpoints

Key API endpoints available:

- **Status**: `GET /api/public/get_status`
- **Sessions**: `GET /api/public/get_sessions`
- **Users**: `GET /api/public/get_users`
- **Workspaces**: `GET /api/public/get_workspaces`

Full API documentation available in Swagger UI.

## Connecting with Postman

### Option 1: Import Swagger Definition

1. **Open Postman** and create a new workspace
2. **Import API Specification**:
   - Click `Import` → `Link`
   - Enter: `https://localhost:443/api/public/swagger.json`
   - Click `Continue` → `Import`

3. **Configure Environment**:
   - Create new environment: `Kasm Local`
   - Add variables:
     ```
     base_url: https://localhost:443
     api_key: <your-api-key>
     ```

4. **Disable SSL Verification** (for self-signed certificates):
   - Settings → General → SSL certificate verification → OFF

### Option 2: Manual Collection Setup

1. **Create New Collection**: `Kasm Workspaces API`

2. **Add Authentication**:
   - Collection → Authorization
   - Type: `API Key`
   - Key: `Authorization`
   - Value: `Bearer <token>`
   - Add to: `Header`

3. **Add Sample Requests**:

   **Get Status**
   ```
   GET https://localhost:443/api/public/get_status
   Headers:
     Authorization: Bearer <your-token>
   ```

   **List Users**
   ```
   GET https://localhost:443/api/public/get_users
   Headers:
     Authorization: Bearer <your-token>
   ```

   **Get Sessions**
   ```
   GET https://localhost:443/api/public/get_sessions
   Headers:
     Authorization: Bearer <your-token>
   ```

### Obtaining API Token

To get an API token for Postman:

1. **Login to Kasm**: `https://localhost:443`
2. **Navigate to**: Admin → API Keys
3. **Generate New API Key**:
   - Name: `Postman Testing`
   - Expiration: 30 days
   - Copy the generated token

4. **Use in Postman**:
   - Add to Authorization header as `Bearer <token>`

### Postman Pre-request Script

For automated token refresh, add this to your collection pre-request:

```javascript
// Kasm API Authentication
const baseUrl = pm.environment.get("base_url");
const username = pm.environment.get("username");
const password = pm.environment.get("password");

if (!pm.environment.get("access_token")) {
    pm.sendRequest({
        url: `${baseUrl}/api/public/login`,
        method: 'POST',
        header: {
            'Content-Type': 'application/json',
        },
        body: {
            mode: 'raw',
            raw: JSON.stringify({
                username: username,
                password: password
            })
        }
    }, function (err, res) {
        if (!err) {
            const token = res.json().token;
            pm.environment.set("access_token", token);
        }
    });
}
```

## LXD Registration

The workflow automatically registers new Kasm instances to the LXD endpoint:

- **Endpoint**: `https://201.151.150.226:8443`
- **Method**: REST API via Python
- **Data Sent**: Hostname, IP, Kasm URL, timestamp, status

Registration is handled by `scripts/lxd_register.py` which:
- Gathers system information
- Sends POST request to LXD endpoint
- Saves registration result as JSON artifact
- Handles connection failures gracefully (for CI/CD compatibility)

## Running the Workflow

### Automatic Trigger

The workflow triggers automatically on:
- Push to `main` branch
- Push to `copilot/**` branches
- Pull requests to `main`

### Manual Trigger

1. Go to: https://github.com/infra-neo/poc2-audit-access/actions
2. Select: `Kasm Workspaces Deployment & Test`
3. Click: `Run workflow`
4. Select branch and click `Run workflow`

## Accessing Artifacts

After workflow completion, artifacts are available at:

```
https://github.com/infra-neo/poc2-audit-access/actions/runs/<RUN_ID>
```

### Available Artifacts

| Artifact Name | Description | Retention |
|--------------|-------------|-----------|
| `kasm-deployment-logs` | Complete installation and test logs | 30 days |
| `kasm-deployment-report` | Summary report with test results | 30 days |
| `kasm-credentials` | Kasm access credentials | 7 days |
| `lxd-registration-data` | LXD registration response | 30 days |

### Viewing Report

Download and view the summary report:

```bash
# Download artifact
gh run download <RUN_ID> -n kasm-deployment-report

# View report
cat report.txt
```

## Local Development

### Prerequisites

- Ubuntu 20.04+ or compatible Linux
- Docker installed
- Minimum 4GB RAM, 20GB disk space
- Root/sudo access

### Running Scripts Locally

```bash
# Install Kasm Workspaces
sudo bash scripts/setup_kasm.sh

# Test installation
bash scripts/test_kasm.sh

# Register with LXD
python3 scripts/lxd_register.py

# Generate summary
python3 scripts/summary.py test.log

# Cleanup
bash scripts/cleanup.sh
```

## Troubleshooting

### Common Issues

**Issue**: Kasm installation fails
- **Solution**: Check system requirements (RAM, disk space)
- **Logs**: Review `/tmp/kasm_install.log`

**Issue**: API not accessible
- **Solution**: Wait 30-60 seconds for services to fully start
- **Check**: `sudo docker ps` to verify containers are running

**Issue**: LXD registration fails
- **Solution**: This is expected in CI/CD - endpoint may be unreachable
- **Note**: Registration failure doesn't stop workflow

### Debug Commands

```bash
# Check Kasm containers
sudo docker ps --filter "name=kasm"

# View Kasm logs
sudo docker logs <container-name>

# Test API manually
curl -k https://localhost:443/api/public/get_status

# Check credentials
cat /tmp/kasm_credentials.txt
```

## CI/CD Integration

### Workflow Timeline

```
Checkout (10s) → Setup (15-20m) → Test (30s) → Register (10s) 
→ Summary (5s) → Cleanup (30s) → Artifacts (10s)

Total: ~20-25 minutes
```

### Success Criteria

- ✓ All Kasm containers running
- ✓ API responding on port 443
- ✓ Swagger documentation accessible
- ✓ Test suite passing (≥80%)
- ✓ Artifacts uploaded successfully

## Security Notes

⚠️ **Important Security Considerations**:

1. **Self-Signed Certificates**: Kasm uses self-signed SSL certificates by default
2. **Credentials**: Generated passwords are stored in artifacts (7-day retention)
3. **API Access**: Secure API keys in production deployments
4. **LXD Endpoint**: Uses HTTPS with SSL verification disabled (adjust for production)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit pull request with description

## Support

For issues or questions:
- Open an issue: https://github.com/infra-neo/poc2-audit-access/issues
- Review workflow runs: https://github.com/infra-neo/poc2-audit-access/actions

## License

MIT License - see LICENSE file for details

---

**Project Status**: Active Development  
**Last Updated**: 2025-11-11  
**Kasm Version**: 1.15.0