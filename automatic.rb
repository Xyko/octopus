require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	system("date >> lixo.txt")#;ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
    system("cat #{slp/60}  >> lixo.txt")
	sleep(20)

end