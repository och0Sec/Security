#"This is a script that will make API calls to crxcavator.io to get a name a risk score on Chrome Extensions intalled on a Windows machine"
#Example: Computer > crxposer.py localhost

__author__ = "Oto Ricardo"
__copyright__ = "Copyright 2020"
__credits__ = ["Oto Ricardo", "Aaron H"]
__license__ = "GPL"
__version__ = "1.0"
__maintainer__ = "Oto Ricardo"
__email__ = "oto.ricardo@protomail.com"
__status__ = "Production"

import requests
import sys
from pprint import pprint
import os
import json

def get_info(crxkey):
    webstore_ = ''
    risk_ = ''
    dict_ = {}
    headers = {
        'Accept': 'application/json',
        'Key': 'API_KEY_GOES_HERE', # ADD YOUR API KEY HERE, YOU CAN GET IT FROM HTTPS://CRXCAVATOR.IO WHEN YOU SIGN UP FOR A FREE ACCOUNT
        'user-agent': 'Python Client'
    }
    url = 'https://api.crxcavator.io/v1/report/' + crxkey
    response = requests.get(url=url, headers=headers, verify=False)
    response = response.json()
    if response == None:
        print(f"[*] INFO - {crxkey} was not found in database!")
    else:
        webstore_ = response[0]['data']['webstore']
        risk_ = response[0]['data']['risk']
        dict_.update(webstore_)
        dict_.update(risk_)
        return dict_

if __name__ == "__main__":
    if len(sys.argv) == 1 or len(sys.argv) > 2:
        print("This script takes one argument!\nExample: " + sys.argv[0] + " computerName")
    else:

        computer = sys.argv[1]
        sketchy = []
        badkeys = []
        whitelist = []
        print(f"[*] - Connection to computer {computer}")
        if os.path.exists(f'\\\\{computer}\\C$') == True:
            users = os.listdir(f'\\\\{computer}\\C$\\Users\\')
            for user in users:
                if user == 'All Users' or user == 'Default' or user== 'Default User' or user == 'desktop.ini' or user =='Public':
                    pass
                else:
                    #print(f'[*] - Analysing User: {user}')
                    if os.path.exists(f'\\\\{computer}\\C$\\Users\\{user}\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\') == True:
                        print('[*] - Analysing Extensions')
                        crxKeys =os.listdir(f'\\\\{computer}\\C$\\Users\\{user}\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Extensions\\')
                        #print('[*] - Generating Report')
                        for crxKey in crxKeys:
                            if len(crxKey) != 32:
                                print(f'[*] INFO - {crxKey} is not a valid extension ID!')
                                badkeys.append(crxKey)
                            else:
                                mydict = get_info(crxKey)
                                if mydict == None or len(mydict) == 0:
                                    if crxKey not in badkeys:
                                        badkeys.append(crxKey)
                                else:
                                    if int(mydict['total']) > 25  and 'google' not in mydict['offered_by']:
                                        sketchy.append(f"User: {user}, Extension Name: \"{mydict['name']}\", Offered By: {mydict['offered_by']}, Risk Score: {mydict['total']}")

            if len(sketchy) == 0:
                print('YOU ARE LOOKING GREAT!! No sketchy extensions were found!')
            else:
                print('\n\n\n')
                print('You have sketchy extension installed! Check your system!\nSUMMARY:')
                for i in sketchy:
                    print(i)

            if len(badkeys) == 0:
                pass
            else:
                print('\n\n\nThese Chrome extension keys were not found on the CRXCAVATOR.IO database:\n')
                for i in crxKeys:
                    print(i)
        else:
            print(f'Unable to to connect to {computer}. Check you network connetion')

