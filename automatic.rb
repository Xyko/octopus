require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	system( "uptime >> lixo.txt")#;ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
    system('cat "Sleeping #{slp/60} minuts.." >> lixo.txt')
	sleep(1)

end