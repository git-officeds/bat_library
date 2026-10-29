@echo off
setlocal

:: 【設定箇所】環境に合わせて書き換えてください
set DB_USER=root
set DB_PASS=
:: データベース名を半角スペースで区切って入れる
set DB_NAMES=db_01 kanri user option
:: バックアップ先のディレクトリのパス
set BACKUP_DIR=C:\documents\開発環境\
:: SQLの場所
set XAMPP_MYSQL_BIN=C:\xampp\mysql\bin

:: 日付と時刻を取得
set TIME_STAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIME_STAMP=%TIME_STAMP: =0%

:: 1. MySQLを「完全に裏側（バックグラウンド）」で静かに起動させる
start /B "" "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini" --standalone
:: 起動完了まで10秒待機
timeout /t 10 /nobreak >nul

:: 2. データベースを順番にエクスポート
for %%A in (%DB_NAMES%) do (
    "%XAMPP_MYSQL_BIN%\mysqldump.exe" -u %DB_USER% %%A > "%BACKUP_DIR%\%%A_%TIME_STAMP%.sql"
)

:: 3. バックアップが終わったら、MySQLに終了指令を出して安全に閉じる
"%XAMPP_MYSQL_BIN%\mysqladmin.exe" -u %DB_USER% shutdown
:: 終了完了まで5秒待機
timeout /t 5 /nobreak >nul

:: 【容量不足対策】各データベースごとに「最新の2件」を残し、古いものを削除
for %%A in (%DB_NAMES%) do (
    for /f "skip=2 delims=" %%F in ('dir /b /o-d "%BACKUP_DIR%\%%A_*.sql" 2^>nul') do (
        del "%BACKUP_DIR%\%%F"
    )
)

exit