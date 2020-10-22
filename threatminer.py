import sys
import requests
from pprint import pprint
__author__ = "Oto Ricardo"
__copyright__ = "Copyright 2020"
__credits__ = ["Oto Ricardo"]
__license__ = "GPL"
__version__ = "1.0"
__maintainer__ = "Oto Ricardo"
__email__ = "oto.ricardo@protomail.com"
__status__ = "Alpha"
__twitter__ = "@0xOch0"
'''
Please referense the url below get a detailed descriptions on what each command does.
https://www.threatminer.org/api.php

THIS A SCRIPT THAT IS COMMAND-LINE BASED. IT TAKES ONLY 3 ARGUMENTS,
EXAMPLE:
first the name of the script, second the command, lastly the domain or host
> threatminer.py -dw google.com
-dw = domain whois
-dd = domain passive DNS
-du = domain URI (finds the uri linked to a domain)
-dh = domain hash
-ds = domain subdomains
*******
-iw = ip whois
-id = ip passive dns
-iu = ip URI
-ih = ip hash
-ic = ip certificates

To Dos:
[1] Modify script to validate correct input such as -dw when fed an ip would cause an error.
[2] Error handling when get request returns: {'results': [], 'status_code': '404', 'status_message': 'No results found.'}
[3] Tie script to other tools 
'''
if len(sys.argv) != 3:
    print("This script takes arguments!\nExample: " + sys.argv[0][-14:] + " -w google.com")
else:
    command_ = sys.argv[1]
    obj_ = sys.argv[2]
    var_= ''
    opt_ = []
    if command_ == '-dw':
        var_ = '1'
        opt_ = 'domain'
    elif command_ == '-dd':
        var_ = '2'
        opt_ = 'domain'
    elif command_ == '-du':
        var_ = '3'
        opt_ = 'domain'
    elif command_ == '-dh':
        var_ = '4'
        opt_ = 'domain'
    elif command_ == '-ds':
        var_ = '5'
        opt_ = 'domain'
    elif command_ == '-iw':
        var_ = '1'
        opt_ = 'host'
    elif command_ == '-id':
        var_ = '2'
        opt_ = 'host'
    elif command_ == '-iu':
        var_ = '3'
        opt_ = 'host'
    elif command_ == '-ih':
        var_ = '4'
        opt_ = 'host'
    elif command_ == '-ic':
        var_ = '5'
        opt_ = 'host'

    headers = {
        'Accept': 'application/json',
        'user-agent': 'Python Client'
    }
    url = f'https://api.threatminer.org/v2/{opt_}.php?q={obj_}&rt={var_}'
    print(url)
    response = requests.get(url=url, headers=headers) # add verify=False if you have issues with SSL certs.
    pprint(response.json())
    
