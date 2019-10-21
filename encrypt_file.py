#!/usr/bin/env python3
#This is a simple script to encrypt a file with only on line of data.
#Print statements are there for testing, remove print statements if needed.

from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import base64
    
####Use 16-byte key.
key = b'This is 16 Bytes'
print("Key: " + str(key))

####Base64 encode keyy.
keystr = base64.b64encode(key)
print("Base64 encoded key: " + str(keystr))

####Generate Inizialization Vector
iv = get_random_bytes(16)
print('Randomly generated iv: ' + str(iv))

####Input what to encrypt. Opens a file called file with one line.
with open('file', 'rb') as f:
    for line in f:
          line = line.strip()
print("Data to be encrypted: " + str(line))

#Encrypt message
cipher = AES.new(key, AES.MODE_CFB, iv)
msg = cipher.encrypt(line)
print('Encrypted & Base64 Encoded Secret: ' + str(base64.b64encode(msg)))
