require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	f = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + "controle","w+")
	time1 = Time.now
	agora = "Current Time : " + time1.day.to_s +  "/" +time1.month.to_s + " "+ time1.hour.to_s + ":" + time1.min.to_s + ":" + time1.sec.to_s
	f.puts agora 
	#system("ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
	sleep(20)

end