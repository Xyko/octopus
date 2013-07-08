# -*- encoding : utf-8 -*-
require 'rubygems'
require 'mechanize'
require 'logger'
require 'hpricot'
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'rufus/scheduler'
require "highline/system_extensions"
include HighLine::SystemExtensions


load "Tribal.rb"

options = OpenStruct.new
options.library = []
options.inplace = false
options.encoding = "utf8"
options.transfer_type = :auto
options.verbose = false
opts = OptionParser.new do |opts|

	opts.banner = "Usage: tribal.rb -w world -c [cronattack|spy|check|farm|fake|ally|targets|incoming|screate|skill|rename|plan|planattack] [options]"
	opts.separator ""
	opts.separator "Specific options:"
	# Optional argument with keyword completion.

	opts.on("-q","--query [QUERY]") do |n|	
		options.query = n 
	end
	opts.on("-l","--list [LIST]") do |n|	
		options.list = n 
	end
	opts.on("-t","--time [TIME]") do |n|	
		options.time = n 
	end
	opts.on("-v","--village [VILLAGE]") do |n|	
		options.village_name = n 
	end
	opts.on("-w","--world [WORLD]") do |n|	
		options.world_name = n 
	end
	opts.on("-c","--c [COMMAND]", [:cronattack, :spy, :check, :farm, :fake, :ally, :targets, :teste, :incoming, :clean, :skill, :screate, :rename, :plan, :planattack],
		"Select command type (cronattack, spy, check, farm, fake, ally, targets, incoming, clean, screate, skill, rename, plan, planattack)") do |c|
		options.c_type = c
	end

	opts.on_tail("-h", "--help", "Show this message") do
		puts opts
		exit(0)
	end

end
opts.parse!(ARGV)

def errorMsg
	puts ""
	puts "os parametros world e command são obrigatórios.xxx"
	# exec("cd {File.expand_path(File.dirname(__FILE__) ).to_s};ruby Tribal.rb -h")
	# puts "os parametros world e command são obrigatórios."
	puts ""
	exit(0)
end

errorMsg if options.world_name.nil?
errorMsg if options.c_type.nil?

name   = "xykoBR"
passwd = "barbara"
world  = options.world_name

tw = Tribal.new(:name => name,:passwd => passwd,:world => world)

tw.connect
puts "Connected: #{tw.logged?}"

archers = false
archers = true  if world.eql? "br48"
tw.atualiza_tropas(archers) 

case options.c_type
	when :spy
		puts "spy+"
		tw.attackSpy(options.village_name)
	when :farm
		puts "farm+"
		tw.farmAll(true)
	when :fake
		puts "fake+"
		tw.fake("")
	when :ally
		puts "Executando ally..."
		tw.ally(options.ally_name)
	when :targets
		puts "Executando targets..."
		tw.targets
	when :incoming
		puts "Executando incoming"
		tw.incoming
	when :clean
		puts "Executando clean..."
		tw.cleanReports
	when :skill
		puts "Executando skill..."
		tw.sendSnobtoKill
	when :screate
		puts "Executando screate..."
		tw.snobCreate
	when :rename
		puts "Executando rename..."
		tw.rename	
	when :plan
		puts "Executando plan..."
		tw.plan(options.village_name)	
	when :planattack
		puts "Executando planAttack..."
		if options.query.eql? nil
			tw.planAttack(options.village_name,options.time) {true}
		else
			tw.planAttack(options.village_name,options.time) {options.query}
		end	
	when :cronattack
		puts "Executando cronattack..."
		tw.cronattack(options.village_name,options.time,options.list)
	when :teste
		puts "Executando teste..."
		tw.teste("623|327,624|333","archer=10 heavy=8"	,"2013-07-07 07:40:00")
	else
		puts "Vazia..."
end






