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
	objTab.Screen.Send("en" & chr(13))
	objTab.Screen.WaitForString("assword:")
	objTab.Screen.Send("wlan!@#00" & chr(13))
	objTab.Screen.WaitForString("#")
	objTab.Screen.Send("terminal length 0" & chr(13))
	objTab.Screen.WaitForString("#")
End Sub

sub getLog(objTab)
	if getMode(objTab)="user" then
		defaultComm(objTab)
	end if 

	objTab.Session.LogFileName=fileName(objTab)
	if objTab.Session.LogFileName<>"" then
		objTab.Session.Log(False)
	end if 
	objTab.Session.Log(True)
	for each comm in split(getComm(),chr(13))
		objTab.Screen.Send(RTrim(comm) & chr(13))
		objTab.Screen.WaitForString(wait(objTab))
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

set fso=CreateObject("Scripting.FileSystemObject")

' tabNum=crt.GetTabCount
' for tab=1 to tabNum
' 	set objTab=crt.GetTab(tab)
' 	objTab.Activate
' 	getLog(objTab)
' next

' crt.Dialog.MessageBox("Completed!")

' for each comm in split(getComm(),chr(13))
' 	for tab=1 to tabNum
' 		set objTab=crt.GetTab(tab)
' 		objTab.Activate
' 		objTab.Screen.Send(RTrim(comm) & chr(13))
' 		crt.Screen.Clear
' 	next
' 	crt.sleep(2000)
' 	check=1
' 	do while(check<=tabNum)
' 		set checkTab=crt.GetTab(check)
' 		checkTab.Activate
' 		'msgbox(checkTab.Screen.WaitForString(wait(checkTab),1))
' 		if checkTab.Screen.WaitForString("#") then
' 			count=1
' 		else 
' 			count=0
' 		end if 
' 		check=check+1
' 		' if check>tabNum and count<tabNum then
' 		' 	check=1
' 		' elseif check>tabNum and count>tabNum then
' 		' 	check=99
' 		' end if 
' 		msgbox(count)
' 	loop
' next

' for each devName2 in split(devNameL,",")
' 	msgbox(devName2)
' next
msgbox(split(devNameL,",")(0))