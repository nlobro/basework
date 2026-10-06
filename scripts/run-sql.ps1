#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)
$ErrorActionPreference = 'Stop'
$previousOutputEncoding = $OutputEncoding
try {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "SQL file does not exist: $Path" }
    $resolvedPath = (Resolve-Path -LiteralPath $Path).ProviderPath
    $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
    $sql = [System.IO.File]::ReadAllText($resolvedPath, $utf8)
    $running = docker inspect --format '{{.State.Running}}' postgres-db 2>$null
    if ($LASTEXITCODE -ne 0 -or $running -ne 'true') { throw 'Container postgres-db is not running. Start the project first.' }
    $OutputEncoding = $utf8
    $sql | docker exec -i postgres-db psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
    if ($LASTEXITCODE -ne 0) { throw 'SQL execution failed. Check PostgreSQL readiness and the SQL error above.' }
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
} finally {
    $OutputEncoding = $previousOutputEncoding
}
