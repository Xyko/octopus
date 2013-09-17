# -*- encoding : utf-8 -*-
require 'socket'

hostname = '199.180.129.116'

#hostname = 'localhost'

port = 2000

s = TCPSocket.open(hostname, port)

s.send("09/07/2013 11:45:00,616|317,616|316,spy=5\0",0)

s.send("bye\0",0)
s.flush
s.close






# ruby TribalCommands.rb -w br48 -c cronattack -v "636|331" -t "07/07/2013 14:00:00" -l "spy"|grep 251


# ruby TribalCommands.rb -w br48 -c cronattack -v "601|355" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "604|346" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "612|350" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "602|347" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "609|366" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "595|357" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "601|348" -t "07/07/2013 14:00:00" -l "spy"
# ruby TribalCommands.rb -w br48 -c cronattack -v "615|345" -t "07/07/2013 14:00:00" -l "spy"



#s.send("07/07/2013 20:00:00,616|321,601|355,spy=450\0",0)
# s.send("07/07/2013 20:01:00,620|346,604|346,spy=450\0",0)

 











