# $language="VBScript"
# $interface="1.0"

set fso=CreateObject("Scripting.FileSystemObject")

'检测log目录是否存在，若不存在则创建'
sub newFolder() 
	if not fso.FolderExists(".\log") then 
		fso.CreateFolder(".\log")
	end if 
End Sub

'检测comm.txt是否存在，若不存在则提示并创建。存在则读取数据'
Function getComm ()
  	if fso.FileExists(".\command.txt") then'判断文件是否存在
  		set c=fso.GetFile(".\command.txt")
  		if c.Size>0 then '判断文件长度
  			set commFile=fso.OpenTextFile(".\command.txt")
  			getComm = commFile.ReadAll '读取文件'
		else
			crt.Dialog.MessageBox("Can not find any _command in 'command.txt' file !")'提示没有找到任何命令'
		end if 
	else
		crt.Dialog.MessageBox("Can not find any command !"&chr(13)&_
			"Please copy your command to 'command.txt' file!") '提示文件不存在'
		fso.CreateTextFile(".\command.txt") '创建文件'
	end if 
End Function  

'获取当前tab所在的模式（user，enable，config）'
Function getMode (objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns)) '获取当前行内容'
	if 	Right(currentRow,1)="#" then '判断是否包含#'
		if Right(currentRow,9)="(config)#" '判断是否包含(config)#'
			getMode="config" '函数返回值为config'
		else
			getMode="enable" '函数返回值为enable'
		end if
	elseif Right(currentRow,1)=">" then '判断是否包含>'
		getMode="user"     '函数返回值为user'
	' else 
	' 	crt.Dialog.MessageBox("Unknow mode !")  '提示未知模式'
	end if 
End Function

'获取当前设备名'
Function devName (objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))'获取当前行内容'
	if getMode(objTab)="user" or getMode(objTab)="enable" then 
		devName=mid(currentRow,1,len(currentRow)-1) '若当前模式为user或enable，则函数返回至为当前行去掉最后一个字符'
	elseif getMode(objTab)="config" then
		devName=mid(currentRow,1,len(currentRow)-9) '若当前模式为config，则函数返回至为当前行去掉最后9个字符'
	' else
	' 	crt.Dialog.MessageBox("Unknow mode !") '提示未知模式'
	end if
End Function


'生成文件名'
Function fileName (objTab)
	s="\/*:|<>?" & chr(34) '定义非法字符'
	for l= 1 to len(s)
		'crt.Dialog.MessageBox(instr(1,devName,mid(s,l,1)))
		if instr(1,devName(objTab),mid(s,l,1))>0 then
			fileName=".\log\"&replace(devName(objTab),mid(s,l,1),"-")_
			&".log"     '遍历非法字符，若当前设备名中存在则替换为“-”'
		end if 
	next
End Function

'生成WaitFor内容，>、#、(config)#'
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

sub getLog()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		if getMode(objTab)="user" then
			defaultComm(objTab)
		end if 
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
	next
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

Sub apCfg (serverip)
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		t=year(now)&month(now)&day(now)
		ap="copy flash:ap-config.text tftp://"&_
		serverip&"/ap-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(ap & chr(13))
		crt.sleep(1)
	next
End Sub

sub checkOK()
	check=1
	tabNum=crt.GetTabCount
	do while check<=tabNum
		set checkTab=crt.GetTab(check)
		checkTab.Activate
		if waitStop(checkTab) then
			check=check+1
		end if 
		crt.sleep(200)
	loop
end sub

Sub runCfg (serverip)
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		t=year(now)&month(now)&day(now)
		run="copy startup-config tftp://"&_
		serverip&"/run-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(run & chr(13))
		crt.sleep(1)
	next
End Sub

sub backup()
	serverip="111.111.111.111"
	reset()
	runCfg(serverip)
	checkOK()
	reset()
	apCfg(serverip)
end sub

getLog()