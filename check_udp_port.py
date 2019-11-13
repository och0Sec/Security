#!/usr/bin/python
import socket
# Open a raw socket listening on all ip addresses

def send_udp():

    UDP_IP = "ip_address" #This is the destination IP.
    UDP_PORT = port_number
    MESSAGE = "Hello, World!" #Can be whatever

#defines the socket and sends message
    sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))
def listen_for_icmp():
    #Defines a listening socket to for ICMP - Closed UDP ports send an ICMP unreacheable message.
    sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
    
    sock.bind(('local_ip_address', 1)) #Give it your computer's local IP.
    data = sock.recv(1024)

    # ip header is the first 20 bytes
    ip_header = data[:20]

    # ip source address is 4 bytes and is second last field (dest addr is last)
    ips = ip_header[-8:-4]

    # convert to dotted decimal format
    source = '%i.%i.%i.%i' % (ord(ips[0]), ord(ips[1]), ord(ips[2]), ord(ips[3]))

    print 'Port closed from %s' % source
'''
MAIN
'''
try :
   while True :
    send_udp()
    listen_for_icmp()
      
except KeyboardInterrupt :
   print ''
