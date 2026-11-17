<#
.SYNOPSIS
  Places one outbound call from the Mahima Palm Springs Bolna agent for one lead.

.DESCRIPTION
  This is the integration point a Facebook lead form would use: when a lead arrives,
  call POST https://api.bolna.ai/call with the lead's details as user_data.

  user_data sent:
    customer_name   - from the lead form; the agent greets the lead by this name
    customer_email  - from the lead form; read back for confirmation instead of being
                      spelled over the phone (voice-spelled emails were misheard in testing)
    upcoming_dates  - the next 7 days as "Weekday=YYYY-MM-DD" pairs, computed here in IST.
                      The model looks dates up instead of computing weekdays, which it
                      got wrong in live testing (defect D7).
    timezone        - Asia/Kolkata

  The Bolna API key is typed at run time and never written to disk.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\place_call.ps1 `
    -AgentId "<agent uuid>" -Phone "+91XXXXXXXXXX" -Name "Rahul" -Email "rahul@example.com"
#>
param(
  [Parameter(Mandatory = $true)] [string] $AgentId,
  [Parameter(Mandatory = $true)] [string] $Phone,
  [Parameter(Mandatory = $true)] [string] $Name,
  [string] $Email = ""
)

# Today's date in India Standard Time, independent of the machine's timezone.
$ist   = [TimeZoneInfo]::FindSystemTimeZoneById("India Standard Time")
$today = [TimeZoneInfo]::ConvertTimeFromUtc([DateTime]::UtcNow, $ist).Date
$inv   = [Globalization.CultureInfo]::InvariantCulture

$upcoming = (1..7 | ForEach-Object {
  $d = $today.AddDays($_)
  "{0}={1}" -f $d.ToString("dddd", $inv), $d.ToString("yyyy-MM-dd", $inv)
}) -join ", "

$secure = Read-Host "Bolna API key (input hidden)" -AsSecureString
$apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

$body = @{
  agent_id               = $AgentId
  recipient_phone_number = $Phone
  user_data              = @{
    customer_name  = $Name
    customer_email = $Email
    upcoming_dates = $upcoming
    timezone       = "Asia/Kolkata"
  }
} | ConvertTo-Json -Depth 5

Write-Host "Upcoming dates sent: $upcoming"
$response = Invoke-RestMethod -Method Post -Uri "https://api.bolna.ai/call" `
  -Headers @{ Authorization = "Bearer $apiKey"; "Content-Type" = "application/json" } `
  -Body ([Text.Encoding]::UTF8.GetBytes($body))
$apiKey = $null

Write-Host "Queued:" ($response | ConvertTo-Json -Compress)
Write-Host "Keep the execution_id: it is the key for the transcript, recording and cost."
