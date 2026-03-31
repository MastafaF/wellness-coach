# notify.ps1 — Wellness Coach Layer 2: Windows toast notification
# Called by Task Scheduler every 60 minutes.
# Runs notify.sh --toast-only to check interval + pick a tip, then shows a Windows toast.

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

# ── 2. Run notify.sh --toast-only and capture tip output ─────────────────────
$notifyScript = "$env:USERPROFILE\.claude\skills\wellness-coach\scripts\notify.sh"
# Convert Windows path to Unix path for bash
$unixScript = $notifyScript -replace '\\', '/' -replace '^([A-Za-z]):', { '/' + $args[0].Groups[1].Value.ToLower() }

try {
  $tipOutput = & $bash -c "bash '$unixScript' --toast-only 2>/dev/null"
} catch {
  exit 1
}

# Exit if no output (interval guard fired or no tips available)
if ([string]::IsNullOrWhiteSpace($tipOutput)) {
  exit 0
}

$tipText = $tipOutput.Trim()

if ([string]::IsNullOrWhiteSpace($tipText)) {
  exit 0
}

# ── 3. Pick a focus video URL dynamically from focus-videos.md ───────────────
$focusVideosFile = Join-Path (Split-Path $PSScriptRoot) "focus-videos.md"
# Read fallback URL from config.sh, or use built-in default
$unixInstallDir = $PSScriptRoot -replace '\\', '/' -replace '^([A-Za-z]):', { '/' + $args[0].Groups[1].Value.ToLower() }
$focusUrl = try { & $bash -c "source '$unixInstallDir/config.sh' && echo `$WELLNESS_FALLBACK_VIDEO" 2>$null } catch { $null }
if ([string]::IsNullOrWhiteSpace($focusUrl)) { $focusUrl = "https://www.youtube.com/watch?v=bSkzWpcWz-o" }

if (Test-Path $focusVideosFile) {
  $lines = Get-Content $focusVideosFile
  $urls = $lines | Where-Object { $_ -match "^https?://" }
  if ($urls.Count -gt 0) {
    $focusUrl = $urls[(Get-Random -Maximum $urls.Count)]
  }
}

# ── 4. Show Windows 11 toast notification ────────────────────────────────────
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
    <action content="Open focus video" arguments="$focusUrl" activationType="protocol"/>
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
