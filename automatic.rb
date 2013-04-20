require 'rubygems'

tst = true
while tst

	slp = 60 * (30 + Random.rand(30))
	f = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + "controle","w+")
	f.puts DateTime.now 
	#system("ruby Tribal.rb -c farm")
	break if $?.exitstatus != 0
	sleep(20)

end