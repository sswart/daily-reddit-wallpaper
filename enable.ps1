# copy set-background-image to specified folder
# setup scheduledJob
Write-Output "This script registers a background job that will download an image from a random configured subreddit and set it as a background image"
$Result = Read-Host "Do you wish to continue? (y/n)"

$Path = Read-Host "Enter path for config/images (leave empty for current path):"

if ([string]::IsNullOrEmpty($Path)){
    $Path = $PSScriptRoot
    echo "Using ${Path}"
}
while (-not (Test-Path -Path $Path)){
    $Path = Read-Host "Entered path invalid. Enter directory for config/images (leave empty for current path):"
}

if ($Result.ToLower() -eq "y"){

    try{
        $Job = Get-ScheduledJob -Name "Download-Reddit-Wallpaper"
        if (-not ($null -eq $Job)){
            Disable-ScheduledJob $Job
            Unregister-ScheduledJob $Job
        }
    }
    catch {}

    $Trigger = New-JobTrigger -Daily -At "14:00"
    $Job = Register-ScheduledJob -Name "Download-Reddit-Wallpaper" -FilePath "${PSScriptRoot}\set-background-image.ps1" -ArgumentList $Path -Trigger $Trigger
    Enable-ScheduledJob $Job
}
