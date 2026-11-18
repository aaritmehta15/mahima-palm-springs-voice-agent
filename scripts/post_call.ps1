<#
.SYNOPSIS
  Closes the loop after a call: fetch the result, act on what the customer asked for, and check the transcript.

.DESCRIPTION
  1. GET https://api.bolna.ai/executions/{id}; credentials inside the payload (tool headers) are removed
     before anything is saved. Output goes to local/calls/ (gitignored).
  2. Reads the agent's post-call extractions (category "Lead Outcome"):
       Opt-out        true            -> phone number added to the do-not-call list; place_call.ps1 will refuse it
       Callback Day   today / tomorrow / day_after_tomorrow
       Callback Time  morning / afternoon / evening / same_time / not_specified
                                      -> a follow-up call is scheduled (after you confirm) with call_reason=callback
  3. Runs tests/check_transcript.py on the transcript (automatic critical-failure checks).

.EXAMPLE
  .\scripts\post_call.ps1 -ExecutionId 6b56f180-c232-440f-ba19-218d16f01316
#>
param(
  [Parameter(Mandatory = $true)] [string] $ExecutionId,
  [string] $DncFile = "",
  [switch] $NoSchedule
)
# Windows PowerShell 5.1 does not set $PSScriptRoot inside param defaults, so resolve it here
$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $DncFile) { $DncFile = Join-Path $here "..\local\do_not_call.txt" }

$root = Join-Path $here ".."
$outDir = Join-Path $root "local\calls"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$apiKey = $env:BOLNA_API_KEY
if (-not $apiKey) {
  $secure = Read-Host "Bolna API key (input hidden)" -AsSecureString
  $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
  $env:BOLNA_API_KEY = $apiKey   # kept only for this PowerShell session, so a scheduled callback needs no re-entry
}

# Windows PowerShell 5.1 decodes responses without a charset as Latin-1, which garbles Devanagari.
# Read the raw bytes and decode them as UTF-8 explicitly; also print UTF-8 to the console.
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$resp = Invoke-WebRequest -UseBasicParsing -Uri "https://api.bolna.ai/executions/$ExecutionId" -Headers @{ Authorization = "Bearer $apiKey" }
$exec = [Text.Encoding]::UTF8.GetString($resp.RawContentStream.ToArray()) | ConvertFrom-Json

# 1. Remove credentials before saving (tool configs carry the Cal.com key in their headers)
if ($exec.usage_breakdown -and $exec.usage_breakdown.api_tools) { $exec.usage_breakdown.PSObject.Properties.Remove("api_tools") }
$exec | ConvertTo-Json -Depth 30 | Out-File -Encoding utf8 (Join-Path $outDir "$ExecutionId.json")
$transcriptPath = Join-Path $outDir "$ExecutionId.txt"
$exec.transcript | Out-File -Encoding utf8 $transcriptPath

$cost = if ($exec.total_cost) { "{0:N3}" -f ($exec.total_cost / 100) } else { "?" }
Write-Host ""
Write-Host "=== $ExecutionId ===" -ForegroundColor Cyan
Write-Host ("status: {0} | ended: {1} | duration: {2}s | cost: `${3}" -f $exec.status, $exec.termination_reason, $exec.conversation_duration, $cost)
Write-Host ""
Write-Host $exec.transcript

# 2. Find a disposition anywhere inside extracted_data by its name
function Find-Disposition($node, [string]$name) {
  if ($null -eq $node -or $node -is [string] -or $node -is [ValueType]) { return $null }
  foreach ($p in $node.PSObject.Properties) {
    if ($p.Name -ieq $name) {
      $v = $p.Value
      if ($v -is [string]) { return $v }
      if ($v.objective) { return [string]$v.objective }
      if ($v.subjective) { return [string]$v.subjective }
      return [string]$v
    }
    $found = Find-Disposition $p.Value $name
    if ($found) { return $found }
  }
  return $null
}

$phone   = $exec.telephony_data.to_number
$optOut  = Find-Disposition $exec.extracted_data "Opt-out"
$cbDay   = Find-Disposition $exec.extracted_data "Callback Day"
$cbTime  = Find-Disposition $exec.extracted_data "Callback Time"
$visit   = Find-Disposition $exec.extracted_data "Site Visit Status"
$outcome = Find-Disposition $exec.extracted_data "Call Outcome"
Write-Host ""
Write-Host "Extractions -> outcome: $outcome | visit: $visit | opt-out: $optOut | callback: $cbDay / $cbTime" -ForegroundColor Yellow

# 3a. Opt-out -> do-not-call list
if ($optOut -match "^(true|yes)$") {
  $existing = @(); if (Test-Path $DncFile) { $existing = Get-Content $DncFile }
  if ($existing -notcontains $phone) { Add-Content -Path $DncFile -Value $phone }
  Write-Host "OPT-OUT: $phone added to the do-not-call list. place_call.ps1 will refuse this number." -ForegroundColor Red
}
# 3b. Senior expert callback = a HUMAN handover (prompt S7 Branch D). Log it for the sales team; never auto-schedule an AI call.
elseif ($exec.transcript -match ('senior expert ' + [char]0x0906 + [char]0x092A + [char]0x0915 + [char]0x094B + ' ' + [char]0x0915 + [char]0x0932)) {   # 'senior expert aapko kal' (S7 Branch D), ASCII-only for PowerShell 5.1
  $handoff = Join-Path $root "local\expert_callbacks.tsv"
  Add-Content -Path $handoff -Value ("{0}`t{1}`t{2}`ttomorrow 10:00-17:00 IST" -f (Get-Date -Format s), $ExecutionId, $phone)
  Write-Host "SENIOR EXPERT CALLBACK: human handover logged to local\expert_callbacks.tsv (tomorrow 10 AM to 5 PM). No AI call scheduled." -ForegroundColor Yellow
}
# 3c. Customer asked Neha to call back later -> schedule a follow-up AI call
elseif ($cbDay -and $cbDay -notmatch "^(none|not_discussed)$" -and -not $NoSchedule) {
  $ist = [TimeZoneInfo]::FindSystemTimeZoneById("India Standard Time")
  $callUtc = [DateTime]::SpecifyKind([DateTime]::Parse($exec.initiated_at, [Globalization.CultureInfo]::InvariantCulture), [DateTimeKind]::Utc)
  $callIst = [TimeZoneInfo]::ConvertTimeFromUtc($callUtc, $ist)
  $offset = switch ($cbDay) { "today" {0} "tomorrow" {1} "day_after_tomorrow" {2} default {1} }
  $hour   = switch ($cbTime) { "morning" {11} "afternoon" {14} "evening" {17} "same_time" {$callIst.Hour} default {11} }
  $minute = if ($cbTime -eq "same_time") { $callIst.Minute } else { 0 }
  $when = $callIst.Date.AddDays($offset).AddHours($hour).AddMinutes($minute)
  $iso = $when.ToString("yyyy-MM-ddTHH:mm:00", [Globalization.CultureInfo]::InvariantCulture) + "+05:30"
  Write-Host "CALLBACK requested: $cbDay / $cbTime -> $iso IST"
  $answer = Read-Host "Schedule this callback call now? (y/n)"
  if ($answer -eq "y") {
    $name  = $exec.context_details.recipient_data.customer_name
    $email = $exec.context_details.recipient_data.customer_email
    & (Join-Path $here "place_call.ps1") -AgentId $exec.agent_id -Phone $phone -Name $name -Email $email `
        -ScheduleAt $iso -CallReason "callback" -DncFile $DncFile -Label "auto-callback for $ExecutionId"
  } else { Write-Host "Not scheduled." }
}

# 4. Automatic transcript checks
Write-Host ""
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) { & python -I (Join-Path $root "tests\check_transcript.py") $transcriptPath }
else { Write-Host "Python not found; skipped tests\check_transcript.py" }
