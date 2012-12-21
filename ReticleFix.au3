#requireadmin

Func reticleFix()
   $tempDevConPath = @TempDir & "/devcon.exe"

   Switch @OSArch
	  Case "X86"
		 FileInstall("bin/devcon_x86.exe", $tempDevConPath)
	  Case "X64"
		 FileInstall("bin/devcon_x64.exe", $tempDevConPath)
   EndSwitch

   RunWait($tempDevConPath & " disable =Display *", "", @SW_HIDE)
   RunWait($tempDevConPath & " enable =Display *", "", @SW_HIDE)
   
   FileDelete($tempDevConPath)
   
   Exit(1)
EndFunc

Func getSteamPath()
   Return StringReplace(RegRead("HKCU\Software\Valve\Steam", "SteamPath"), "/", "\")
EndFunc

Func getBops2Path()
   return getSteamPath() & "\steamapps\common\Call of Duty Black Ops II"
EndFunc

$reticleFixPath = getBops2Path() & "\ReticleFix.exe"

Func installReticleFix()
   $tempSetAclPath = @TempDir & "/SetACL.exe"

   Switch @OSArch
	  Case "X86"
		 FileInstall("bin/SetACL_x86.exe", $tempSetAclPath)
	  Case "X64"
		 FileInstall("bin/SetACL_x64.exe", $tempSetAclPath)
   EndSwitch
   
   $installScriptPath = getBops2Path() & "\installscript.vdf"
   
   $target = '	"Run Process"' & @LF & _
			'	{'
   $replace = $target & @LF & _
			   '		"ReticleFix"' & @LF & _
			   '		{' & @LF & _
			   '			"HasRunKey"		"HKEY_LOCAL_MACHINE\\Software\\Valve\\Steam\\Apps\\202970"' & @LF & _
			   '			"process 1"		"%INSTALLDIR%\\ReticleFix.exe"' & @LF & _
			   '		}'
			   
			   
   $content = FileRead($installScriptPath)
   
   If Not StringInStr($content, "ReticleFix") Then
	  $content = StringReplace($content, $target, $replace)
	  
	  $file = FileOpen($installScriptPath, 2)
	  FileWrite($file, $content)
   EndIf
   
   RunWait(StringFormat('%s -on "%s" -ot file -actn ace -ace "n:%s;m:deny;p:write"', $tempSetAclPath, $installScriptPath, @UserName), "", @SW_HIDE)
   
   FileCopy(@ScriptFullPath, $reticleFixPath, 1)
   
   MsgBox(32, "ReticleFix", "ReticleFix installed!" & @CRLF & "Now just launch Call of Duty: Black Ops 2!")
   
   FileDelete($tempSetAclPath)
EndFunc

If StringCompare(@ScriptFullPath, $reticleFixPath) == 0 Then
   reticleFix()
Else
   installReticleFix()
EndIf