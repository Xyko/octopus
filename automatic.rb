require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	f = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + "/controle","a")
	slp = 60 * (30 + Random.rand(30))
	time1 = Time.now
	time2 = time1 + slp
	timeInfo = sprintf "Current Time : %s/%s   %s:%s -> %s:%s.\n",
	time1.day.to_s,
	time1.month.to_s,
	time1.hour.to_s,
	time1.min.to_s,
	time2.hour.to_s,
	time2.min.to_s
	puts timeInfo
	f.puts timeInfo
	system("ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
	f.close unless f.closed?
	sleep(slp)

end