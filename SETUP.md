# Workshop Setup Instructions

# Workshop Setup

## Prerequisites

- Docker Desktop installed and running
- At least 8GB RAM available
- 10GB free disk space

## Setup Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd odsc_east_2026
```

### 2. Start All Services
```bash
docker-compose up -d
```

Wait about 15-20 seconds for all services to start.

### 3. Initialize Senzing Database (ONE-TIME ONLY)

⚠️ **Run this once before using the notebooks:**
```bash
chmod +x scripts/init_database.sh
./scripts/init_database.sh
```

You should see:
```
✅ SUCCESS!
Senzing database initialized successfully.
```

### 4. Verify Setup

Open **http://localhost:8888** in your browser and run the `00_setup_check.ipynb` notebook.

All cells should pass with ✅.

## Workshop URLs

| Service | URL |
|---------|-----|
| JupyterLab | http://localhost:8888 |
| Portainer (optional) | http://localhost:9000 |

## Troubleshooting

**If Senzing container keeps restarting:**
```bash
# Check if initialization is needed
docker-compose logs senzing | grep "sys_vars"

# If you see "relation sys_vars does not exist", run Step 3 again
```

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

## Notes

- No password required for JupyterLab
- Network name is based on directory: `<directory-name>_erkg-network`
- If you renamed the directory, update the network name in Step 3

---

**Ready?** Open http://localhost:8888 and start with `00_setup_check.ipynb`! 🚀