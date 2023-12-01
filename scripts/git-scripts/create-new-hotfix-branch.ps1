param ($branchName)
if (-NOT $branchName) {
    # Create branch based on current development version
    $release =Get-Content "$PSScriptRoot\..\..\version.txt" -First 1
    if (-NOT $release) {
        Write-Error "Failed to get version"
        Exit 1
    }
    $branchName = "m/hotfix/$release"+"x" 
} 

# Check git status and stash if needed
$status = git status -s
$status
$isEmpty = [string]::IsNullOrEmpty($status)
if ($isEmpty) {
    "Clean"
}
else {
    "Not clean, stashing changes"
    git stash 
}

# Create the new branch from the tip of the master branch
git checkout master
git pull
git checkout -b $branchName


