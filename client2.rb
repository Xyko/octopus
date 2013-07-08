# -*- encoding : utf-8 -*-
require 'socket'

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

#s.send("jobs\0",0)
s.send("08/07/2013 19:49:00,623|327,615|345,heavy=1357 axe=2762\0",0)

s.flush
s.close


