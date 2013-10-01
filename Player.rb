# -*- encoding : utf-8 -*-
require 'rubygems'

class Player

	attr_accessor  :name, :id, :passwd, 
	:ally_id, :ally_name, :ally_tag, 
	:points, :rank, 
	:villages,
	:targets,
	:principal,
	:farm_capacity,
	:reports

	def initialize(options = {})
	end

	def updatecapacity
		farm_capacity = 0
		villages.each{|ville_name,ville|
			farm_capacity += ville.farmed_cap
		}
		return farm_capacity
	end

end

