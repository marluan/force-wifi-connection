;	Script para retomar conexão Wi-Fi sempre que cair
;	Cuidado para não colocar para retomar conexões com autenticação inválida, pois a macro ficará tentando conectar sem parar
;	Lmebre-se que para conectar em mais de uma rede, você PRECISA TER a mesma quantidade de adaptadores no PC (eu uso um adaptador usb para ter 2 redes)
IniRead, values,config.ini,Adapters,nomesAdaptadores
nomesAdaptadores:= StrSplit( values,",")

IniRead, values,config.ini,Networks,nomesRedes
nomesRedes:=StrSplit( values,",")

DetectHiddenWindows On
Loop
{
	dhw := A_DetectHiddenWindows
	Run "%ComSpec%" /k,, Hide, pid
	while !(hConsole := WinExist("ahk_pid" pid))
		Sleep 100
	DllCall("AttachConsole", "UInt", pid)
	DetectHiddenWindows %dhw%
	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec("cmd /c netsh wlan show interface")
	While !objExec.Status
		Sleep 100
	wlanres := objExec.StdOut.ReadAll()
	DllCall("FreeConsole")
	Process Exist, %pid%
	if (ErrorLevel == pid)
		Process Close, %pid%
	
	Loop, % nomesAdaptadores.length()
	{
		nomeRede:=nomesRedes[A_Index]
		IfNotInString,wlanres,%nomeRede%
		{
			objShell := ComObjCreate("WScript.Shell")
			comandoAtual:="cmd /c netsh wlan connect ssid=""" . nomesRedes[A_Index] . """ name=""" . nomesRedes[A_Index] . """ interface=""" . nomesAdaptadores[A_Index] . """"
			objExec := objShell.Exec(comandoAtual)
			While !objExec.Status
				Sleep 100
		}
	}
	Sleep, 2500
}