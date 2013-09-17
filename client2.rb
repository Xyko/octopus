# -*- encoding : utf-8 -*-
require 'socket'

hostname = '199.180.129.116'
port = 2000

s = TCPSocket.open(hostname, port)

s.send("jobs\0",0)

s.flush
s.close


