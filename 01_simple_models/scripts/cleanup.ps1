# Cleanup Script for OpenModelica Simulation Artifacts
# Run this after simulations to clean up temporary files

Write-Host ""
Write-Host "Cleaning up OpenModelica simulation artifacts..." -ForegroundColor Yellow
Write-Host ""

# Count files before
$artifactFiles = Get-ChildItem -Filter "CCGT_Complete_Simple*" -ErrorAction SilentlyContinue
$before = $artifactFiles.Count

if ($before -eq 0) {
    Write-Host "No simulation artifacts found. Already clean!" -ForegroundColor Green
    exit
}

Write-Host "Found $before files to process..." -ForegroundColor White
Write-Host ""

# Move result file to results folder first
$matFiles = Get-ChildItem -Filter "*_res.mat" -ErrorAction SilentlyContinue
if ($matFiles.Count -gt 0) {
    Write-Host "Moving result files to ../results/ ..." -ForegroundColor Cyan
    foreach ($matFile in $matFiles) {
        Move-Item $matFile.FullName -Destination "../results/" -Force
        Write-Host "  Moved: $($matFile.Name)" -ForegroundColor Green
    }
    Write-Host ""
}

# Delete all other compilation artifacts
Write-Host "Deleting compilation artifacts..." -ForegroundColor Cyan

$patterns = @("*.exe", "*.c", "*.o", "*.h", "*.makefile", "*.bat", "*.log", "*.libs", "*.json", "*.xml")

foreach ($pattern in $patterns) {
    $files = Get-ChildItem -Filter "CCGT_Complete_Simple$pattern" -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
    }
}

# Count remaining
$after = (Get-ChildItem -Filter "CCGT_Complete_Simple*" -ErrorAction SilentlyContinue).Count

Write-Host ""
Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host "  Removed: $($before - $after) files" -ForegroundColor White

if ($after -gt 0) {
    Write-Host "  Remaining: $after files" -ForegroundColor Yellow
}

Write-Host ""
