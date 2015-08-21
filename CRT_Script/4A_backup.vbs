# $language="VBScript"
# $interface="1.0"


sub newFolder()
	if not fso.FolderExists(".\log") then
		fso.CreateFolder(".\log")
	end if 
End Sub

Function getComm ()
  	if fso.FileExists(".\command.txt") then
  		set c=fso.GetFile(".\command.txt")
  		if c.Size>0 then
  			set commFile=fso.OpenTextFile(".\command.txt")
  			getComm = commFile.ReadAll
		else
			crt.Dialog.MessageBox("Can not find any command in 'command.txt' file !")
		end if 
	else
		crt.Dialog.MessageBox("Can not find any command !"&chr(13)&_
			"Please copy your command to 'command.txt' file!")
		fso.CreateTextFile(".\command.txt")
	end if 
 End Function  

Function getMode (objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
	if 	Right(currentRow,1)="#" then
		if Right(currentRow,9)="(config)#" then
			getMode="config"
		else
			getMode="enable"
		end if
	elseif Right(currentRow,1)=">" then
		getMode="user"
	' else 
	' 	crt.Dialog.MessageBox("Unknow mode !")
	end if 
End Function

Function devName (objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
	if getMode(objTab)="user" or getMode(objTab)="enable" then
		devName=mid(currentRow,1,len(currentRow)-1)
	elseif getMode(objTab)="config" then
		devName=mid(currentRow,1,len(currentRow)-9)
	' else
	' 	crt.Dialog.MessageBox("Unknow mode !")
	end if
End Function

Function fileName (objTab)
	s="\/*:|<>?" & chr(34)
	for l= 1 to len(s)
		'crt.Dialog.MessageBox(instr(1,devName,mid(s,l,1)))
		if instr(1,devName(objTab),mid(s,l,1))>0 then
			fileName=".\log\"&replace(devName(objTab),mid(s,l,1),"-")_
			&".log"
		end if 
	next
End Function

Function wait (objTab)
	if getMode(objTab)="enable" then
		wait=devName(objTab)&"#"
	elseif getMode(objTab)="config" then
		wait=devName(objTab)&"(config)#"
	elseif getMode(objTab)="user" then
		wait=devName(objTab)&">"
	' else
	' 	objTab.Dialog.MessageBox("Unknow mode !")
	end if 
End Function

Sub defaultComm (objTab)
	checkTime="checktime "&date&" "&hour(now)&":"&minute(now)&":"&second(now)&" checktime"
	line="=========="
	if getMode(objTab)="user" then
		objTab.Screen.Send("en" & chr(13))
		objTab.Screen.WaitForString("assword:")
		objTab.Screen.Send("wlan!@#00" & chr(13))
		objTab.Screen.WaitForString("#")
	else 
		objTab.Screen.Send("terminal length 0" & chr(13))
		objTab.Screen.WaitForString("#")
		objTab.Screen.Send("!"&line&checktime&line& chr(13))
		objTab.Screen.WaitForString("#")
	end if 
End Sub

sub getLog(objTab)
	if getMode(objTab)="user" then
		defaultComm(objTab)
	end if 
	objTab.Activate
	objTab.Session.LogFileName=fileName(objTab)
	if objTab.Session.LogFileName<>"" then
		objTab.Session.Log(False)
	end if 
	objTab.Session.Log(True)
	defaultComm(objTab)
	for each comm in split(getComm(),chr(13))
		objTab.Screen.Send(RTrim(comm) & chr(13))
		objTab.Screen.WaitForString("#")
	next
	objTab.Session.Log(False)
end sub

Function devNameL ()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
		if getMode(objTab)="user" or getMode(objTab)="enable" then
			devName1=mid(currentRow,1,len(currentRow)-1)
		elseif getMode(objTab)="config" then
			devName1=mid(currentRow,1,len(currentRow)-9)
		end if
		devNameL=devNameL&devName1&","
	next
End Function

Function waitStop (objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
	if objTab.Screen.CurrentColumn>2 and instr(1,currentRow,"#")>0 then
		waitStop=True
	else
		waitStop=False
	end if
End Function

Function openLogAll ()
	logNum=crt.GetTabCount
	for l=1 to logNum
		set objLogO=crt.GetTab(l)
		objLogO.Session.LogFileName=fileName(objLogO)
		if objLogO.Session.LogFileName<>"" then
			objLogO.Session.Log(False)
		end if 
		objLogO.Session.Log(True)
	next
End Function

Function closeLogAll ()
	logNum=crt.GetTabCount
	for l=1 to logNum
		set objLogC=crt.GetTab(l)
		if objLogC.Session.LogFileName<>"" then
			objLogC.Session.Log(False)
		end if 
	next
End Function

Sub reset ()
	logNum=crt.GetTabCount
	for r=1 to logNum
		set objRes=crt.GetTab(r)
		objRes.Activate
		objRes.Screen.Clear 
		objRes.Screen.Send(chr(13)&chr(13)&chr(13))
	next
	crt.GetTab(1).Activate
End Sub

Sub apCfg (objTab)
	serverip="221.216.145.214"
	t=year(now)&month(now)&day(now)
	ap="copy flash:ap-config.text tftp://"&serverip&"/ap-"&replace(mid(fileName(objTab),7),".log","")&"-"&t&".log"
	objTab.Screen.Send(ap & chr(13))
End Sub

Sub runCfg (objTab)
	serverip="221.216.145.214"
	t=year(now)&month(now)&day(now)
	run="copy startup-config tftp://"&serverip&"/run-"&replace(mid(fileName(objTab),7),".log","")&"-"&t&".log"
	objTab.Screen.Send(run & chr(13))
End Sub

set fso=CreateObject("Scripting.FileSystemObject")

sub backup()
	set fso=CreateObject("Scripting.FileSystemObject")
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		runCfg(objTab)
		crt.sleep(1)
	next

	set objTab=crt.GetTab(1)

	check=1
	do while check<=tabNum
		set checkTab=crt.GetTab(check)
		checkTab.Activate
		if waitStop(checkTab) then
			check=check+1
		end if 
		crt.sleep(200)
	loop

	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		apCfg(objTab)
		crt.sleep(1)
	next
end sub

backup()