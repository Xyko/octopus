# -*- encoding : utf-8 -*-
require 'socket'

hostname = '199.180.129.116'

#hostname = 'localhost'

port = 2000

s = TCPSocket.open(hostname, port)

s.send("2013-07-07 07:33:00,616|321,617|321,spy=10\0",0)



s.send("bye\0",0)
s.flush
s.close




#ruby TribalCommands.rb -w br48 -c cronattack -v "636|331" -t "07/07/2013 05:30:00" -l "spy"|grep 251







