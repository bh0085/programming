#! /usr/bin/env python

import socket
mySocket = socket.socket ( socket.AF_INET, socket.SOCK_DGRAM )
mySocket.bind ( ( '', 8080 ) )
while True:
   data, client = mySocket.recvfrom ( 100 )
   print('We have received a datagram from', client)
   print( data)
   mySocket.sendto ( b'Green-eyed datagram.', client )

