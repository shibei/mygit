# -*- coding: utf-8 -*-
from __future__ import unicode_literals
"""
Created on Wed Aug 26 15:46:51 2015
@author: Admin
"""

import paramiko

ssh=paramiko.SSHClient()
#ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#ssh.connect("192.168.248.128",22,"root", "admin123")
#stdin, stdout, stderr = ssh.exec_command("ls -al")
#print stdout.readlines()
#ssh.close()