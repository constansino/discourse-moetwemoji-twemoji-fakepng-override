\
<#
Copy your existing "fakepng" directory (files already named correctly, e.g. yum.png) into the plugin repo's twemoji/ folder.

Example:
  $src = "C:\Users\1\love\moetwemoji72x72fakepng(avif)"
  .\scripts\prepare-fakepng.ps1 -Source $src

This DOES NOT rename files; it copies *.png as-is.
#>

param(
  [Parameter(Mandatory=$true)][string]$Source
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$dst = Join-Path $repoRoot "twemoji"

New-Item -ItemType Directory -Force -Path $dst | Out-Null

Get-ChildItem -Path $Source -Filter *.png -File | ForEach-Object {
  Copy-Item -Force $_.FullName (Join-Path $dst $_.Name)
}

$cnt = (Get-ChildItem -Path $dst -Filter *.png -File).Count
Write-Host "Done. Copied $cnt png files into $dst"
