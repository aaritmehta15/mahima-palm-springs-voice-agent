<#
.SYNOPSIS
  Cancels a queued or scheduled Bolna call (POST /call/{execution_id}/stop). A call already in progress cannot be stopped.
.EXAMPLE
  .\scripts\stop_call.ps1 -ExecutionId fc3ab121-d0b9-4d61-ac21-3782cb4bbe31
#>
param([Parameter(Mandatory = $true)] [string] $ExecutionId)

$apiKey = $env:BOLNA_API_KEY
if (-not $apiKey) {
  $secure = Read-Host "Bolna API key (input hidden)" -AsSecureString
  $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}
$r = Invoke-RestMethod -Method Post -Uri "https://api.bolna.ai/call/$ExecutionId/stop" -Headers @{ Authorization = "Bearer $apiKey" }
Write-Host "Stop request for ${ExecutionId}:" ($r | ConvertTo-Json -Compress)
