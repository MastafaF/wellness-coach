# notify.ps1 — Wellness Coach Layer 2: Windows toast notification
# Called by Task Scheduler every 60 minutes.
# Runs notify.sh to check interval + pick a tip, then shows a Windows toast.

# ── 1. Find bash executable ──────────────────────────────────────────────────
$bashCandidates = @(
  "C:\Program Files\Git\bin\bash.exe",
  "C:\Program Files (x86)\Git\bin\bash.exe",
  "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)

$bash = $null
foreach ($candidate in $bashCandidates) {
  if (Test-Path $candidate) {
    $bash = $candidate
    break
  }
}

if (-not $bash) {
  # Try PATH
  $bash = (Get-Command bash -ErrorAction SilentlyContinue)?.Source
}

if (-not $bash) {
  exit 1  # No bash found — silent failure
}

# ── 2. Run notify.sh and capture output ──────────────────────────────────────
$notifyScript = "$env:USERPROFILE\.claude\skills\wellness-coach\scripts\notify.sh"
# Convert Windows path to Unix path for bash
$unixScript = $notifyScript -replace '\\', '/' -replace '^([A-Za-z]):', { '/' + $args[0].Groups[1].Value.ToLower() }

try {
  $tipOutput = & $bash -c "bash '$unixScript' 2>/dev/null"
} catch {
  exit 1
}

# Exit if no output (interval guard fired or no tips)
if ([string]::IsNullOrWhiteSpace($tipOutput)) {
  exit 0
}

# Clean up the tip: strip box-drawing characters and leading spaces for toast
$tipLines = $tipOutput -split "`n" | Where-Object {
  $_ -notmatch '╭|╰|╮|╯|│.*Wellness check-in' -and $_.Trim() -ne ''
}
$tipText = ($tipLines | ForEach-Object { $_.Trim() }) -join ' '
$tipText = $tipText.Trim()

if ([string]::IsNullOrWhiteSpace($tipText)) {
  exit 0
}

# ── 3. Show Windows 11 toast notification ────────────────────────────────────
$focusVideo = "https://www.youtube.com/watch?v=bSkzWpcWz-o"

# Load Windows Runtime assemblies
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

# Build toast XML
$toastXml = @"
<toast scenario="reminder">
  <visual>
    <binding template="ToastGeneric">
      <text>Wellness check-in</text>
      <text>$([System.Security.SecurityElement]::Escape($tipText))</text>
    </binding>
  </visual>
  <actions>
    <action content="Open focus video" arguments="$focusVideo" activationType="protocol"/>
    <action content="Dismiss" arguments="dismiss" activationType="system"/>
  </actions>
</toast>
"@

$xmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
$xmlDoc.LoadXml($toastXml)

$appId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
$toastNotifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
$toast = New-Object Windows.UI.Notifications.ToastNotification($xmlDoc)

try {
  $toastNotifier.Show($toast)
} catch {
  # Toast failed silently — non-intrusive by design
}
