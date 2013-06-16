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

