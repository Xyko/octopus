# -*- encoding : utf-8 -*-
require 'rubygems'

class Village

	attr_accessor  :id, :name, :xcoord, :ycoord, :user_id, :spear, :sword, :axe, 
	:spy, :light,  :heavy, :ram, :catapult, :knight, :snob, :wood, :clay, :iron, :delete,
	:spear_cap, :sword_cap, :axe_cap, :light_cap,  :heavy_cap, :farmed_cap, 
	:distance, :h_capacity, :resources, :continent, :master,
	:spear_vel, :sword_vel, :axe_vel, :spy_vel, :light_vel,  :heavy_vel, :ram_vel, 
	:catapult_vel, :knight_vel, :snob_vel,
	:archer, :marcher, :archer_cap, :marcher_cap, :archer_vel, :marcher_vel

	def initialize(options = {})
		self.h_capacity = 1
		self.name		= options[:name]
		self.xcoord		= options[:xcoord].to_i
		self.ycoord		= options[:ycoord].to_i
		self.user_id	= options[:user_id].to_i
		self.id			= options[:id].to_i	
		self.wood		= options[:wood].to_i	
		self.clay		= options[:clay].to_i	
		self.iron		= options[:iron].to_i
		self.resources	= options[:wood].to_i + options[:clay].to_i + options[:iron].to_i
		self.delete		= options[:delete]
		self.farmed_cap = options[:farmed].to_i
		self.distance	= 0
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
		self.archer		=	18
		self.spear 		= 0
		self.sword		= 0
		self.axe   		= 0
		self.spy 		= 0
		self.light 		= 0
		self.heavy 		= 0
		self.ram 		= 0
		self.catapult 	= 0
		self.knight 	= 0
		self.snob 		= 0
		self.continent	= self.ycoord.to_s[0]+self.xcoord.to_s[0]
	end

	def getVar(info)
		return self.instance_variable_get("@#{info}") if instance_variable_defined?("@#{info}")
	end
	def setVar(info,value)
		return self.instance_variable_set("@#{info}",value) if instance_variable_defined?("@#{info}")
	end

	def farmed_cap
		self.farmed_cap = 	self.spear_cap.to_i	* self.spear.to_i	+
							self.sword_cap.to_i	* self.sword.to_i	+
							self.axe_cap.to_i	* self.axe.to_i		+
							self.light_cap.to_i	* self.light.to_i	+
							self.heavy_cap.to_i	* self.heavy.to_i
	end


end
