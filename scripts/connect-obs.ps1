<#
Opens an SSH tunnel to studiostreamer's headless-OBS VNC port (if one
isn't already open) and launches RealVNC Viewer against it.

See docs/network/headless-obs-setup.md for how the remote side is set up.
#>

$SshHost = "studiostreamer"
$LocalPort = 5900
$VncViewer = "C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe"

$tunnelActive = Get-NetTCPConnection -LocalPort $LocalPort -State Listen -ErrorAction SilentlyContinue

if (-not $tunnelActive) {
    Write-Host "Opening SSH tunnel to $SshHost (localhost:$LocalPort -> studiostreamer:$LocalPort)..."
    Start-Process -WindowStyle Hidden -FilePath "ssh" -ArgumentList "-N", "-L", "${LocalPort}:localhost:${LocalPort}", $SshHost
    Start-Sleep -Seconds 2
}
else {
    Write-Host "Tunnel already open on localhost:$LocalPort."
}

if (Test-Path $VncViewer) {
    Start-Process -FilePath $VncViewer -ArgumentList "localhost:$LocalPort"
}
else {
    Write-Warning "VNC viewer not found at '$VncViewer'. Connect manually to localhost:$LocalPort."
}
