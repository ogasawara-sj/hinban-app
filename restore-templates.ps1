# 品番取得システム - テンプレート復元ツール
# public\templates\ 配下の2つのExcelテンプレートをGit管理下の正常版に復元する。
# 何度実行しても安全（正常版に戻すだけ）。
$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location -Path $PSScriptRoot

Write-Host '============================================'
Write-Host '  品番取得システム - テンプレート復元ツール'
Write-Host '============================================'
Write-Host ''
Write-Host "フォルダ: $PSScriptRoot"
Write-Host ''

# Gitリポジトリか確認
& git rev-parse --is-inside-work-tree > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host '[エラー] このフォルダはGitリポジトリではないか、Gitが見つかりません。' -ForegroundColor Red
    Write-Host 'C:\hinban-app で実行しているか、Gitがインストールされているか確認してください。' -ForegroundColor Red
    Write-Host ''
    Read-Host 'Enterキーを押すと閉じます'
    exit 1
}

$files = @(
    'public/templates/access-register-template.xlsx',
    'public/templates/offer-list-template.xlsx'
)

Write-Host '復元しています...'
& git checkout -- $files[0] $files[1]
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '[エラー] 復元に失敗しました。上記のGitのメッセージを確認してください。' -ForegroundColor Red
    Write-Host ''
    Read-Host 'Enterキーを押すと閉じます'
    exit 1
}

Write-Host ''
Write-Host '復元が完了しました。ファイルの状態を確認しています...'
Write-Host ''

$allOk = $true
foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot $f))[0..3]
    $hex = ($bytes | ForEach-Object { $_.ToString('x2') }) -join ' '
    if ($hex -eq '50 4b 03 04') {
        Write-Host "  OK: $f  ($hex)" -ForegroundColor Green
    } else {
        Write-Host "  NG: $f  ($hex)" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ''
if ($allOk) {
    Write-Host '両方のテンプレートが正常な状態です。' -ForegroundColor Green
} else {
    Write-Host '一部のテンプレートがまだ異常です。もう一度このツールを実行するか、状況を確認してください。' -ForegroundColor Red
}

Write-Host ''
Write-Host 'アプリの画面を再読み込み（Ctrl+Shift+R）すれば反映されます。'
Write-Host ''
Read-Host 'Enterキーを押すと閉じます'
