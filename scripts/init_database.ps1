# Auto-detect the Docker network based on directory name
$DirName = Split-Path -Leaf (Get-Location)
$NetworkName = "${DirName}_erkg-network"

Write-Host "============================================"
Write-Host "Initializing Senzing Database"
Write-Host "============================================"
Write-Host "Directory: $DirName"
Write-Host "Network: $NetworkName"
Write-Host ""

# Check if network exists
$networkCheck = docker network inspect $NetworkName 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Network '$NetworkName' not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure containers are running:"
    Write-Host "  docker-compose up -d"
    Write-Host ""
    exit 1
}

# Check if database is already initialized
Write-Host "Checking if database is already initialized..."
$checkResult = docker run --rm --network $NetworkName postgres:15 psql "postgresql://postgres:workshop@postgres:5432/erkg" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='sys_vars';" 2>$null
if ($LASTEXITCODE -ne 0) { $checkResult = "0" }

if ($checkResult.Trim() -eq "1") {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "ALREADY INITIALIZED"
    Write-Host "============================================"
    Write-Host "Senzing database is already set up."
    Write-Host "No action needed."
    Write-Host ""
    Write-Host "If you want to reset and start fresh:"
    Write-Host "  docker-compose down -v"
    Write-Host "  docker-compose up -d"
    Write-Host "  .\scripts\init_database.ps1"
    Write-Host ""
    exit 0
}

# Run initialization
Write-Host "Database not initialized. Running setup..."
Write-Host ""

$engineConfig = '{"PIPELINE":{"CONFIGPATH":"/etc/opt/senzing","RESOURCEPATH":"/opt/senzing/er/resources","SUPPORTPATH":"/opt/senzing/data"},"SQL":{"CONNECTION":"postgresql://postgres:workshop@postgres:5432:erkg?sslmode=disable"}}'

docker run --rm --network $NetworkName --env "SENZING_ENGINE_CONFIGURATION_JSON=$engineConfig" senzing/init-database --install-senzing-er-configuration

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "============================================"
    Write-Host "Senzing database initialized successfully."
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Open http://localhost:8888"
    Write-Host "2. Run notebooks/00_setup_check.ipynb"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "============================================"
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "============================================"
    Write-Host "Initialization failed. Check errors above."
    Write-Host ""
    exit 1
}
