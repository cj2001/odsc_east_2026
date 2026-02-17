# Workshop Setup Instructions

## Prerequisites

- Docker Desktop installed and running

## Setup Steps

### 1. Clone the Repository
```bash
git clone https://github.com/cj2001/odsc_east_2026.git
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
