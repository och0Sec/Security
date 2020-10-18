#!/usr/bin/env python3

import requests
import mailer
from pprint import pprint
import json

url = "https://tap-api-v2.proofpoint.com/v2/siem/all?format=json&sinceSeconds=600"

useragent = "Python client"
headers = {'user-agent': useragent}
sp = 'replace with sp'
secret = 'replace with secret'
auth = (sp, secret)

response = requests.get(url, headers=headers, auth=auth)
#pprint(response.json())
#print('=' * 45)
for key in response.json():
    message = ''
    #print(len(response.json()[key]))
    if len(response.json()[key]) != 0 and key != 'queryEndTime':
        if len(response.json()[key]) == 1:
            dict = response.json()[key][0]
            message += '********************Alert********************\n'
            message += 'Status: ' + key + '\n'
            message += 'Recipient: ' + json.dumps(dict['recipient'])
            message += '\nSender: '+ json.dumps(dict['sender'])
            message += '\nSenderIP: ' + json.dumps(dict['senderIP'])
            message += '\nSubject: '+ json.dumps(dict['subject'])
            message += '\nthreatsInfoMap: '+ json.dumps(dict['threatsInfoMap'])
            message += '\n**********************************************\n\n'
            #mailer.send_email('Proofpoint Alert: ' + key, message)
            #pprint(message)
        else:
            for i in range(len(response.json()[key])-1):
                dict = response.json()[key][i]
                message += '********************Alert********************\n'
                message += 'Status: ' + key + '\n'
                message += 'Recipient: ' + json.dumps(dict['recipient'])
                message += '\nSender: '+ json.dumps(dict['sender'])
                message += '\nSenderIP: ' + json.dumps(dict['senderIP'])
                message += '\nSubject: '+ json.dumps(dict['subject'])
                message += '\nthreatsInfoMap: '+ json.dumps(dict['threatsInfoMap'])
                message += '\n**********************************************\n\n'
                #mailer.send_email('Proofpoint Alert: ' + key, message)
                #pprint(message)
if message != '':
    mailer.send_email('Proofpoint Alerts', message)
