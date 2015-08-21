# -*- coding: utf-8 -*-
"""
Spyder Editor

This temporary script file is located here:
C:\Users\Admin\.spyder2\.temp.py
"""

def cut(line,x):
    if x>=0:       
        cell=",".join(line.split()).split(',')[x]
    else:
        cell=",".join(line.split()).split(',')
    return cell

import os, re,time,xlrd,xlwt

list_title=['主机名检查',
            '设备版本',
            '硬件信息',
            '主备关系',
            '上次启动时间',
            '系统运行时间（天：时：分：秒）',
            'CPU利用率',
            '内存利用率',
            'SSID',
            '在线AP数检查(总数，在线数)',
            '在线用户数检查',
            '查看用户地址池ip地址分配情况',
            'Radio状态',
            '无线状态检查',
            '电源检查',
            '风扇检查',
            '日志检查',
            '端口状态',
            '路由表检查',
            '设备网络可达检查',
            '检查SSH远程登录状态',
            '检查远程访问登录控制',
            '检查SNMP服务器配置',
            '检查防火墙开关',
            '设备时间',
            '巡检时间']
i=0
row=0

os.chdir(r"D:\check\log")                                     #切换目录
file_list=os.listdir(".")                               #获得文件列表

#新建EXCEL文件并写入表头
workbook=xlwt.Workbook()
table=workbook.add_sheet('master',True)
for title in list_title:
    table.write(0,i,title.decode('utf-8'))
    i=i+1
   
for file_name in file_list:
    row=row+1
    print '正在处理:'.decode('utf-8')+file_name
    
    check_list={'主机名检查':'',
                'CPU利用率':'',
                '日志检查':'正常',
                '风扇检查':'正常',
                '系统运行时间（天：时：分：秒）':'',
                '电源检查':'正常',
                '内存利用率':'',
                '设备版本':'',
                '硬件信息':'',
                '端口状态':'正常',
                '路由表检查':'正常',
                '设备网络可达检查':'正常',
                '检查SSH远程登录状态':'正常',
                '检查远程访问登录控制':'',
                '检查SNMP服务器配置':'',
                '检查防火墙开关':'正常',
                '主备关系':'',
                '在线AP数检查(总数，在线数)':'',
                'Radio状态':'正常',
                '无线状态检查':'正常',
                '在线用户数检查':'',
                'SSID':'',
                '查看用户地址池ip地址分配情况':'',
                '设备时间':'',
                '巡检时间':'',
                '上次启动时间':''}

    with open(file_name,'r') as f:                      #打开文件
        line_list=f.readlines()                         #读取文件每一行
        for x in range(len(line_list)):
            
#hostname/'主机名检查'
            if re.match(u'.*>en',line_list[x]):
                check_list['主机名检查']=line_list[x].split('>')[0]

#show cpu  | include five minute /'CPU利用率'
            if 'show cpu  | include five minute' in line_list[x].strip():
                check_list['CPU利用率']=cut(line_list[x+1].strip(),5)

#show version
            if 'show version' in line_list[x].strip():
                check_list['上次启动时间']=cut(line_list[x+2].strip(),4)\
                               +' '+cut(line_list[x+2].strip(),5) 
                check_list['系统运行时间（天：时：分：秒）']=\
                            cut(line_list[x+3].strip(),3)      
                check_list['硬件信息']=cut(line_list[x+4].strip(),4)
                check_list['设备版本']=cut(line_list[x+5].strip(),4)+\
                                      ' '+cut(line_list[x+5].strip(),5)

#show ssh/'检查SSH远程登录状态'
            if 'show ssh' in line_list[x].strip():
                if cut(line_list[x+2].strip(),1)!='2.0':
                    check_list['检查SSH远程登录状态']='SSH版本异常'
                elif cut(line_list[x+2].strip(),2)!='aes256-cbc':
                    check_list['检查SSH远程登录状态']='SSH加密异常'
                elif cut(line_list[x+2].strip(),6)!='ruijie':
                    check_list['检查SSH远程登录状态']='SSH用户异常'
                else:
                    check_list['检查SSH远程登录状态']='正常'

#show running-config | b line vty/'检查远程访问登录控制'
            if 'show running-config | b line vty' in line_list[x].strip():
                if 'denyTTY' in cut(line_list[x+3].strip(),-1):
                    check_list['检查远程访问登录控制']='正常'

#show snmp host/'检查SNMP服务器配置'
            if 'show snmp host' in line_list[x].strip():
                if cut(line_list[x+1].strip(),2)!='10.223.16.23':
                    check_list['检查SNMP服务器配置']='SNMP1地址异常'
                elif cut(line_list[x+2].strip(),1)!='162':
                    check_list['检查SNMP服务器配置']='SNMP1端口异常'
                elif cut(line_list[x+3].strip(),1)!='trap':
                    check_list['检查SNMP服务器配置']='SNMP1模式异常'
                elif cut(line_list[x+4].strip(),1)!='cmcc!@#99':
                    check_list['检查SNMP服务器配置']='SNMP1团体字异常'
                elif cut(line_list[x+5].strip(),2)!='v2':
                    check_list['检查SNMP服务器配置']='SNMP1版本异常'
                elif cut(line_list[x+7].strip(),2)!='10.255.228.148':
                    check_list['检查SNMP服务器配置']='SNMP2地址异常'
                elif cut(line_list[x+8].strip(),1)!='162':
                    check_list['检查SNMP服务器配置']='SNMP2端口异常'
                elif cut(line_list[x+9].strip(),1)!='trap':
                    check_list['检查SNMP服务器配置']='SNMP2模式异常'
                elif cut(line_list[x+10].strip(),1)!='cmcc!@#99':
                    check_list['检查SNMP服务器配置']='SNMP2团体字异常'
                elif cut(line_list[x+11].strip(),2)!='v2':
                    check_list['检查SNMP服务器配置']='SNMP2版本异常'
                else:
                    check_list['检查SNMP服务器配置']='正常'
                    
#show hot-backup/'主备关系'
            if 'show hot-backup' in line_list[x].strip():
                check_list['主备关系']=cut(line_list[x+2].strip(),3)

#show ap-config summary/'在线AP数检查(总数，在线数)'
            if 'show ap-config summary' in line_list[x].strip():
                check_list['在线AP数检查(总数，在线数)']=\
                str(int(cut(line_list[x+7].strip(),3))+int(cut(line_list[x+8].strip(),3)))+\
                '/'+cut(line_list[x+7].strip(),3)
                
#show wlan users/'在线用户数检查'
            if 'show wlan users' in line_list[x].strip():
                check_list['在线用户数检查']=cut(line_list[x+1].strip(),2).split(':')[1]
                
#show wlan-config summary/'SSID'
            if 'show wlan-config summary' in line_list[x].strip():
                count=4
                wlan_list=[]
                ssid_list=[]
                while 'BJBJ' not in line_list[x+count].strip():
                    wlan_list.append(cut(line_list[x+count].strip(),-1))
                    count=count+1
                for ssid in wlan_list:
                    if ssid[1] not in ssid_list: ssid_list.append(ssid[1])
                for ssidstr in ssid_list:
                    check_list['SSID']=check_list['SSID']+':'+ssidstr

#show clock/'设备时间'
            if 'show clock' in line_list[x].strip():
                check_list['设备时间']=line_list[x+1].strip()

#show ip dhcp pool/'查看用户地址池ip地址分配情况'
            if 'show ip dhcp pool' in line_list[x].strip():
                check_list['查看用户地址池ip地址分配情况']=cut(line_list[x+4].strip(),3)+r'%'

#show memory/'内存利用率'
            if 'show memory' in line_list[x].strip():
                check_list['内存利用率']=cut(line_list[x+5].strip(),3)

#'巡检时间'
            check_list['巡检时间']=time.strftime( '%Y-%m-%d %H:%M:%S', time.localtime())
        
#结果写入excel文件
    for col in range(len(list_title)):
        table.write(row,col,check_list[list_title[col]].decode('utf-8'))

workbook.save('d:/check/check.xls')
