require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	system( "uptime >> lixo.txt;ruby Tribal.rb -c farm >> lixo.txt")
	break if $?.exitstatus != 0
    puts "Sleeping #{slp/60} minuts.."
	sleep(slp)

end