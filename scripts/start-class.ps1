#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
try {
    Push-Location (Split-Path -Parent $PSScriptRoot)
    try {
        git status
        if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git status.' }
        $branch = git branch --show-current
        if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { throw 'Switch to main before starting class.' }
        $changes = git status --porcelain
        if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git changes.' }
        if ($changes) { throw 'Local changes exist. Commit or preserve them before pulling; no files were deleted.' }
        git pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw 'Git pull failed. Resolve the problem before starting Docker.' }
        docker compose up -d
        if ($LASTEXITCODE -ne 0) { throw 'Docker startup failed. Check Docker Desktop, port 5432 and container postgres-db.' }
        docker ps
        if ($LASTEXITCODE -ne 0) { throw 'Cannot list Docker containers.' }
        Write-Host @'
DBeaver connection:
Host:     127.0.0.1
Port:     5432
Database: postgres
Username: postgres
Password: postgres
PostgreSQL may need a few seconds before the first connection.
'@
    } finally { Pop-Location }
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
