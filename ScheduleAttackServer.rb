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
require 'socket'
require 'time_diff'

load "Tribal.rb"
load "World.rb"

server = TCPServer.open(2000)

log  = Logger.new("schedule.log") 
log.level = Logger::INFO  

log.info("Iniciado em: #{Time.new.localtime}")
scheduler = Rufus::Scheduler.start_new

loop {
	Thread.start(server.accept) do |client|
		while client
			incomingData = client.gets("\0")
			if incomingData != nil
				incomingData = incomingData.chomp
			end
			if incomingData == "jobs\0"
				log.info "#{incomingData} => #{scheduler.all_jobs.methods.sort}"
				client.close
				break
			end
			if incomingData == "bye\0"
				log.info("Received: bye, closed connection")
				client.close
				break
			else
				log.info("#{incomingData}")
				msg = incomingData.split(",")
				timeToStart = Time.diff(Time.now, Time.parse(msg[0]))
				log.info("#{timeToStart}")
				seconds = 
				timeToStart[:day] 		* 24 	* 3600  + 
				timeToStart[:hour] 		* 3600  		+ 
				timeToStart[:minute] 	* 60 			+ 
				timeToStart[:second]

				log.info("Executei o schedule em #{msg[0]} = #{seconds}")
				log.info("Origem         : #{msg[1]} ")
				log.info("Destino        : #{msg[2]} ")
				log.info("Vetor de ataque: #{msg[3]} ")


				scheduler.in "#{seconds}s".to_s do
					name   = "xykoBR"
					passwd = "barbara"
					world  = "br48"
					tw = Tribal.new(:name => name,:passwd => passwd,:world => world)
					tw.connect
					log.info("Connected: #{tw.logged?}")

					@vetAttack = Hash.new
					msg[3].split(" ").each {|troop|
						unit = troop.split("=")[0]
						qtd  = troop.split("=")[1]
						@vetAttack = @vetAttack.merge(tw.setTroops "spy=#{qtd.to_i}")   	if unit.eql? "spy"
						@vetAttack = @vetAttack.merge(tw.setTroops "heavy=#{qtd.to_i}") 	if unit.eql? "heavy"
						@vetAttack = @vetAttack.merge(tw.setTroops "light=#{qtd.to_i}") 	if unit.eql? "light"
						@vetAttack = @vetAttack.merge(tw.setTroops "marcher=#{qtd.to_i}") 	if unit.eql? "marcher"
						@vetAttack = @vetAttack.merge(tw.setTroops "archer=#{qtd.to_i}") 	if unit.eql? "archor"
						@vetAttack = @vetAttack.merge(tw.setTroops "spear=#{qtd.to_i}") 	if unit.eql? "spear"
						@vetAttack = @vetAttack.merge(tw.setTroops "axe=#{qtd.to_i}") 		if unit.eql? "axe"
						@vetAttack = @vetAttack.merge(tw.setTroops "sword=#{qtd.to_i}") 	if unit.eql? "sword"
						@vetAttack = @vetAttack.merge(tw.setTroops "ram=#{qtd.to_i}") 		if unit.eql? "ram"
						@vetAttack = @vetAttack.merge(tw.setTroops "catapult=#{qtd.to_i}") 	if unit.eql? "catapult"
						@vetAttack = @vetAttack.merge(tw.setTroops "snob=#{qtd.to_i}") 		if unit.eql? "snob"
						@vetAttack = @vetAttack.merge(tw.setTroops "knight=#{qtd.to_i}") 	if unit.eql? "knight"
					}

					villageFrom = tw.getVillageCoord(msg[1])
					villageTo   = tw.getVillageCoord(msg[2])

					tw.ataqueTropas(villageFrom,villageTo,@vetAttack,"attack")

				end

				# client.puts "#{incomingData}"
				# client.flush
			end
		end
	end
}



