# -*- encoding : utf-8 -*-
require 'rubygems'

class Village

	attr_accessor  :id, :name, :xcoord, :ycoord, :user_id, 
	:spear, 	:spear_cap, 	:spear_vel, 	:spear_def,		:spear_atck	,		
	:sword, 	:sword_cap, 	:sword_vel, 	:sword_def,		:sword_atck	,		
	:axe, 		:axe_cap,		:axe_vel,		:axe_def,		:axe_atck	,		
	:archer,	:archer_cap,	:archer_vel,	:archer_def,	:archer_atck	,	
	:spy, 		:spy_cap, 		:spy_vel, 		:spy_def,		:spy_atck	,		
	:light, 	:light_cap, 	:light_vel, 	:light_def, 	:light_atck	, 	
	:marcher,	:marcher_cap,	:marcher_vel,	:marcher_def, 	:marcher_atck	, 	
	:heavy, 	:heavy_cap, 	:heavy_vel, 	:heavy_def, 	:heavy_atck	, 	
	:ram, 		:ram_cap, 		:ram_vel, 		:ram_def, 		:ram_atck	, 		
	:catapult, 	:catapult_cap, 	:catapult_vel, 	:catapult_def, 	:catapult_atck	, 
	:knight, 	:knight_cap, 	:knight_vel, 	:knight_def, 	:knight_atck	, 	
	:snob, 		:snob_cap, 		:snob_vel, 		:snob_def, 		:snob_atck	, 		
	:wood, :stone, :iron, 
	:delete,
	:farmed_cap, 
	:distance, :h_capacity, :resources, :continent, :master,
	:defense_cap,
	:attack_cap,
	:capacity

	def initialize(options = {})

		self.h_capacity = 1
		self.name		= options[:name]
		self.xcoord		= options[:xcoord].to_i
		self.ycoord		= options[:ycoord].to_i
		self.user_id	= options[:user_id].to_i
		self.id			= options[:id].to_i	
		self.wood		= options[:wood].to_i	
		self.stone		= options[:stone].to_i	
		self.iron		= options[:iron].to_i
		self.resources	= options[:wood].to_i + options[:stone].to_i + options[:iron].to_i
		self.delete		= options[:delete]
		self.farmed_cap = options[:farmed].to_i
		self.distance	= 0
		self.defense_cap= 0
		self.attack_cap = 0
		self.capacity = 0
		
		self.spear_cap 	= 25 * h_capacity.to_i
		self.sword_cap	= 15 * h_capacity.to_i
		self.axe_cap   	= 10 * h_capacity.to_i
		self.light_cap 	= 80 * h_capacity.to_i
		self.heavy_cap 	= 50 * h_capacity.to_i
		self.marcher_cap= 50 * h_capacity.to_i
		self.archer_cap = 10 * h_capacity.to_i

		self.spear_vel	=	18 
		self.sword_vel	=	22 
		self.axe_vel	=	18 
		self.spy_vel	=	 9 
		self.light_vel	=	10  
		self.heavy_vel	=	11 
		self.ram_vel	=	30 
		self.catapult_vel=	30 
		self.knight_vel	=	10 
		self.snob_vel	=	35
		self.marcher_vel=	10
		self.archer_vel	=	18

		self.spear_atck	=	10 
		self.sword_atck	=	25 
		self.axe_atck	=	40 
		self.archer_atck=	15
		self.spy_atck	=	 0 
		self.light_atck	=  130  
		self.marcher_atck= 120
		self.heavy_atck	=  150 
		self.ram_atck	=	 2 
		self.catapult_atck=100 
		self.knight_atck=  150 
		self.snob_atck	=	30

		self.spear_def	=	15
		self.sword_def	=	50 
		self.axe_def	=	10 
		self.archer_def=	50
		self.spy_def	=	 2 
		self.light_def	=	30 
		self.marcher_def=	40 
		self.heavy_def	=  200 
		self.ram_def	=	20 
		self.catapult_def= 100 
		self.knight_def =  250
		self.snob_def	=  100

		self.spear 		= 0
		self.sword		= 0
		self.axe   		= 0
		self.archer 	= 0
		self.spy 		= 0
		self.light 		= 0
		self.marcher 	= 0
		self.heavy 		= 0
		self.ram 		= 0
		self.catapult 	= 0
		self.knight 	= 0
		self.snob 		= 0

		self.continent	= self.ycoord.to_s[0]+self.xcoord.to_s[0]

	end

	def setresources(wood,stone,iron,capacity)
		self.wood		= wood.to_i	
		self.stone		= stone.to_i	
		self.iron		= iron.to_i
		self.capacity = capacity
	end

	def explain_cap
		puts "Spear   #{self.spear_cap.to_i 	* self.spear.to_i 		}"
		puts "Sword   #{self.sword_cap.to_i	* self.sword.to_i 		}"
		puts "Axe     #{self.axe_cap.to_i   	* self.axe.to_i 		  }"	 	
		puts "Light   #{self.light_cap.to_i 	* self.light.to_i 	 	}"
		puts "Heavy   #{self.heavy_cap.to_i 	* self.heavy.to_i 	 	}"
		puts "Marcher #{self.marcher_cap.to_i* self.marcher.to_i 	}"
		puts "Archer  #{self.archer_cap.to_i * self.archer.to_i 	}" 
	end 



	def getVar(info)
		return self.instance_variable_get("@#{info}") if instance_variable_defined?("@#{info}")
	end
	def setVar(info,value)
		return self.instance_variable_set("@#{info}",value) if instance_variable_defined?("@#{info}")
	end

	def farmed_cap
		self.farmed_cap = self.spear_cap.to_i	* self.spear.to_i	+
							self.sword_cap.to_i	* self.sword.to_i	+
							self.axe_cap.to_i	* self.axe.to_i		+
							self.light_cap.to_i	* self.light.to_i	+
							self.heavy_cap.to_i	* self.heavy.to_i
	end

	def defense_cap
		self.defense_cap = 	
		self.spear_def.to_i		* self.spear.to_i	+
		self.sword_def.to_i		* self.sword.to_i	+
		self.axe_def.to_i		* self.axe.to_i		+
		self.archer_def.to_i	* self.light.to_i	+
		self.spy_def.to_i		* self.spy.to_i		+
		self.light_def.to_i		* self.light.to_i	+
		self.marcher_def.to_i	* self.marcher.to_i	+
		self.heavy_def.to_i		* self.heavy.to_i	+
		self.ram_def.to_i		* self.ram.to_i		+
		self.catapult_def.to_i	* self.catapult.to_i+
		self.knight_def.to_i	* self.knight.to_i	+
		self.snob_def.to_i		* self.snob.to_i
	end

	def attack_cap
		self.attack_cap = 
		self.spear_atck.to_i	* self.spear.to_i	+
		self.sword_atck.to_i	* self.sword.to_i	+
		self.axe_atck.to_i		* self.axe.to_i		+
		self.archer_atck.to_i	* self.light.to_i	+
		self.spy_atck.to_i		* self.spy.to_i		+
		self.light_atck.to_i	* self.light.to_i	+
		self.marcher_atck.to_i	* self.marcher.to_i	+
		self.heavy_atck.to_i	* self.heavy.to_i	+
		self.ram_atck.to_i		* self.ram.to_i		+
		self.catapult_atck.to_i	* self.catapult.to_i+
		self.knight_atck.to_i	* self.knight.to_i	+
		self.snob_atck.to_i		* self.snob.to_i	
	end

end
