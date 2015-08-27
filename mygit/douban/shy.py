# -*- coding: utf-8 -*-
from __future__ import unicode_literals
"""
Created on Sun Aug 16 13:55:48 2015

@author: Admin
"""

import requests,urllib,os,time

headers={
        'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.0; MSN 2.5; Windows 95)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.0; Windows 95; DigExt);',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.0; Windows 95)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; MSN 2.5; MSN 2.5; Windows 98)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; MSN 2.5; Windows 95)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; MSN 2.5; Windows 98)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 95)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 95; Yahoo! JAPAN Version Windows 95/NT CD-ROM Edition 1.0.)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 98; BIGLOBE)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 98; canoncopyer)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 98; Compaq)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.0; Windows 98; DigExt);',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows NT)',
        'User-Agent':'Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)'
        }
proxies={
        "http":"http://211.90.28.105:8088",
        "http":"http://113.69.160.24:80",
        "http":"http://61.156.217.81:80",
        "http":"http://117.177.243.43:8086",
        "http":"http://27.191.0.137:81",
        "http":"http://219.225.129.26:80",
        "http":"http://111.161.126.101:80",
        "http":"http://101.200.172.120:8088",
        "http":"http://114.42.114.31:80"
        }

def getImage(themeList):
    rootPath=r'f:\douban\shy\image'
    for k in themeList:
        for p in k['photos']:
            imageUrl=p['alt']
            fileName=k['id']+'_'+p['id']+'.jpg'
            if fileName not in os.listdir(rootPath):
                filePath=rootPath+'\\'+fileName
                urllib.urlretrieve(imageUrl,filePath)
                print '正在下载：'.decode('utf-8')+imageUrl

apiUrl='https://api.douban.com/v2/group/haixiuzu/topics'
while 1==1:
    r=requests.get(apiUrl,headers=headers,proxies=proxies)
    if str(r.status_code)=='200':
        api=r.json()
        themeList=api['topics']
        getImage(themeList)
    else:
        for i in range(0,60*15,5):
            print '请求次数过多，等待：'.decode('utf-8')+str(60*15-i)+'秒'.decode('utf-8')
            time.sleep(5)
    for i in range(0,10,5):
            print '等待：'.decode('utf-8')+str(10-i)+'秒'.decode('utf-8')
            time.sleep(5)

#test    