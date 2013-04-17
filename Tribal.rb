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
load 'Player.rb'
load 'World.rb'
load 'Village.rb'
load "console.rb"


class Tribal

	attr_accessor  :player, :world, :village, :report

	def initialize(options = {})
		 puts "Classe instanciada..." #com options: #{options[:args]}"
		 @logged  = false
		 @player  = Player.new
		 @world   = World.new
		 @tools   = World.new
		 @player.name   = options[:name]
		 @player.passwd = options[:passwd]
		 @world.name    = options[:world]
		 @world.get_knowledge_base
		 @world.get_players.each { |key, value|
				if key[:name].eql? @player.name 
					@player.id       = value[:id]
					@player.ally_id  = value[:ally_id]
					@player.points   = value[:points]
					@player.rank     = value[:rank]
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
				@player.villages[value[:name]] = 
				Village.new(
					:name 	 => value[:name],
					:id 	 => value[:id],
					:xcoord  => value[:xcoord],
					:ycoord  => value[:ycoord],
					:user_id => value[:user_id])
			end 
		}

	end

	def connect
		@logged  = false
		@agent   = Mechanize.new { |a| 
			a.log  = Logger.new("mechanize.log") 
			a.log.level = Logger::INFO
		}
		@agent.user_agent_alias = 'Linux Mozilla'
		page     = @agent.get("http://www.tribalwars.com.br/index.php?action=login&server="+@world.name)
		form     = page.forms.first
		#form.fields.each { |f| puts f.name + "=" + f.value}
		form.field_with(:name => "user").value      = @player.name
		form.field_with(:name => "password").value  = @player.passwd
		form.field_with(:name => "server").value    = @world.name
		@pagePrincipal = @agent.submit(form)
		analisaBot(@pagePrincipal)
		#@html = File.open('teste.html','w'){|f| f.write( @pagePrincipal.body.to_s)}
		@logged =  @pagePrincipal.body.to_s.index('<title>_xykoBR').nil?
	end

	def analisaBot(page)
		 botMsg = "contra Bots"
		 if page.body.to_s.index(botMsg)
			puts "BOT"
			imagens = page.image_urls
			imagens.each do |imagem|
				if imagem.index('captcha') != nil
					@agent.get(imagem).save_as('/Users/francisco/Desktop/bot.png')
				end
				puts imagem
			end
			formCaptcha  = page.forms.first
			formCaptcha.field_with(:name => "code").value = gets.chomp
			page@agent.submit(formCaptcha, formCaptcha.button_with(:value => "Continuar"))
		 else
			 return page
		 end
	end

	def logged?
		return @logged
	end

	def atualiza_tropas
		@player.villages.each  {|key, value|
			pagePlace = @agent.get('http://'+@world.name+'.tribalwars.com.br/game.php?village='+value.id.to_s+'&screen=place')
			analisaBot(pagePlace)
			value.spear    =  pagePlace.link_with(:href => /#unit_input_spear/).text.sub('(','').sub(')','')
			value.sword    =  pagePlace.link_with(:href => /#unit_input_sword/).text.sub('(','').sub(')','')
			value.axe      =  pagePlace.link_with(:href => /#unit_input_axe/).text.sub('(','').sub(')','')
			value.spy      =  pagePlace.link_with(:href => /#unit_input_spy/).text.sub('(','').sub(')','')
			value.light    =  pagePlace.link_with(:href => /#unit_input_light/).text.sub('(','').sub(')','')
			value.heavy    =  pagePlace.link_with(:href => /#unit_input_heavy/).text.sub('(','').sub(')','')
			value.ram      =  pagePlace.link_with(:href => /#unit_input_ram/).text.sub('(','').sub(')','')
			value.catapult =  pagePlace.link_with(:href => /#unit_input_catapult/).text.sub('(','').sub(')','')
			value.knight   =  pagePlace.link_with(:href => /#unit_input_knight/).text.sub('(','').sub(')','')
			value.snob     =  pagePlace.link_with(:href => /#unit_input_snob/).text.sub('(','').sub(')','')
		}
	end


	def janelaSpy(village, tolerance)
		x 	= village.xcoord.to_i
		y 	= village.ycoord.to_i
		id 	= village.id
		vetRet = Hash.new
		cont = 0
		@world.get_villages.each {|key, value|
		if value[:user_id].eql?  "0" 
			_x = value[:xcoord].to_i
			_y = value[:ycoord].to_i
			if 	_x.between?(	x - tolerance	,	x + tolerance	) && 
				_y.between?(	y - tolerance	,	y + tolerance	)
					dist    = Math.sqrt((x - _x) ** 2 + (y - _y) ** 2).to_i
					vetRet["#{_x} #{_y}"] = dist
			end
		end 
		}
		return vetRet
	end



	def getVillage(villageName)
		@player.villages.each  {|key, value|
			if value.name.eql? villageName
				return value
			end
		}
		return @player.villages[@player.villages.keys[rand(@player.villages.size)]]
	end

	def ataqueTropas(fromVillage, toVillage, vTropas, attackType)


			pagePraca  = @agent.get('http://' + @world.name + '.tribalwars.com.br/game.php?village='+fromVillage.id.to_s+'&screen=place')
			analisaBot(pagePraca)
			formPraca  = pagePraca.forms.first

			formPraca.field_with(:name => "x").value = toVillage.xcoord
			formPraca.field_with(:name => "y").value = toVillage.ycoord

			formPraca.field_with(:name => "spear").value	= vTropas["spear"]
			formPraca.field_with(:name => "sword").value 	= vTropas["sword"]
			formPraca.field_with(:name => "axe").value   	= vTropas["axe"]
			formPraca.field_with(:name => "spy").value 	 	= vTropas["spy"]
			formPraca.field_with(:name => "light").value 	= vTropas["light"]
			formPraca.field_with(:name => "heavy").value 	= vTropas["heavy"]
			formPraca.field_with(:name => "ram").value 		= vTropas["ram"]
			formPraca.field_with(:name => "catapult").value = vTropas["catapult"]
			formPraca.field_with(:name => "knight").value 	= vTropas["knight"]
			formPraca.field_with(:name => "snob").value 	= vTropas["snob"]

			pageAtack = @agent.submit(formPraca, formPraca.button_with(:name => attackType))

			# pageAtack1 = @agent.submit(formPraca, formPraca.button_with(:name => "attack"))
			# pageAtack2 = @agent.submit(formPraca, formPraca.button_with(:name => "attack"))
			# pageAtack3 = @agent.submit(formPraca, formPraca.button_with(:name => "attack"))
			# pageAtack4 = @agent.submit(formPraca, formPraca.button_with(:name => "attack"))

			analisaBot(pageAtack)

			formAtack  = pageAtack.forms.first
			
			# formAtack1  = pageAtack1.forms.first
			# formAtack2  = pageAtack2.forms.first
			# formAtack3  = pageAtack3.forms.first
			# formAtack4  = pageAtack4.forms.first

			@agent.submit(formAtack, formAtack.button_with(:value => "Ok"))

			# @agent.submit(formAtack1, formAtack1.button_with(:value => "Ok"))
			# @agent.submit(formAtack2, formAtack2.button_with(:value => "Ok"))
			# @agent.submit(formAtack3, formAtack3.button_with(:value => "Ok"))
			# @agent.submit(formAtack4, formAtack4.button_with(:value => "Ok"))

			return true
	end

	def nearerTo(xi, yi)
		menor = 10
		key   = ""
		@player.villages.each  {|rkey, rvalue|
			xf = rvalue.xcoord.to_i
			yf = rvalue.ycoord.to_i
			dist = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
			if dist <= menor then
				menor = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
				key   = rkey
			end
		}
		#puts "escolhemos a menor distancia = #{menor} /#{@player.targets[key]}"
		return @player.villages[key]
	end

	def checkHaul(ville, target, type)
		haul = ville.getVar("#{type}").to_i * ville.getVar("#{type}_cap").to_i
		if haul >= target.resources
			ville.setVar("#{type}",	target.resources / ville.getVar("#{type}_cap"))
			target.resources = 0
			return ville.getVar("#{type}")
		else
			target.resources -= haul
			ret = ville.getVar("#{type}")
			ville.setVar("#{type}", 0)
			return ret
		end
	end

	def farmAll

		@player.villages.each  {|key, ville|

			@temp_vector = Hash.new

			#ville = @player.villages[@player.villages.keys[0]]

			puts ville.name

			pageReports = @agent.get("http://"+@world.name+".tribalwars.com.br/game.php?village="+firstId.to_s+"&mode=attack&screen=report")
			analisaBot(pageReports)

			links = pageReports.links_with(:href => /(.*mode=attack&view*.)/)

			puts "Analisando #{links.size} relatórios..."
			links.each_with_index do |link,index|
				pageReport = link.click
				analisaBot(pageReport)
				link_to_delete = pageReport.link_with(:href  => /(.*action=del_one*.)/).uri
				coordenadas = link.text
				alvo = coordenadas[coordenadas.rindex('(')+1,coordenadas.rindex(')')-coordenadas.rindex('(')-1].strip.split("|")
				alvo_texto = coordenadas[coordenadas.rindex('(')+1,coordenadas.rindex(')')-coordenadas.rindex('(')-1].strip.split("|")
				xcoord = alvo[0]
				ycoord = alvo[1]
				delete = false

				if !@temp_vector.key?("#{xcoord} #{ycoord}") then

					wood = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
					clay = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
					iron = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
					@capacity = wood + clay + iron

					if wood > 100 || clay > 100 || iron > 100 && wood + clay + iron > 300
						@temp_vector["#{xcoord} #{ycoord}"] = ""
						
						puts "#{index}/#{links.size} Analizando #{xcoord}/#{ycoord} com #{wood+clay+iron}." 

						target = Village.new(
							:xcoord 	=> xcoord,
							:ycoord 	=> ycoord,
							:wood 		=> wood.to_i,
							:clay 		=> clay.to_i,
							:iron 		=> iron.to_i,
							:delete 	=> "")

						@vetAttack = Hash.new
						attackWith(ville, "light") 
						attackWith(ville, "heavy") 
						# attackWith(ville, :walkers) 

						if @vetAttack.size > 0
							@vetAttack = @vetAttack.merge(setTroops "spy=1")
							puts "#{index}/#{links.size} #{ville.name} atacando #{xcoord}/#{ycoord} com #{@vetAttack}. Restam: #{ville.light} #{ville.heavy} #{ville.spear} #{ville.sword} #{ville.axe}"
							ataqueTropas(ville,target,@vetAttack,"attack")
							delete = pageReport.link_with(:href  => /(.*action=del_one*.)/).uri
							pageDelete = @agent.get('http://'+@world.name+'.tribalwars.com.br'+ delete.to_s)
							analisaBot(pageDelete) 
						end


					else
						delete = true
					end
				else
					delete = true
				end
				if delete
					puts "#{index}/#{links.size} cleanReport deleta o relatório #{xcoord} #{ycoord}" 
					pageDelete = @agent.get('http://'+@world.name+'.tribalwars.com.br'+ link_to_delete.to_s)
					analisaBot(pageDelete) 
				end

			end
		}

	end


# 	def farmAll2

# 		ville = @player.villages[@player.villages.keys[0]]

# 		pageReports = @agent.get("http://"+@world.name+".tribalwars.com.br/game.php?village="+firstId.to_s+"&mode=attack&screen=report")

# 		analisaBot(pageReports)

# 		event = pageReports.parser.xpath('//*[@id="report_list"]')

# 		event.children.reverse.each {|e|

# 			case e.elements[0].elements.size.to_s
# 				when "4"
# 					index = 2
# 				when "5"
# 					index = 3
# 				else
# 				  index = 0
# 			end

# 			if index == 2 || index == 3

# 				linkText  = e.elements[0].elements[index].children[1].attribute_nodes[0].to_s
# 				link = pageReports.link_with(:href  => linkText)
# 				pageReport = link.click

# 				wood = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
# 				clay = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
# 				iron = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
# 				@capacity = wood + clay + iron
				
# 				if wood > 25 || clay > 25 || iron > 25

# 					coords = pageReport.parser.xpath('//*[@id="attack_info_def"]')

# 					xcoord = /\([0-9]{3}[|][0-9]{3}\)/m.match(link.text).to_s.gsub(/[()]/,'').split("|")[0]
# 					ycoord = /\([0-9]{3}[|][0-9]{3}\)/m.match(link.text).to_s.gsub(/[()]/,'').split("|")[1]

# 					puts "Analizando #{xcoord}/#{ycoord} com #{wood+clay+iron}." 

# 					target = Village.new(
# 						:xcoord 	=> xcoord,
# 						:ycoord 	=> ycoord,
# 						:wood 		=> wood.to_i,
# 						:clay 		=> clay.to_i,
# 						:iron 		=> iron.to_i,
# 						:delete 	=> "")

# 					@vetAttack = Hash.new
# 					attackWith(ville, "light") 
# 					attackWith(ville, "heavy") 
# 					# attackWith(ville, :walkers) 

# 					if @vetAttack.size > 0
# 						@vetAttack = @vetAttack.merge(setTroops "spy=1")
# 						puts "Atacando #{xcoord}/#{ycoord} com #{@vetAttack}. Restam: #{ville.light} #{ville.heavy} #{ville.spear} #{ville.sword} #{ville.axe}"
# 						ataqueTropas(ville,target,@vetAttack,"attack")
# 						delete = pageReport.link_with(:href  => /(.*action=del_one*.)/).uri
# 						pageDelete = @agent.get('http://'+@world.name+'.tribalwars.com.br'+ delete.to_s)
# 						analisaBot(pageDelete) 
# 					end

# 				end

# 			end

# 		}
# 	end






	def attackWith (ville, type)


		# case type
		# 	when :light
		# 		if ville.getVar(type).to_i * ville.getVar(type+"_cap").to_i > @capacity && @capacity > 0
		# 			togo 	   = (@capacity / ville.getVar(type+"_cap")).to_i
		# 			remaining  = ville.getVar(type).to_i - togo
		# 			if togo > 0 
		# 				togo += 1 if remaining >= 1
		# 				ville.setVar(type,remaining-1)
		# 				@vetAttack = @vetAttack.merge(setTroops "#{type}=#{togo}")
		# 				@capacity -= togo * ville.getVar(type+"_cap").to_i
		# 			end		
		# 		end 			
		# 	when :heavy
		# 	when :walkers
		# 	else
		# 		puts "Vazia..."
		# end


		if ville.getVar(type).to_i * ville.getVar(type+"_cap").to_i > @capacity && @capacity > 0
			togo 	   = (@capacity / ville.getVar(type+"_cap")).to_i
			remaining  = ville.getVar(type).to_i - togo
			if togo > 0 
				togo += 1 if remaining >= 1
				ville.setVar(type,remaining-1)
				@vetAttack = @vetAttack.merge(setTroops "#{type}=#{togo}")
				@capacity -= togo * ville.getVar(type+"_cap").to_i
			end		
		end 



		
	end


	def inAttack

		inAttackVet = Hash.new
		commandsPage = @agent.get("http://"+@world.name+".tribalwars.com.br/game.php?village="+firstId.to_s+"mode=commands&amp;screen=overview_villages&amp;type=attack")
		analisaBot(commandsPage)
		coords = commandsPage.parser.xpath('//table[@id="commands_table"]').inner_text.scan(/\([0-9]{3}[|][0-9]{3}\)/m)
		coords.each {|coord|
			_x = coord.gsub(/[()]/,'').split("|")[0].to_i
			_y = coord.gsub(/[()]/,'').split("|")[1].to_i
			inAttackVet["#{_x} #{_y}"] = ""
		}
		puts inAttackVet

	end


	def attackSpy
		cont = 0

		#@player.villages.each  {|rkey, ville|
		ville = getVillage("xykoBR")

			@temp_vector = janelaSpy(ville,9).sort_by {|_key, value| value}
			cont = 0
			@temp_vector.each {|key,value|

				xcoord = key.split(" ")[0].to_i
				ycoord = key.split(" ")[1].to_i
				spy   = 2
				spear = sword = axe = heavy = light = ram =  catapult = knight = snob = 0
				vTropas = setTropas(spear,sword,axe,spy,light,heavy,ram,catapult,knight,snob)
				target = Village.new(
						:name 	 => "",
						:id 	 => "",
						:xcoord  => xcoord,
						:ycoord  => ycoord,
						:user_id => "")

				ataqueTropas(ville,target,vTropas,"attack")
				cont += 1
				puts "#{cont} #{@temp_vector.size} #{value} #{xcoord} #{ycoord} <= #{ville.name}"

			}

		#}
	end

	def firstId
		return @player.villages[@player.villages.keys[0]].getVar("id")
	end

	def ataqueFake(target)
		ville = nil
		while ville == nil
			candidate = getVillage("")
			ville = candidate  if candidate.getVar("axe").to_i > 4 && candidate.getVar("spy").to_i > 4 && candidate.getVar("catapult").to_i >= 4
		end
		vFakeTrain = setTropas("","","","1","","","1","","","")
		vFakeFull  = setTropas("","","1","1","","","","","","")
		if [true, false].sample
			puts "TrainFake #{target.name} #{target.xcoord} #{target.ycoord}  : #{ville.name}"
			ataqueTropas(ville,target,vFakeTrain,"attack")
			ataqueTropas(ville,target,vFakeTrain,"attack")
			ataqueTropas(ville,target,vFakeTrain,"attack")
			ataqueTropas(ville,target,vFakeTrain,"attack")
		else
			puts "FullFake  #{target.name} #{target.xcoord} #{target.ycoord} from : #{ville.name}"
			ataqueTropas(ville,target,vFakeFull,"attack")
		end
	end

	def setTroops inVector
		outVector = Hash.new 
		inVector.split(" ").each {|vector|
			vector.split("=")[0]
			outVector[vector.split("=")[0].to_s] 	= vector.split("=")[1].to_i
		}
		return outVector
	end

	def setTropas(spear,sword,axe,spy,light,heavy,ram,catapult,knight,snob)
		vTropas = Hash.new 
		vTropas["spear"] 	= spear
		vTropas["sword"] 	= sword
		vTropas["axe"  ] 	= axe
		vTropas["spy"  ] 	= spy
		vTropas["light"] 	= light
		vTropas["heavy"] 	= heavy
		vTropas["ram"] 		= ram
		vTropas["catapult"] = catapult
		vTropas["knight"] 	= knight
		vTropas["snob"] 	= snob
		return vTropas
	end

	def fake(target)
		
		puts "Fake attacks to: #{target}"
		targetId = ""
		@world.get_players.each { |key, value|
			if key[:name].eql? target 
				targetId = value[:id]
			end
		}
		cont = 0
		@world.get_villages.each {|key, value|
			if value[:user_id].eql? targetId
				ataqueFake(Village.new(
					:name 	 => value[:name],
					:id 	 => value[:id],
					:xcoord  => value[:xcoord],
					:ycoord  => value[:ycoord],
					:user_id => value[:user_id]))
				cont += 1
				# exit(0) if cont == 3
			end 
		}
	end

	def ally(ally)
		allyId = ""
		@world.get_allys.each {|key, value|
			 allyId = value[:id] if key[:tag].eql?(ally)
		}
		puts "#{ally}=" 
 		@world.get_players.each { |key, value|
			if value[:ally_id].eql? allyId 
				playerName = "#{key[:name]}"
				palyerId = value[:id]
				@world.get_villages.each {|key, value|
				if value[:user_id].eql?  palyerId
					#puts "#{playerName} #{value[:xcoord]}|#{value[:ycoord]} K#{value[:continent]} #{value[:points]}"
					puts "\"#{value[:xcoord]}|#{value[:ycoord]}|#{playerName}\","
				end 
				}

			end
		}
	end

	def targets

		@player.villages.each  {|key, ville|

			@divShowNotes = @agent.get('http://'+ @world.name+'.tribalwars.com.br/game.php?village='+ville.id.to_s+'&screen=overview')
			@notes = @divShowNotes.parser.xpath('//*[@id="show_notes"]')
			@notes.xpath('//*[@id="show_notes"]').xpath('//*[@id="village_note"]').text.split(" ").each {|target|

				xcoord = target.split("|")[1].to_i
				ycoord = target.split("|")[2].to_i
				attack = target.split("|")[0].to_s

				if attack == "s"

					spear = sword = axe = light = spy = heavy = ram = catapult = knight = snob = 0
					spy   = 5
					light = 25
					vTropas = setTropas(spear,sword,axe,spy,light,heavy,ram,catapult,knight,snob)
					target = Village.new(
							:name 	 => @world.getVillageByCoords(xcoord,ycoord),
							:id 	 => "",
							:xcoord  => xcoord,
							:ycoord  => ycoord,
							:user_id => "")
					ataqueTropas(ville,target,vTropas,"attack")
					puts "#{ville.name} => #{xcoord} #{ycoord} #{target.name}"

				end

			}
		}
	end

	def cleanReports #(Deleta duplicados e recursos < 25)

		@temp_vector = Hash.new

		group_id = "0"

		pageReports = @agent.get("http://"+@world.name+".tribalwars.com.br/game.php?village="+firstId.to_s+"&mode=attack&screen=report")

		analisaBot(pageReports)

		links = pageReports.links_with(:href => /(.*mode=attack&view*.)/)

		puts "Analisando #{links.size} relatórios..."
		links.each_with_index do |link,index|

			pageReport = link.click
			analisaBot(pageReport)

			link_to_delete = pageReport.link_with(:href  => /(.*action=del_one*.)/).uri
			coordenadas = link.text

			alvo = coordenadas[coordenadas.rindex('(')+1,coordenadas.rindex(')')-coordenadas.rindex('(')-1].strip.split("|")
			alvo_texto = coordenadas[coordenadas.rindex('(')+1,coordenadas.rindex(')')-coordenadas.rindex('(')-1].strip.split("|")

			xcoord = alvo[0]
			ycoord = alvo[1]
			delete = false

			if !@temp_vector.key?("#{xcoord} #{ycoord}") then

				wood = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
				clay = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
				iron = pageReport.parser.xpath('//table[@id="attack_spy"]').inner_text.to_s.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i

				if wood > 100 || clay > 100 || iron > 100 && wood + clay + iron > 300
					@temp_vector["#{xcoord} #{ycoord}"] = ""
					puts "#{index} cleanReport mantem o relatório #{xcoord} #{ycoord}" 
				else
					delete = true
				end
			else
				delete = true
			end
			if delete
				puts "#{index} cleanReport deleta o relatório #{xcoord} #{ycoord}" 
				pageDelete = @agent.get('http://'+@world.name+'.tribalwars.com.br'+ link_to_delete.to_s)
				analisaBot(pageDelete) 
			end

		end
	end

	def incoming

		prng       = Random.new(Time.now.to_i)
		scheduler  = Rufus::Scheduler.start_new

		while true

				@pageIncoming = @agent.get('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&screen=overview_villages&mode=incomings&type=unignored&subtype=attacks')
				analisaBot(@pageIncoming)

				@event = @pageIncoming.parser.xpath('//*[@id="incomings_table"]')

				@event.xpath('//td').xpath('//span[@class="timer"]').each {|e|

arrive_time = e.children.to_s.split(':')[0].to_i * 3660 + e.children.to_s.split(':')[1].to_i * 60 + e.children.to_s.split(':')[2].to_i

puts e.children
puts arrive_time
exit(0)
					# attackTo  = e.parent().parent().children()[2].text.strip
					# arriveIn  = e.parent().parent().children()[6].text.strip
					# countDown = e.parent().parent().children()[7].text.strip
				    # linkText  = e.parent().parent().children()[2].children()[1].attribute_nodes()[0].to_s
					# link = @pageIncoming.link_with(:href  => linkText)
					# printf "%-25s \t %10s \t %10s \t %20s \t %20s \n" ,attackTo,arriveIn,countDown,linkText,link

				}
			sleep_time = prng.rand(360)
			puts "#{Time.at(0)} Sleeping #{sleep_time} seconds"
			sleep(sleep_time)
		end
	end

	def teste
		@player.villages.each  {|key, ville|
			janelaSpyTeste(ville,12)
		}
	end

	def loadVar

		Console.clear
		Cursor.position = 5,5
		cmd = ""
		sts = true
		while sts 

			k = get_character

			case k
			when 10
				sts = false
			when 32..126
				cmd += k.chr
			when 127
				if cmd.size == 1
					cmd = "" 
				else
					cmd = cmd[0..(cmd.size-2)]
				end
			end

			Cursor.position = 5,5
			puts " " * 50
			Cursor.position = 5,5
			puts "[#{cmd}] = #{sts}"

		end
		return cmd
	end


end #end Class

options = OpenStruct.new
options.library = []
options.inplace = false
options.encoding = "utf8"
options.transfer_type = :auto
options.verbose = false
opts = OptionParser.new do |opts|

	opts.banner = "Usage: tribal.rb -c [spy|check|farm|fake|ally|targets|incoming|getsum] [options]"
	opts.separator ""
	opts.separator "Specific options:"
	# Optional argument with keyword completion.

	opts.on("-n","--name NAME") do |n|	
		options.ally_name = n 
	end

	opts.on("-c","--c [COMMAND]", [:spy, :check, :farm, :fake, :ally, :targets, :teste, :incoming, :clean],
		"Select command type (spy, check, farm, fake, ally, targets, incoming, clean)") do |c|
		options.c_type = c
		opts.on("-n","--name NAME") do |n|	
			options.ally_name = n 
		end
	end

	opts.on_tail("-h", "--help", "Show this message") do
		puts opts
		exit(0)
	end
end
opts.parse!(ARGV)


name   = "xykoBR"
passwd = "barbara"
world  = "br48"
tw = Tribal.new(:name => name,:passwd => passwd,:world => world)
tw.connect
puts "Connected: #{tw.logged?}"
tw.atualiza_tropas

case options.c_type
	when :spy
		puts "spy+"
		tw.attackSpy
	when :farm
		puts "farm+"
		tw.farmAll
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
	when :teste
		puts "Executando teste..."
		tw.teste	
	else
		puts "Vazia..."
end





