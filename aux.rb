require 'rubygems'

xi=10
yi=14
zi=7
xf=0
yf=0
zf=0
recursos=28

puts "#{xi} #{yi} #{zi}"
puts "#{xf} #{yf} #{zf}"

while recursos >= 3

	if recursos > 0
		if xi > 0
			xf += 1
			recursos -= 1
		end
	end

	if recursos > 0
		if yi > 0
			yf += 1
			recursos -= 1
		end
	end

	if recursos > 0
		if zi > 0
			zf += 1
			recursos -= 1
		end
	end

end

puts "#{xi} #{yi} #{zi}"
puts "#{xf} #{yf} #{zf}"












