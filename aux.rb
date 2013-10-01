require 'rubygems'



x = [1,2,3,4,5,6,7,8,9]

while x.size > 0
	puts x.size
	x.delete_at(rand(x.size))
end





