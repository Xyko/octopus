require 'rubygems'
require 'logger'

log  = Logger.new("a.log") 
log.level = Logger::INFO

tst = true
while tst

	slp = 60 * (15 + Random.rand(15))
	log.info(sprintf "Current Time : %s/%s   %s:%s -> %s:%s.\n",
	time1.day.to_s,
	time1.month.to_s,
	time1.hour.to_s,
	time1.min.to_s,
	time2.hour.to_s,
	time2.min.to_s)
	time1 = Time.now
	time2 = time1 + slp
	time2 = time1 + slp
	system("ruby Tribal.rb -c farm")
	log.info("sleeping....")
	if $?.exitstatus != 0
		info.fatal("saida inexperada....")
	end
	sleep(slp)

end