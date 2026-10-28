@echo off
rem Shortcut so `.\dbt build` works without dbt on PATH. Uses this folder's profiles.yml.
"%APPDATA%\Python\Python313\Scripts\dbt.exe" %* --profiles-dir "%~dp0."
