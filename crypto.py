from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import base64
    
key = b'Sixteen byte key'
iv = get_random_bytes(16)
secret = b'Attack at dawn'
print('Secret Message: ' + str(secret))
print('IV: ' + str(iv))
print('key: ' + str(key))

#Base64 Encode:
keystr = base64.b64encode(key)
print("Base64 encoded key: " + str(keystr))

#Decode Base64:
s = base64.b64decode(keystr)
print("Base64 decoded key: " + str(s))

#Encryption
cipher = AES.new(key, AES.MODE_CFB, iv)
msg = iv + cipher.encrypt(secret)
print('Encrypted & Base64 Encoded Secret: ' + str(base64.b64encode(msg)))

#Decryption
cipher = AES.new(key, AES.MODE_CFB, iv)
text = cipher.decrypt(msg)
print('Decrypted Message: ' + str(text))
