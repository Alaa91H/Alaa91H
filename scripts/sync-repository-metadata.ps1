#requires -Version 7.0
<#
.SYNOPSIS
  Synchronize GitHub repository descriptions and topics for Alaa91H.

.DESCRIPTION
  Keeps the public-facing About metadata consistent with the actual projects.
  Requires GitHub CLI (gh) authenticated with permission to edit the repositories.

.EXAMPLE
  ./scripts/sync-repository-metadata.ps1 -DryRun

.EXAMPLE
  ./scripts/sync-repository-metadata.ps1
#>

[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) was not found. Install it from https://cli.github.com/ and authenticate with 'gh auth login'."
}

if (-not $DryRun) {
    gh auth status *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub CLI is not authenticated. Run 'gh auth login' first."
    }
}

$repositories = [ordered]@{
    "Alaa91H/Alaa91H" = @{
        Description = "Android, AOSP, automation, systems, and open-source projects by Alaa."
        Topics = @("github-profile", "android-developer", "aosp", "automation", "open-source")
    }
    "Alaa91H/BlackList" = @{
        Description = "Privacy-first Android call blocker with offline screening, local rules, temporary blocks, and no cloud or trackers."
        Topics = @("android", "kotlin", "jetpack-compose", "call-blocker", "call-screening", "privacy", "offline", "material3")
    }
    "Alaa91H/CLONIX" = @{
        Description = "Android app cloning for custom ROMs and rooted devices using isolated users/profiles, shared APKs, and separate app data."
        Topics = @("android", "aosp", "app-cloner", "android-multiuser", "root", "kernelsu", "magisk", "custom-rom")
    }
    "Alaa91H/GeneralsZH" = @{
        Description = "Native Command & Conquer: Generals - Zero Hour port for Android and Apple platforms with touch controls, multiple renderers, and multiplayer."
        Topics = @("command-and-conquer", "generals-zero-hour", "android", "cpp", "vulkan", "opengl-es", "multiplayer", "game-port")
    }
    "Alaa91H/islamic-unified-bot" = @{
        Description = "Telegram bot for Adhkar, Quran voice streaming, prayer times, and automated Azan notifications."
        Topics = @("telegram-bot", "python", "quran", "prayer-times", "adhan", "adhkar", "pyrogram", "automation")
    }
    "Alaa91H/Muslim" = @{
        Description = "Privacy-first, local-first Android companion for prayer times, Quran and Hadith study, Islamic learning, and worship utilities."
        Topics = @("android", "kotlin", "jetpack-compose", "quran", "prayer-times", "hadith", "islamic-app", "privacy", "wear-os")
    }
    "Alaa91H/NexaFlow" = @{
        Description = "Context-aware Android automation engine with triggers, constraints, workflows, and capability-adaptive execution via Android APIs, Shizuku, or root."
        Topics = @("android", "kotlin", "automation", "jetpack-compose", "shizuku", "root", "workflows", "aosp", "material3")
    }
    "Alaa91H/NexaSense" = @{
        Description = "Open-source AOSP sensor suite with compass, level, Qibla direction, sensor discovery, diagnostics, and true-north support."
        Topics = @("android", "kotlin", "aosp", "compass", "sensors", "qibla", "jetpack-compose", "material3", "geomagnetic-model")
    }
    "Alaa91H/NOVADownloadManager" = @{
        Description = "Open-source desktop download manager powered by Tauri, Rust, libcurl multi, yt-dlp and FFmpeg, with a Manifest V3 browser companion."
        Topics = @("download-manager", "tauri", "rust", "typescript", "libcurl", "yt-dlp", "ffmpeg", "browser-extension", "windows", "manifest-v3")
    }
    "Alaa91H/O2AutoReply" = @{
        Description = "Android utility that automatically replies to O2 Unlimited on Demand renewal SMS messages."
        Topics = @("android", "sms", "automation", "o2", "telephony")
    }
    "Alaa91H/O2CallForwarding" = @{
        Description = "Android utility for managing O2 Germany and GSM call-forwarding settings through MMI/USSD codes with a Material 3 interface."
        Topics = @("android", "kotlin", "call-forwarding", "ussd", "mmi", "telephony", "o2", "material3")
    }
    "Alaa91H/opencode-bridge" = @{
        Description = "Arabic Telegram control plane for a locally hosted OpenCode development agent with task queues, guarded Git/GitHub workflows, and adaptive resource control."
        Topics = @("opencode", "telegram-bot", "python", "ai-agent", "github-automation", "systemd", "task-queue", "devops", "automation")
    }
    "Alaa91H/packages_apps_Evolver" = @{
        Description = "Evolution X Evolver fork for custom-ROM settings, feature development, localization, and Android system customization."
        Topics = @("evolution-x", "evolver", "android", "aosp", "custom-rom", "kotlin", "settings")
    }
    "Alaa91H/frameworks_base" = @{
        Description = "AOSP frameworks/base fork for custom-ROM framework changes and system-level Android feature development."
        Topics = @("aosp", "android-framework", "android", "custom-rom", "evolution-x", "framework")
    }
    "Alaa91H/QuranLiveStream" = @{
        Description = "Adaptive 24/7 Quran broadcasting engine with synchronized recitation, Tafsir, prayer times, weather, and native multi-platform layouts."
        Topics = @("quran", "live-streaming", "ffmpeg", "nodejs", "prayer-times", "tafsir", "rtmp", "youtube", "tiktok", "automation")
    }
    "Alaa91H/SPREVA" = @{
        Description = "Offline-first Android app for learning German from Pre-A1 to C1 with first-class Arabic support, structured lessons, and audio practice."
        Topics = @("android", "kotlin", "german-learning", "language-learning", "arabic", "jetpack-compose", "offline-first", "education", "a1", "c1")
    }
    "Alaa91H/Universal_Debloat_Editable_Hide_List_For_Android" = @{
        Description = "Systemless KernelSU/Magisk debloat module with editable package lists, reversible hide/disable modes, recovery installer, and optional web UI."
        Topics = @("android", "debloat", "kernelsu", "magisk", "root", "module", "systemless", "custom-rom", "recovery", "shell")
    }
}

function Invoke-GhCommand {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $display = "gh " + ($Arguments -join " ")

    if ($DryRun) {
        Write-Host "[DRY RUN] $display"
        return
    }

    & gh @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $display"
    }
}

foreach ($entry in $repositories.GetEnumerator()) {
    $repo = $entry.Key
    $meta = $entry.Value

    Write-Host ""
    Write-Host "==> $repo"

    Invoke-GhCommand -Arguments @(
        "repo", "edit", $repo,
        "--description", $meta.Description
    )

    if ($DryRun) {
        Write-Host "[DRY RUN] Replace topics: $($meta.Topics -join ', ')"
        continue
    }

    $payload = @{ names = @($meta.Topics) } | ConvertTo-Json -Compress
    $apiArgs = @(
        "api",
        "--method", "PUT",
        "-H", "Accept: application/vnd.github+json",
        "-H", "X-GitHub-Api-Version: 2022-11-28",
        "repos/$repo/topics",
        "--input", "-"
    )

    $payload | & gh @apiArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to update topics for $repo"
    }
}

Write-Host ""

if ($DryRun) {
    Write-Host "Dry run complete. No repository metadata was changed."
} else {
    Write-Host "Repository descriptions and topics synchronized successfully."
}
