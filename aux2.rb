# -*- encoding : utf-8 -*-
require 'rubygems'


def countdown seconds

	puts 
	for x in (1..seconds).to_a.reverse 
		printf "\b\b" + x.to_s
		sleep 1
	end

end

countdown 20