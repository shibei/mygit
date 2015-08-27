#!/usr/bin/env python  
# -*- coding: iso-8859-1 -*-  
# GET Command Generator  
  
from pysnmp.entity.rfc3413.oneliner import cmdgen  
errorIndication, errorStatus, errorIndex, varBinds = cmdgen.CommandGenerator().getCmd(  
    cmdgen.CommunityData('my-agent', 'cmcc!@#99', 1),  
    cmdgen.UdpTransportTarget(('117.130.250.109', 161)),  
    '.1.3.6.1.4.1.4881.1.1.10.2.56.1.1.32.0'  
)  
#none  
print(errorIndication)  
#0  
print(errorStatus)  
#[(ObjectName(1.3.6.1.2.1.1.1.0), OctetString(hexValue='436973636f20496e7465726e6574776f726b204f7065726174696e672053797374656d20536f667477617265200d0a494f532028746d2920433236303020536f667477617265202843323630302d54454c434f2d4d292c2056657273696f6e2031322e3328313361292c2052454c4541534520534f4654574152452028666332290d0a546563686e6963616c20537570706f72743a20687474703a2f2f7777772e636973636f2e636f6d2f74656368737570706f72740d0a436f707972696768742028632920313938362d3230303520627920636973636f2053797374656d732c20496e632e0d0a436f6d70696c6564204d6f6e2032352d4170722d303520')), (ObjectName(1.3.6.1.2.1.1.2.0), ObjectIdentifier(1.3.6.1.4.1.9.1.208))]  
print(varBinds)  
#Cisco Internetwork Operating System SoftwareIOS (tm) C2600 Software (C2600-TELCO-M), Version 12.3(13a), RELEASE SOFTWARE (fc2)Technical Support: http://www.cisco.com/techsupportCopyright (c) 1986-2005 by cisco Systems, Inc.Compiled Mon 25-Apr-05  
print str(varBinds[0][1]);  
#1.3.6.1.4.1.9.1.208  
#print str(varBinds[1][1]);  