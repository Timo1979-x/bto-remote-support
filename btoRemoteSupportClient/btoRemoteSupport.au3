#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#Include <GuiListView.au3>

Local $vncExeName = "winvnc.exe"
; host:port for repeater (ex: 192.168.200.5:5500 or vpn.gto.by)
Local $repeaterHost = "vpn1.gto.by:5500"

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
