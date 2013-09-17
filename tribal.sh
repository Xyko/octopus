#/bin/bash
wget http://br48.tribalwars.com.br/map/player.txt -O /tmp/playerbr48.txt
wget http://br48.tribalwars.com.br/map/village.txt -O /tmp/villagebr48.txt
wget http://br48.tribalwars.com.br/map/ally.txt -O /tmp/allybr48.txt
if [ -f playerbr48.txt ]
then
 rm playerbr48.txt
fi
if [ -f villagebr48.txt ]
then
 rm villagebr48.txt
fi
if [ -f allybr48.txt ]
then
 rm allybr48.txt
fi
mv /tmp/playerbr48.txt . 
mv /tmp/villagebr48.txt . 
mv /tmp/allybr48.txt . 

#/bin/bash
wget http://br44.tribalwars.com.br/map/player.txt -O /tmp/playerbr44.txt
wget http://br44.tribalwars.com.br/map/village.txt -O /tmp/villagebr44.txt
wget http://br44.tribalwars.com.br/map/ally.txt -O /tmp/allybr44.txt
if [ -f playerbr44.txt ]
then
 rm playerbr44.txt
fi
if [ -f villagebr44.txt ]
then
 rm villagebr44.txt
fi
if [ -f allybr44.txt ]
then
 rm allybr44.txt
fi
mv /tmp/playerbr44.txt . 
mv /tmp/villagebr44.txt . 
mv /tmp/allybr44.txt . 


#/bin/bash
wget http://br52.tribalwars.com.br/map/player.txt -O /tmp/playerbr52.txt
wget http://br52.tribalwars.com.br/map/village.txt -O /tmp/villagebr52.txt
wget http://br52.tribalwars.com.br/map/ally.txt -O /tmp/allybr52.txt
if [ -f playerbr52.txt ]
then
 rm playerbr52.txt
fi
if [ -f villagebr52.txt ]
then
 rm villagebr52.txt
fi
if [ -f allybr52.txt ]
then
 rm allybr52.txt
fi
mv /tmp/playerbr52.txt . 
mv /tmp/villagebr52.txt . 
mv /tmp/allybr52.txt . 
