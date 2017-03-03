Set WshShell = WScript.CreateObject("WScript.Shell")
'WshShell.Run("vncviewer.exe -plugin MSRC4Plugin_for_sc.dsm -keepalive 5 -8bit -proxy 192.168.200.5:5900 ID:5555")
WshShell.Run("vncviewer.exe -autoscaling -noauto -keepalive 5 -256colors -encoding tight -compresslevel 5 -proxy 192.168.200.5:5900 ID:5555")