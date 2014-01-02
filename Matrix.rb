# -*- encoding : utf-8 -*-
require 'rubygems'
require 'slop'
require 'time_difference'
require "redis"

load 'Player.rb'
load 'World.rb'
load 'Village.rb'

class Matrix

	def initialize(options = {})

		puts %x(./tribal.sh) if TimeDifference.between(Time.now, File.mtime(File.expand_path(File.dirname(__FILE__) ).to_s + '/playerbr44.txt')).in_hours > 6

		puts "Classe instanciada..."
		@world   = World.new
		@player  = Player.new
		@target  = Player.new

    @world.name     = options[:world]
    @player.name    = options[:login]
    @player.passwd  = options[:passwd]
    @world.archers  = true if options[:archers]
    @world.nologin  = true if options[:nologin]    

    @dia 						= options[:date][0] if options[:date]
    @mes 						= options[:date][1] if options[:date]
    @hora 					= options[:date][2] if options[:date]
    @minuto 				= options[:date][3] if options[:date]

    @xtarget 				= options[:target][0] if options[:target]
    @ytarget 				= options[:target][1] if options[:target]

    @target.name    = options[:message][0] 

		puts "Loading data and login...."

		@world.get_knowledge_base
		@world.get_players.each { |key, value|
			if key[:name].eql? @player.name 
				@player.id       = value[:id]
				@player.ally_id  = value[:ally_id]
				@player.points   = value[:points]
				@player.rank     = value[:rank]
			end
	
			if key[:name].eql? @target.name
				@target.id       = value[:id]
				@target.ally_id  = value[:ally_id]
				@target.points   = value[:points]
				@target.rank     = value[:rank]
			end
		}

		@world.get_allys.each {|key, value|
			if value[:id].eql? @player.ally_id
				@player.ally_name = value[:name]
				@player.ally_tag  = key[:tag]
			end 
		}
		@player.villages = Hash.new
		@world.get_villages.each {|key, value|
			if value[:user_id].eql?  @player.id
				@player.villages[value[:id]] = 
				Village.new(
					:name     => value[:name],
					:id       => value[:id],
					:xcoord   => value[:xcoord],
					:ycoord   => value[:ycoord],
					:user_id  => value[:user_id])
			end 
		}
		@target.villages = Hash.new
		@world.get_villages.each {|key, value|
			if value[:user_id].eql?  @target.id
				@target.villages[value[:id]] = 
				Village.new(
					:name     => value[:name],
					:id       => value[:id],
					:xcoord   => value[:xcoord],
					:ycoord   => value[:ycoord],
					:user_id  => value[:user_id])
			end 			
		}

	end



	def test(msg)
		redis = Redis.new(:host => "127.0.0.1", :port => 6379)

		case msg[0]
		when "set"
			redis.set(msg[1], msg[2])
		when "get"
			puts redis.get(msg[1])			
		end

	end

	def transform(d)
		return "#{format("%02i",d.hour)}:#{format("%02i",d.min)}:#{format("%02i",d.sec)}"
	end

	def arquivo(msg)
		f = File.open("ataque.txt", 'w')
	  t = Time.new(2013, @mes, @dia, @hora, @minuto, 0)
		f.puts "Ataque contra #{@target.name}"
		@player.villages.each  {|okey, ovalue|
	    xi = ovalue.xcoord.to_i
	    yi = ovalue.ycoord.to_i
			first = true
	  	@target.villages.each  {|tkey, tvalue|
	  		f.puts "#{ovalue.name}" if first
	  		first = false
		    xf 		= tvalue.xcoord.to_i
		    yf 		= tvalue.ycoord.to_i
				d 		= Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
				dist 	= format("%.1f",Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2))
				cv 		= t - 11 * d * 60
    		w  		= t - 22 * d * 60
    		c 		= t - 30 * d * 60
    		s  		= t - 35 * d * 60
		    f.puts format("#{ovalue.xcoord}:#{ovalue.ycoord} => #{tvalue.xcoord}:#{tvalue.ycoord} %8s %8s %8s %8s %5s \n", 
		      transform(cv),
		      transform(w),
		      transform(c),              
		      transform(s),              
		      dist) 

	  	}
	  	f.puts "     "
  	}
	end

	def progressivo(msg)
			f = File.open("ataque.txt", 'w')
		  t = Time.new(2013, @mes, @dia, @hora, @minuto, 0)
			f.puts "Ataque contra #{@target.name}"
			@player.villages.each  {|okey, ovalue|
		    xi = ovalue.xcoord.to_i
		    yi = ovalue.ycoord.to_i
				first = true
		  	@target.villages.each  {|tkey, tvalue|
		  		f.puts "#{ovalue.name}" if first
		  		first = false
			    xf 		= tvalue.xcoord.to_i
			    yf 		= tvalue.ycoord.to_i
					d 		= Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
					dist 	= format("%.1f",Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2))
					cv 		= t - 11 * d * 60
	    		w  		= t - 22 * d * 60
	    		c 		= t - 30 * d * 60
	    		s  		= t - 35 * d * 60
			    f.puts format("#{ovalue.xcoord}:#{ovalue.ycoord} => #{tvalue.xcoord}:#{tvalue.ycoord} %8s %8s %8s %8s %5s \n", 
			      transform(cv),
			      transform(w),
			      transform(c),              
			      transform(s),              
			      dist) 

		  	}
		  	f.puts "     "
	  	}
		end


		def orda(msg)

			@vetAttack = Hash.new
			t = Time.new(2014, 12, 2, 18, 4, 0)
			xi = msg[0].split("|")[0].to_i
			yi = msg[0].split("|")[1].to_i
			v = msg[1]
			msg.each_index{|idx| 
				if idx > 1	
					xf = msg[idx].split("|")[0].to_i
					yf = msg[idx].split("|")[1].to_i
					d 		= Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
					dist 	= format("%.1f",Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2))
					hora  = transform(t - 10 * d * 60)
					name  = @world.getVillageByCoords(xf,yf)
					#puts "#{@world.getVillageByCoords(xf,yf)} #{xf} #{yf} #{dist} #{hora}"
			    puts format("#{xi}:#{yi} => #{xf}:#{yf} %25s %8s %8s\n",name,dist, hora)

				end
			}

		end

#ruby Matrix.rb  -p barbara -l xykoBR -w br56 -c orda -m "564|510:spy=5:564|507:561|509:565|513:567|510:567|512:561|508:566|510:564|512:562|510:568|510:560|509:560|511:563|514:562|511:560|508:559|510:563|505:569|509:562|515:566|515:560|506:568|514:567|515:569|513"


# Marcus Vinícius Travassos Haickel de Oliveira
# 41 3941-2545
# contato@zero3games.com.br



end






opts = Slop.parse(:help => true, :strict => true) do
  on '-v', 'Print the version' do
    puts "Version 1.0"
  end
  on :w, :world=,   'Your world',  :required => true
  on :l, :login=,   'Your login',  :required => true
  on :p, :passwd=,  'Your passwd',  :required => true
  on :t, :target=,  'Target coords', as: Array,  delimiter: ':'
  on :d, :date=,		'DateTime do attack', as: Array,  delimiter: ':'
  on :c, :command=, 'Your command'
  on :m, :message=, 'Option message to send', as: Array,  delimiter: ':'
end

# #begin
matrix = Matrix.new(opts.to_hash)
matrix.send(opts.to_hash[:command],opts.to_hash[:message])

