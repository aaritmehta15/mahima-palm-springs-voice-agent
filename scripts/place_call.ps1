<#
.SYNOPSIS
  Places (or schedules) one outbound call from the Mahima Palm Springs Bolna agent for one lead.

.DESCRIPTION
  This is the integration point a Facebook lead form would use: POST https://api.bolna.ai/call
  with the lead's details as user_data.

  Safeguards
    - Do-not-call list: if the number is in the DNC file (filled automatically by post_call.ps1
      when a customer opts out), the call is refused. Opt-outs are honoured in code, not only in the prompt.

  user_data sent
    customer_name   lead form name; the agent greets by this name
    customer_email  lead form email; read back for confirmation (voice-spelled emails were misheard in testing)
    upcoming_dates  next 7 days as "Weekday=YYYY-MM-DD", computed in IST from the call date. The model
                    looks dates up instead of computing weekdays, which failed in live testing (defect D7)
    call_reason     "callback" when this call was requested by the customer on an earlier call
    timezone        Asia/Kolkata

  The Bolna API key is read from $env:BOLNA_API_KEY, or typed at run time. It is never written to disk.

.EXAMPLE
  .\scripts\place_call.ps1 -AgentId <uuid> -Phone +91XXXXXXXXXX -Name Rahul -Email rahul@example.com
.EXAMPLE
  .\scripts\place_call.ps1 -AgentId <uuid> -Phone +91XXXXXXXXXX -Name Rahul -ScheduleAt "2026-11-19T17:00:00+05:30" -CallReason callback
#>
param(
  [Parameter(Mandatory = $true)] [string] $AgentId,
  [Parameter(Mandatory = $true)] [string] $Phone,
  [Parameter(Mandatory = $true)] [string] $Name,
  [string] $Email = "",
  [string] $ScheduleAt = "",          # ISO 8601 with offset, e.g. 2026-11-19T17:00:00+05:30; empty = call now
  [string] $CallReason = "",          # "callback" or empty
  [string] $DncFile = (Join-Path $PSScriptRoot "..\local\do_not_call.txt"),
  [string] $Label = ""                # free-text test label, written to the local call log
)

# 1. Do-not-call check (opt-outs are enforced here, before any call is placed)
if (Test-Path $DncFile) {
  $blocked = Get-Content $DncFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -eq $Phone }
  if ($blocked) {
    Write-Host "REFUSED: $Phone is on the do-not-call list ($DncFile). No call placed." -ForegroundColor Red
    exit 2
  }
}

# 2. Dates in India Standard Time, counted from the day the call will happen
$ist = [TimeZoneInfo]::FindSystemTimeZoneById("India Standard Time")
$inv = [Globalization.CultureInfo]::InvariantCulture
if ($ScheduleAt) {
  $callDay = [TimeZoneInfo]::ConvertTime([DateTimeOffset]::Parse($ScheduleAt, $inv), $ist).Date
} else {
  $callDay = [TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $ist).Date
}
$upcoming = (1..7 | ForEach-Object {
  $d = $callDay.AddDays($_)
  "{0}={1}" -f $d.ToString("dddd", $inv), $d.ToString("yyyy-MM-dd", $inv)
}) -join ", "

# 3. API key (environment variable first, otherwise hidden prompt)
$apiKey = $env:BOLNA_API_KEY
if (-not $apiKey) {
  $secure = Read-Host "Bolna API key (input hidden)" -AsSecureString
  $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

# 4. Request
$payload = @{
  agent_id               = $AgentId
  recipient_phone_number = $Phone
  user_data              = @{
    customer_name  = $Name
    customer_email = $Email
    upcoming_dates = $upcoming
    call_reason    = $CallReason
    timezone       = "Asia/Kolkata"
  }
}
if ($ScheduleAt) { $payload.scheduled_at = $ScheduleAt }
$body = $payload | ConvertTo-Json -Depth 5

Write-Host "upcoming_dates: $upcoming"
if ($ScheduleAt) { Write-Host "Scheduling call for $ScheduleAt (reason: $CallReason)" } else { Write-Host "Calling now..." }

$response = Invoke-RestMethod -Method Post -Uri "https://api.bolna.ai/call" `
  -Headers @{ Authorization = "Bearer $apiKey"; "Content-Type" = "application/json" } `
  -Body ([Text.Encoding]::UTF8.GetBytes($body))
$apiKey = $null

Write-Host "Queued:" ($response | ConvertTo-Json -Compress)

# 5. Local call log (gitignored), so every test call can be traced to its execution_id
$logDir = Join-Path $PSScriptRoot "..\local"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$line = "{0}`t{1}`t{2}`t{3}`t{4}" -f (Get-Date -Format s), $response.execution_id, $Label, $CallReason, $ScheduleAt
Add-Content -Path (Join-Path $logDir "call_log.tsv") -Value $line
Write-Host "Logged. Next: .\scripts\post_call.ps1 -ExecutionId $($response.execution_id)"
