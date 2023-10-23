## "Самодельный Teamviewer"

Самодельный Teamviewer состоит из 3 частей:
- Комплект для клиента
- Комплект для службы поддержки
- Серверная часть

## Комплект для клиента

Клиентская часть состоит из VNC server и AutoIt

1. Скачать и установить [AutoIt](https://www.autoitscript.com/site/autoit/downloads/)

2. Установить UltraVNC (ссылки: [раз](http://support1.uvnc.com/download/1212/UltraVnc_1212_x86.msi) [два](http://www.uvnc.com/downloads/ultravnc/118-download-ultravnc-1212.html) ). Для совместимости надо использовать 32-битную версию.

3. Создать отдельную папку (d:\btoRemoteSupportClient)

4. Скопировать туда из папки установки UltraVNC файлы:
```
authadmin.dll
authSSP.dll
ldapauth.dll
ldapauth9x.dll
ldapauthnt4.dll
logging.dll
logmessages.dll
vnchooks.dll
workgrpdomnt4.dll
winvnc.exe
ultravnc.ini
options.vnc
```
5. Туда же положить скрипт на AutoIT:
<code>btoRemoteSupport.au3:</code>
```autoit
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#Include <GuiListView.au3>
 
Local $vncExeName = "winvnc.exe"
; host:port for repeater (ex: 192.168.1.1:5500 or xxx.domain.com)
Local $repeaterHost = "192.168.1.1:5500"
 
Local $idMylist
Local $vncExePath = $vncExeName
Local $extractedDir = @TempDir & "\bto-vnc"
FileDelete($extractedDir)
DirCreate($extractedDir)
$extractedDir = $extractedDir & "\"
FileInstall("authadmin.dll", $extractedDir, 1)
FileInstall("authSSP.dll", $extractedDir, 1)
FileInstall("ldapauth.dll", $extractedDir, 1)
FileInstall("ldapauth9x.dll", $extractedDir, 1)
FileInstall("ldapauthnt4.dll", $extractedDir, 1)
FileInstall("logging.dll", $extractedDir, 1)
FileInstall("logmessages.dll", $extractedDir, 1)
FileInstall("vnchooks.dll", $extractedDir, 1)
FileInstall("workgrpdomnt4.dll", $extractedDir, 1)
FileInstall("winvnc.exe", $extractedDir, 1)
FileInstall("ultravnc.ini", $extractedDir, 1)
FileInstall("options.vnc", $extractedDir, 1)
Local $chdirResult = FileChangeDir($extractedDir)
ConsoleWrite("chdir to " & $extractedDir & " " & $chdirResult & @CRLF)
ConsoleWrite($extractedDir & @CRLF)
Main()
 
 
Func KillProc($procName)
	Local $killResult = ProcessClose($procName)
	ConsoleWrite("kill result " & $killResult & @CRLF)
    if $killResult <> 1 Then
    	Return @error
    Else
    	return 0
    EndIf
EndFunc ; ==> KillProc
 
Func KillVNC()
   ;ConsoleWrite("Killing vnc" & @CRLF)
   Return KillProc($vncExeName);
EndFunc
 
Func Main()
    GUICreate("Параметры подключения", 500, 300) ; will create a dialog box that when displayed is centered
 
 
    $idMylist = GUICtrlCreateListView('', 0, 0, 500, 200)
 
	; Add columns
    _GUICtrlListView_InsertColumn($idMylist, 0, "Сотрудник", 200)
    _GUICtrlListView_InsertColumn($idMylist, 1, "код", 150)
 
    ; Add items
    _GUICtrlListView_AddItem($idMylist, "Коско Александр", 0)
    _GUICtrlListView_AddSubItem($idMylist, 0, "6666", 1)
 
    _GUICtrlListView_AddItem($idMylist, "Лукашевич Тимофей", 1)
    _GUICtrlListView_AddSubItem($idMylist, 1, "5555", 1)
 
    GUICtrlSetLimit(-1, 200) ; to limit horizontal scrolling
    ;Local $idClose = GUICtrlCreateButton("my closing button", 64, 160, 175, 25)
   ;Local $idKillProc = GUICtrlCreateButton("Kill", 64, 112, 75, 25)
   Local $label = GUICtrlCreateLabel("Для подключения к сеансу удаленного управления" & @CRLF & "сделайте двойной клик на выбранном сотруднике ", 0, 220, 500, 40)
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
    GUISetState(@SW_SHOW)
 
    ; Loop until the user exits.
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                KillVNC()
				FileDelete($extractedDir)
                Exit
            ;Case $idKillProc
        	;	Local $rslt = KillVNC()
        	;	If $rslt <> 0 Then
        	;		MsgBox($MB_SYSTEMMODAL, "kill result: " & $rslt, $rslt)
        	;	EndIf
            Case $idClose
                MsgBox($MB_SYSTEMMODAL, "", "the closing button has been clicked", 2)
                Exit
        EndSwitch
    WEnd
EndFunc   ;==>Main
 
 
;~ ========================================================
;~ This thing is responcible for click events
;~ ========================================================
Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
 
    Local $hWndFrom, $iCode, $tNMHDR, $hWndListView
    $hWndListView = $idMylist
    If Not IsHWnd($idMylist) Then $hWndListView = GUICtrlGetHandle($idMylist)
 
    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_DBLCLK  ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                   Local $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                   $Index = DllStructGetData($tInfo, "Index")
                   $subitemNR = DllStructGetData($tInfo, "SubItem")
                   ; make sure user clicks on the listview & only the activate
				  If $Index <> -1 Then
					   Local $someStr = _GUICtrlListView_GetItemTextString($idMylist, $Index)
                        $item = StringSplit($someStr,'|')
                        Local $employeeId = $item[2]
						Connect($employeeId)
                    EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
 EndFunc   ;==>WM_NOTIFY
 
Func Connect($employeeId)
   Local $killResult = KillVNC()
   if $killResult <> 0 Then
	  MsgBox($MB_SYSTEMMODAL, "Ошибка: " & $killResult, "Не удалось завершить предыдущий экземпляр " & $vncExeName)
	  Return
   EndIf
 
   Local $pid = ShellExecute ($vncExePath, "-id:" & $employeeId & " -repeater " & $repeaterHost & " -run")
   if $pid == 0 Then
	  MsgBox($MB_SYSTEMMODAL, "Ошибка " & @error, "Не удалось запустить " & $vncExeName)
	  Return
   EndIf
 
   Local $wnd = WinWait("[CLASS:#32770;TITLE:Initiate Connection]", "", 6)
   ConsoleWrite("xx " & $wnd & @CRLF)
   if $wnd == 0 Then
	  MsgBox($MB_SYSTEMMODAL, "Ошибка", "Таймаут запуска " & $vncExeName)
	  Return
   EndIf
   WinActivate($wnd)
   Send("{TAB}"& $employeeId)
   ControlClick($wnd, "", 1)
EndFunc
```

В коде нужно вписать сотрудников техподдержки. Каждому соответствует уникальный цифровой id:
```
_GUICtrlListView_AddItem($idMylist, "Коско Александр", 0) _GUICtrlListView_AddSubItem($idMylist, 0, "6666", 1)
```

6. Заменить файл options.vnc и ultravnc.ini на приведенные:
<code>options.vnc:</code>
```
[connection]
index=
```
<code>ultravnc.ini</code>
```
[ultravnc]
passwd=66726B636B6B385509
passwd2=42614F58624F6F67D1
```

7. Скомпилировать скрипт вышеприведенный скрипт autoit в exe-файл и выложить в интернет

## Комплект для службы поддержки

1. Скачать и установить UltraVNC, как и для клиентов

2. Создать отдельную папку (d:\btoRemoteSupportSupport)

3. Скопировать туда из папки установки UltraVNC все файлы

4. туда же положить файл `vncviewer.vbs`:
```vbs
    Set WshShell = WScript.CreateObject("WScript.Shell")
    WshShell.Run("vncviewer.exe -autoscaling -noauto -keepalive 5 -256colors -encoding tight -compresslevel 5 -proxy 192.168.1.1:5900 ID:5555")
```
при этом для каждого сотрудника техподдержки нужно исправить ID на нужный (ID:5555 в строке запуска)

## Серверная часть

Для работы необходим сервер, который расположен не за NAT'ом. У меня это была машинка с Ubuntu server

1. скачать ultravnc repeater: Зайти на http://www.uvnc.com/downloads/repeater/83-repeater-downloads.html и найти там ссылку под названием Unix1 ([вот она](http://www.uvnc.eu/download/repeater/uvncrepeater.tar.gz))

2. Скомпилировать, установить (в комплекте идет подробная инструкция в файле ultravncrepeaterlinuxport.html):
```bash
cd ~/work
wget http://www.uvnc.eu/download/repeater/uvncrepeater.tar.gz
tar -xzf uvncrepeater.tar.gz
cd UVNCRepeater
make
sudo make install
sudo adduser uvncrep -s /bin/false
```
3. uvncrepeater.ini:
```ini
[general]
;Ports
viewerport = 5900
serverport = 5500

;Repeater's own ip address in case your server happens to have several
;ip addresses (for example, one physical machine running several virtual
;machines each having their own ip address)
;default (0.0.0.0 = INADDR_ANY = uses all addresses) is the same that
;older repeater versions (before 0.12) did --> listens to all interfaces
;Notice ! This IS NOT address of server or viewer, but repeater itself !
ownipaddress = 0.0.0.0

;How many sessions can we have active at the same time ?
;values can be [1...1000]
;Notice: If you actually *have* computer(s) capable
;of 1000 simultaneous sessions, you are probably a *very big company*,
;so please invite me to visit and admire your server(s) ;-)
maxsessions = 100

;If program is started as root (to allow binding ports below 1024),
;it changes to this user after ports have been bound in startup
;You need to create a suitable (normal, non-privileged) user/group and change name here
runasuser = uvncrep

;Allowed modes for repeater
;0=None, 1=Only Mode 1, 2=Only Mode 2, 3=Both modes
;Notice: If you set allowedmodes = 0, repeater will run without listening to any ports,
;it will just wait for your ctlr + c ;-)
allowedmodes = 3

;Logging level
;0 = Very little (fatal() messages, relaying done)
;1 = 0 + Important messages + Connections opened / closed
;2 = 1 + Ini values + exceptions in logic flow
;3 = 2 + Everything else (very detailed and exhaustive logging == BIG log files)
logginglevel = 3
  
[mode1]
;0=All
allowedmode1serverport = 0

;0=Allow connections to all server addressess,
;1=Require that server address (or range of addresses) is listed in
;srvListAllow[0]...srvListAllow[SERVERS_LIST_SIZE-1]
requirelistedserver = 0

;List of allowed server addresses / ranges
;Ranges can be defined by setting corresponding number to 0, e.g. 10.0.0.0 allows all addresses 10.x.x.x
;Address 255.255.255.255 (default) does not allow any connections
;Address 0.0.0.0 allows all connections
;Only IP addresses can be used here, not DNS names
;There can be max SERVERS_LIST_SIZE (default 50) srvListAllow lines
srvListAllow0 = 10.0.0.0        ;Allow network 10.x.x.x
srvListAllow1 = 192.168.0.0     ;Allow network 192.168.x.x

;List of denied server addresses / ranges
;Ranges can be defined by setting corresponding number to 0, e.g. 10.0.0.0 denies all addresses 10.x.x.x
;Address 255.255.255.255 (default) does not deny any connections
;Address 0.0.0.0 denies all connections
;Only IP addresses can be used here, not DNS names
;If addresss/range is both allowed and denied, it will be denied (deny is stronger)
;There can be max SERVERS_LIST_SIZE (default 50) srvListDeny lines
srvListDeny0 = 10.0.0.0         ;Deny network 10.x.x.x
srvListDeny1 = 192.168.2.22     ;Deny host 192.168.2.22
  
[mode2]
;0=Allow all IDs, 1=Allow only IDs listed in idList[0]...idList[ID_LIST_SIZE-1]
requirelistedid = 0

;List of allowed ID: numbers
;Value 0 means "this authenticates negatively"
;If value is not listed, default is 0
;Values should be between [1...LONG_MAX-1]
;There can be max ID_LIST_SIZE (default 100) idList lines
idlist0 = 1111
idlist1 = 2222
idlist2 = 0
idlist3 = 0
idlist4 = 0
idlist5 = 0
idlist6 = 0
idlist7 = 0
idlist8 = 0
idlist9 = 0
  
  
[eventinterface]
;Use event interface (for reporting repeater events to outside world) ?
;This could be used to send email, write webpage, update database etc.
;Possible values: true/false
useeventinterface = true

;Hostname/Ip address  + port of event listener we send events to
eventlistenerhost = localhost
eventlistenerport = 2002

;Make HTTP/1.0 GET request to event listener (instead of normal write dump)
;Somebody wanted this for making a PHP event listener
usehttp = true
```
4. Поставить службу в автозапуск и запустить:
```bash
sudo  update-rc.d uvncrepeater defaults
sudo /etc/init.d/uvncrepeater stop
```

5. Открыть порты: 5500 для доступа из инета и 5900 для доступа изнутри
