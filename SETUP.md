# Workshop Setup Instructions

## Prerequisites

- Docker Desktop installed and running
- **Windows users:** PowerShell 5.1+ (included with Windows 10/11) or [PowerShell 7+](https://github.com/PowerShell/PowerShell)

## Setup Steps

### 1. Clone the Repository

**macOS / Linux:**
```bash
git clone https://github.com/cj2001/odsc_east_2026.git
cd odsc_east_2026
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/cj2001/odsc_east_2026.git
cd odsc_east_2026
```

### 2. Start All Services

**macOS / Linux:**
```bash
docker-compose up -d
```

**Windows (PowerShell):**
```powershell
docker-compose up -d
```

Wait about 15-20 seconds for all services to start.

### 3. Initialize Senzing Database (ONE-TIME ONLY)

⚠️ **Run this once before using the notebooks:**

**macOS / Linux:**
```bash
chmod +x scripts/init_database.sh
./scripts/init_database.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\init_database.ps1
```

> **Note:** If you get an execution policy error, run the following once and then retry:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

You should see:
```
SUCCESS!
Senzing database initialized successfully.
```

### 4. Verify Setup

Open **http://localhost:18888** in your browser and run the `00_setup_check.ipynb` notebook.  (Note that this port is different than the default Jupyter port so as not to conflict with any existing Jupyter installations on your machine.)

All cells should pass with ✅.

### 5. (OPTIONAL) Configure the Senzing MCP Server

If you are using Claude Code, you can connect to the Senzing MCP server for interactive assistance with entity resolution tasks. This requires Node.js 18+ and npm.

From the repo root, run:

**macOS / Linux:**
```bash
python scripts/setup_mcp.py
```

**Windows (PowerShell):**
```powershell
python scripts\setup_mcp.py
```

This will:
- Locate your Node.js and npx binaries (including common version-manager paths like nvm, fnm, and volta)
- Verify that Node.js 18+ is installed
- Generate a `.mcp.json` file in the repo root

If you already have a `.mcp.json` file, the script will prompt you before overwriting it.

## Workshop URLs

| Service | URL |
|---------|-----|
| JupyterLab | http://localhost:18888 |
| Portainer (optional) | http://localhost:9000 |

## Troubleshooting

**Check all containers are running:**
```bash
docker-compose ps
```

All four containers should show "Up" status.

**Stop everything:**
```bash
docker-compose down
```

**Reset everything (deletes all data):**
```bash
docker-compose down -v
```

Then repeat steps 2-3.

### Windows-Specific Issues

**PowerShell execution policy error:**
If you see "running scripts is disabled on this system", run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Docker Desktop not responding:**
Make sure Docker Desktop is running and that you have enabled the WSL 2 backend (Settings > General > "Use the WSL 2 based engine"). Restart Docker Desktop if `docker ps` returns an error.

## Notes

- No password required for JupyterLab
- Network name is based on directory: `<directory-name>_erkg-network`
