# Workshop Setup Instructions

## Prerequisites
- Docker Desktop installed ([download here](https://docs.docker.com/get-docker/))
- At least 8GB RAM available
- 10GB free disk space

## Setup Steps

### 1. Clone and Prepare
```bash
git clone <your-repo-url>
cd odsc_east_2026
mkdir -p notebooks data
```

### 2. Start All Supporting Services
```bash
docker-compose up -d portainer postgres
```

Wait about 10 seconds for PostgreSQL to be ready.

### 3. Set Up Portainer (First Time Only)

Open your browser to: **http://localhost:9000**

1. Create an admin account (username: admin, password: your choice)
2. Select "Get Started" to connect to your local Docker environment
3. Click on "local" to see your containers

**💡 TIP**: Keep Portainer open in a browser tab during the workshop to monitor containers!

### 4. Initialize Senzing Database (ONE-TIME ONLY)

This step sets up the Senzing schema and configuration in PostgreSQL:
```bash
docker run --rm --network odsc_east_2026_default \
  --env SENZING_TOOLS_COMMAND=init-database \
  --env SENZING_TOOLS_DATABASE_URL="postgresql://postgres:workshop@postgres:5432/erkg?sslmode=disable" \
  senzing/senzing-tools
```

You should see output ending with "Sent SQL in ... to database".

**⚠️ IMPORTANT**: Only run this initialization command ONCE. Running it multiple times may cause issues.

### 5. Start Remaining Services
```bash
docker-compose up -d
```

### 6. Verify Services in Portainer

In Portainer:
1. Click on "Containers" in the left sidebar
2. You should see 4 running containers:
   - `erkg_portainer` (green)
   - `erkg_postgres` (green)
   - `erkg_senzing` (green)
   - `erkg_jupyter` (green)

### 7. Open JupyterLab

Open your browser to: **http://localhost:8888**

(No password required)

## Workshop URLs

Keep these tabs open during the workshop:

| Service | URL | Purpose |
|---------|-----|---------|
| **Portainer** | http://localhost:9000 | Monitor containers, view logs |
| **JupyterLab** | http://localhost:8888 | Run workshop notebooks |
| **PostgreSQL** | localhost:5436 | Database (for external tools like pgAdmin/DBeaver) |

**Note:** PostgreSQL is exposed on port 5436 (not the default 5432) to avoid conflicts with local PostgreSQL installations. Internal Docker connections still use port 5432.

## Using Portainer During the Workshop

### View Container Logs
1. Click "Containers" in left sidebar
2. Click on any container name (e.g., `erkg_senzing`)
3. Click "Logs" icon
4. Toggle "Auto-refresh" to see live logs

### Check Container Health
1. Click "Containers"
2. Look at the "Status" column
3. Green "running" = healthy
4. Red "exited" = problem (click to see logs)

### Restart a Container
1. Click "Containers"
2. Check the box next to the container
3. Click "Restart" at the top

### View Resource Usage
1. Click "Containers"
2. See CPU and Memory usage in real-time

