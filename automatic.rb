require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	f = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + "controle","w+")
	time1 = Time.now
	agora = "Current Time : " + time1.day +  "/" +time1.month + " "+ time1.hour + ":" + time1.min + ":" + time1.sec
	f.puts agora 
	#system("ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
	sleep(20)

end