try {
    if ((Get-Service CloudflareWARP).Status -eq 'Running') {
        Stop-Service CloudflareWARP -ErrorAction Stop
        Write-Host "CloudflareWARP Service stopped." -ForegroundColor Green
    } else {
        Start-Service CloudflareWARP -ErrorAction Stop
        Write-Host "CloudflareWARP Service started." -ForegroundColor Green
    }
}
catch {
    Write-Host "CloudflareWARP Service error. Run the script as an administrator, maybe?!" -ForegroundColor Red
}