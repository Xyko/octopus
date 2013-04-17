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

