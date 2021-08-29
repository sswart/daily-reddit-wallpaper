try{
    $Job = Get-ScheduledJob -Name "Download-Reddit-Wallpaper"
    if (-not ($null -eq $Job)){
        Disable-ScheduledJob $Job
        Unregister-ScheduledJob $Job
    }
}
catch {}