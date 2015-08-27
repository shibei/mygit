# $language="VBScript"
# $interface="1.0"

set fso=CreateObject("Scripting.FileSystemObject")
t=year(now)&month(now)&day(now)

'检测log目录是否存在，若不存在则创建'
sub newFolder() 
	if not fso.FolderExists(".\log") then 
		fso.CreateFolder(".\log")
	end if 
End Sub

'检测comm.txt是否存在，若不存在则提示并创建。存在则读取数据'
Function getComm ()
  	if fso.FileExists(".\command.txt") then
  		set c=fso.GetFile(".\command.txt")
  		if c.Size>0 then 
  			set commFile=fso.OpenTextFile(".\command.txt")
  			getComm = commFile.ReadAll 
			crt.Dialog.MessageBox("Can not find any _command in 'command.txt' file !")
		end if 
	else
		crt.Dialog.MessageBox("Can not find any command !"&chr(13)&_
			"Please copy your command to 'command.txt' file!")
		fso.CreateTextFile(".\command.txt")
	end if 
End Function  

'获取当前tab所在的模式（user，enable，config）'
Function getMode(objTab)
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

'获取当前设备名'
Function devName(objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
	if getMode(objTab)="user" or getMode(objTab)="enable" then 
		devName=mid(currentRow,1,len(currentRow)-1) 
	elseif getMode(objTab)="config" then
		devName=mid(currentRow,1,len(currentRow)-9)
	' else'提示未知模式'
	end if
End Function

'生成设备名列表'
Function devNameL ()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		devNameL=devNameL&devName(objTab)&","
	next
End Function

'生成文件名'
Function fileName(objTab)
	s="\/*:|<>?" & chr(34) '定义非法字符'
	for l= 1 to len(s)
		'crt.Dialog.MessageBox(instr(1,devName,mid(s,l,1)))
		if instr(1,devName(objTab),mid(s,l,1))>0 then
			fileName=".\log\"&replace(devName(objTab),mid(s,l,1),"-")_
			&".log"     '遍历非法字符，若当前设备名中存在则替换为“-”'
		end if 
	next
End Function

'生成WaitFor内容，devName & >、#、(config)#'
Function waitFor (objTab)
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

'等待当前命令结束True Fale'
Function waitStop(objTab)
	currentRow=RTrim(objTab.Screen.Get(objTab.Screen.CurrentRow,1,_
		objTab.Screen.CurrentRow,objTab.Screen.Columns))
	if objTab.Screen.CurrentColumn>2 and instr(1,currentRow,"#")>0 then
		waitStop=True
	else
		waitStop=False
	end if
End Function

'开启所有log'
Sub openLogAll ()
	tabNum=crt.GetTabCount
	for l=1 to tabNum
		set objTab=crt.GetTab(l)
		objTab.Activate
		objTab.Session.LogFileName=fileName(objTab)
		if objTab.Session.LogFileName<>"" then
			objTab.Session.Log(False)
		end if 
		objTab.Session.Log(True)
	next
End Sub

'关闭所有log'
Sub closeLogAll ()
	objTab=crt.GetTabCount
	for l=1 to objTab
		set objTab=crt.GetTab(l)
		objTab.Activate
		if objTab.Session.LogFileName<>"" then
			objTab.Session.Log(False)
		end if 
	next
End Sub

'输入初始化命令'
Sub defaultComm(objTab)
	checkTime="checktime "&date&" "&hour(now)&":"&minute(now)&":"&second(now)&" checktime" '当前时间'
	line="=========="'分隔符'
	if getMode(objTab)="user" then				'若模式为user则进入特权模式'
		objTab.Screen.Send("en" & chr(13))
		objTab.Screen.WaitForString("assword:")
		objTab.Screen.Send("wlan!@#00" & chr(13))     						
		objTab.Screen.WaitForString("#")
		objTab.Screen.Send("terminal length 0" & chr(13))
		objTab.Screen.WaitForString("#")
		objTab.Screen.Send("!"&line&checktime&line& chr(13))
		objTab.Screen.WaitForString("#")
	else 
		objTab.Screen.Send("terminal length 0" & chr(13))
		objTab.Screen.WaitForString("#")
		objTab.Screen.Send("!"&line&checktime&line& chr(13))
		objTab.Screen.WaitForString("#")
	end if 
End Sub

'防止超时'
Sub timeover ()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Screen.Send(chr(13))
		objTab.Screen.WaitForString("#")
		crt.sleep(1)
	next
End Sub

'输入所有命令'
sub sendCommAll()
	tabNum=crt.GetTabCount
	'初始化'
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		defaultComm(objTab)
	next
	'开始输入'
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		objTab.Activate
		objTab.Session.LogFileName=fileName(objTab)
		if objTab.Session.LogFileName<>"" then
			objTab.Session.Log(False)
		end if 
		objTab.Session.Log(True) 			'开启log'
		defaultComm(objTab)
		for each comm in split(getComm(),chr(13))
			timeover()
			objTab.Screen.Send(RTrim(comm) & chr(13))
			objTab.Screen.WaitForString("#")
		next
		objTab.Session.Log(False)			'关闭log'
	next
end sub

'重置所有设备'
Sub resetAll ()
	tabNum=crt.GetTabCount
	for r=1 to tabNum
		set objTab=crt.GetTab(r)
		'objTab.Activate
		crt.sleep(200)
		objTab.Screen.Clear 
		objTab.Screen.Send(chr(13)&chr(13)&chr(13))
	next
	crt.GetTab(1).Activate
End Sub

'所有设备备份ap-config到tftp'
Sub apCfgTFTP (serverip)
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		crt.sleep(200)
		objTab.Activate
		defaultComm(objTab)
		ap="copy flash:ap-config.text tftp://"&_
		serverip&"/ap-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(ap & chr(13))
	next
End Sub

'所有设备备份ap-config到ftp'
Sub apCfgFTP (serverip)
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		crt.sleep(100)
		objTab.Activate
		defaultComm(objTab)
		ap="copy flash:ap-config.text ftp://admin:admin123@"&_
		serverip&"/ap-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(ap & chr(13))
	next
End Sub

'检查所有标签页是否就绪,x为延时'
sub checkAll(x)
	check=1
	tabNum=crt.GetTabCount
	do while check<=tabNum
		set checkTab=crt.GetTab(check)
		'checkTab.Activate
		if waitStop(checkTab) then
			check=check+1
		end if 
		crt.sleep(x)
	loop
end sub

'所有设备备份配置文件到tftp'
Sub runCfgTFTP (serverip)
	write()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		crt.sleep(200)
		objTab.Activate
		defaultComm(objTab)
		run="copy flash:config.text tftp://"&_
		serverip&"/run-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(run & chr(13))
	next
End Sub

'所有设备备份配置文件到ftp'
Sub runCfgFTP (serverip)
	'write()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		crt.sleep(100)
		objTab.Activate
		defaultComm(objTab)
		run="copy flash:config.text ftp://admin:admin123@"&_
		serverip&"/run-"&replace(mid(fileName(objTab),7),".log","")&_
		"-"&t&".log"
		objTab.Screen.Send(run & chr(13))
	next
End Sub

'所有设备保存配置'
Sub write ()
	tabNum=crt.GetTabCount
	for tab=1 to tabNum
		set objTab=crt.GetTab(tab)
		crt.sleep(500)
		'objTab.Activate
		defaultComm(objTab)
		objTab.Screen.Send("write " & chr(13))
	next
	checkAll(200)
End Sub

sub backup()
	serverip="183.244.69.171"
	resetAll()
	runCfgFTP(serverip)
	crt.GetTab(1).Activate
	checkAll(10)
	resetAll()
	apCfgFTP(serverip)
	checkAll(10)
	crt.GetTab(1).Activate
	crt.Dialog.MessageBox("OK!")
end sub

backup()
