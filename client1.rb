# -*- encoding : utf-8 -*-
require 'socket'

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)

s.send("2013-07-07 03:27:35,617|326,628|334,spy=450\0",0)
s.send("2013-07-07 02:44:02,616|321,630|333,spy=450\0",0)
s.send("2013-07-07 02:12:24,615|321,634|332,spy=450\0",0)
s.send("2013-07-07 00:55:49,608|320,636|332,spy=450\0",0)
s.send("2013-07-07 02:12:24,616|317,627|336,spy=450\0",0)
s.send("2013-07-07 02:30:00,619|313,631|329,spy=450\0",0)
s.send("2013-07-07 02:12:24,613|321,632|332,spy=450\0",0)
s.send("2013-07-07 02:07:45,613|339,632|327,spy=450\0",0)
s.send("2013-07-07 00:49:41,606|328,637|331,spy=450\0",0)
s.send("2013-07-07 01:52:30,614|321,636|331,spy=450\0",0)

s.send("bye\0",0)
s.flush
s.close










#ruby TribalCommands.rb -w br48 -c cronattack -v "636|331" -t "07/07/2013 05:30:00" -l "spy"|grep 251







