require 'rubygems'
require 'logger'

  log  = Logger.new("a.log") 
  log.level = Logger::INFO

tst = true
while tst

	slp = 60 * (15 + Random.rand(15))
	time1 = Time.now
	time2 = time1 + slp
	log.info(sprintf "Current Time : %s/%s   %s:%s -> %s:%s.\n",
	time1.day.to_s,
	time1.month.to_s,
	time1.hour.to_s,
	time1.min.to_s,
	time2.hour.to_s,
	time2.min.to_s)
	system("ruby Tribal.rb -c farm -w br48")
	log.info("sleeping....")
	if $?.exitstatus != 0
		log.fatal("saida inexperada....")
	end
	sleep(slp)

end
