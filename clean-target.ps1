<#
.SYNOPSIS
Safely deletes common build artifacts, IDE directories, and temporary files
from a repository containing multiple projects.

.DESCRIPTION
This script recursively searches the current directory for specified folders
(like 'target', 'build', 'classes', '.idea') and files (like '*.iml')
that are typically ignored in a .gitignore file, and deletes them.

It uses the -WhatIf parameter by default to perform a dry run. To actually
delete files, you must run the script with the -Execute parameter.

.PARAMETER Execute
A switch parameter that must be present to enable actual deletion.
If omitted, the script performs a dry run using -WhatIf.

.EXAMPLE
# 1. Dry Run (Recommended first step)
# This will show you exactly what the script intends to delete.
.\Cleanup-Repo.ps1

# 2. Execute Deletion
# Only run this once you have reviewed the dry run output and are sure.
.\Cleanup-Repo.ps1 -Execute
#>
param(
    [switch]$Execute
)

# --- Configuration ---
# Folders to delete (These will be deleted recursively)
$FoldersToDelete = @(
    "target",        # Maven build directory
    "build",         # Gradle/general build directory
    "out",           # IntelliJ/general output directory
    "classes",       # Compiled classes directory
    "dist",          # Distribution directory
    ".idea",         # IntelliJ project configuration folder
    ".gradle",       # Gradle wrapper files
    "bin"            # Common binary/output directory
)

# Files to delete (These will be searched for and deleted)
$FilesToDelete = @(
    "*.iml",         # IntelliJ module files
    "*.ipr",         # IntelliJ project files
    "*.iws",         # IntelliJ workspace files
    "*.log",         # General log files
    "*.bak"          # Backup files
)

# --- Execution Logic ---

$CurrentPath = (Get-Location).Path
$DeleteFlag = if ($Execute) { "" } else { "-WhatIf" }

Write-Host "--- Repository Cleanup Utility ---" -ForegroundColor Cyan
Write-Host "Starting cleanup in: $CurrentPath" -ForegroundColor Yellow

if (-not $Execute) {
    Write-Host "Executing in DRY RUN mode. No files will be deleted." -ForegroundColor Green
    Write-Host "To execute deletion, run the script with the '-Execute' parameter." -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "WARNING: Executing LIVE DELETION! Files will be permanently removed." -ForegroundColor Red
    Write-Host "Press Enter to continue or Ctrl+C to abort." -ForegroundColor Red
    $null = Read-Host
}

# 1. Search and delete folders
Write-Host "Searching for and removing unwanted folders..." -ForegroundColor Yellow
foreach ($folder in $FoldersToDelete) {
    Write-Host "Targeting folder: $folder" -ForegroundColor DarkYellow
    # Find all instances of the folder recursively, excluding hidden system files for safety
    Get-ChildItem -Path $CurrentPath -Filter $folder -Directory -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        # Use Invoke-Expression to conditionally apply -WhatIf
        Invoke-Expression "Remove-Item -Path '$($_.FullName)' -Recurse -Force $DeleteFlag"
    }
}

# 2. Search and delete specific files
Write-Host ""
Write-Host "Searching for and removing unwanted files..." -ForegroundColor Yellow
foreach ($filePattern in $FilesToDelete) {
    Write-Host "Targeting file pattern: $filePattern" -ForegroundColor DarkYellow
    # Find all files matching the pattern recursively
    Get-ChildItem -Path $CurrentPath -Include $filePattern -File -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        # Use Invoke-Expression to conditionally apply -WhatIf
        Invoke-Expression "Remove-Item -Path '$($_.FullName)' -Force $DeleteFlag"
    }
}

Write-Host ""
Write-Host "Cleanup process complete." -ForegroundColor Cyan
if (-not $Execute) {
    Write-Host "Please review the list above. If it looks correct, run with '-Execute' to delete the files." -ForegroundColor Green
}