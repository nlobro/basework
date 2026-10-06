#Requires -Version 5.1
param([string]$Message = 'Работа на занятии')
$ErrorActionPreference = 'Stop'
try {
    Push-Location (Split-Path -Parent $PSScriptRoot)
    try {
        git status
        if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git status.' }
        $branch = git branch --show-current
        if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { throw 'Switch to main before finishing class.' }
        git add .
        if ($LASTEXITCODE -ne 0) { throw 'Git add failed. Database was not removed.' }
        git diff --cached --quiet
        $diffCode = $LASTEXITCODE
        if ($diffCode -eq 1) {
            git commit -m $Message
            if ($LASTEXITCODE -ne 0) { throw 'Commit failed. Check repository user.name and user.email. Database was not removed.' }
        } elseif ($diffCode -ne 0) { throw 'Cannot inspect staged changes. Database was not removed.' }
        $remaining = git status --porcelain
        if ($LASTEXITCODE -ne 0 -or $remaining) { throw 'Uncommitted changes remain. Database was not removed.' }
        git push origin main
        if ($LASTEXITCODE -ne 0) { throw 'Push failed. Preserve the database and local folder; resolve Git access or remote changes, then retry.' }
        Write-Host 'Push succeeded. Removing the project database volume; SQL work must already be saved in files.'
        docker compose down -v
        if ($LASTEXITCODE -ne 0) { throw 'Push succeeded, but Docker cleanup failed. Check Docker Desktop and retry cleanup.' }
        Write-Host @'
Before leaving:
- Verify the latest commit on https://github.com/nlobro/basework.
- Sign out of GitHub in VS Code, the browser and Git Credential Manager.
- Remove the local repository folder from the shared PC after verification.
- Remove your DBeaver connection if needed.
'@
    } finally { Pop-Location }
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
