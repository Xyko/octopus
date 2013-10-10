# -*- encoding : utf-8 -*-
require 'rubygems'
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require 'capybara/poltergeist'
require 'logger'
require 'slop'
require 'colorize'
require 'ruby-progressbar'
require 'time_difference'

load 'Player.rb'
load 'World.rb'
load 'Village.rb'

class Octupus

  Capybara.register_driver :selenium_with_long_timeout do |app|
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120
    Capybara::Driver::Selenium.new(app, :browser => :firefox, :http_client => client, :timeout => 120)
  end

  Capybara.app_host           = "http://www.tribalwars.com.br/"
  Capybara.run_server         = false
  Capybara.current_driver     = :poltergeist
  Capybara.javascript_driver  = :selenium_with_long_timeout

  include Capybara::DSL

  def initialize(options = {})

    puts %x(./tribal.sh) if TimeDifference.between(Time.now, File.mtime(File.expand_path(File.dirname(__FILE__) ).to_s + '/playerbr44.txt')).in_hours > 6

    puts "Classe instanciada..."
    @world   = World.new
    @player  = Player.new

    @world.name     = options[:world]
    @player.name    = options[:login]
    @player.passwd  = options[:passwd]
    @world.archers  = true if options[:archers]
    @world.nologin  = true if options[:nologin]    

    if @world.archers
      @world.vet_attack_types = ["spear","sword","axe","archer","marcher","light","heavy"]
    else
      @world.vet_attack_types = ["spear","sword","axe","light","heavy"]
    end

    if @world.nologin || @world.name.nil? || @player.passwd.nil? || @player.name.nil?
      puts "No Login actions".green
      puts "World   #{@world.name}".red
      puts "Name    #{@player.name}".red
      puts "Passwd  #{@player.passwd.gsub(/./,'*')}".red
      puts "Nologin #{@world.nologin}".blue
    else

      puts "Loading data and login...."

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
            :name     => value[:name],
            :id       => value[:id],
            :xcoord   => value[:xcoord],
            :ycoord   => value[:ycoord],
            :user_id  => value[:user_id])
        end 
      }
      login
      refreshTroops

    end
  end

  def testeVillages
    @player.villages.each  {|key, value|
      puts value.name
      puts value.spear   
      puts value.sword   
      puts value.axe     
      puts value.archer  
      puts value.spy     
      puts value.light   
      puts value.heavy   
      puts value.marcher 
      puts value.ram     
      puts value.catapult
      puts value.knight  
      puts value.snob 
    }
  end

  def analisaBot
    botMsg = "contra Bots"
    if page.body.to_s.index(botMsg)
      page.save_screenshot('boot.png')
      exit(0)
    end
  end

  def login
    visit('/')
    fill_in('user',     :with => @player.name)
    fill_in('password', :with => @player.passwd)
    path = ""
    page.find(:xpath, "/html/body/div[2]/div/div[2]/div/div[2]/div[2]/form/div/div/div/a/span[2]").click
    analisaBot
    case @world.name
    when "br44"
    #page.save_screenshot('screenshot1.png')
    sleep(5)
    path = "/html/body/div[2]/div/div[2]/div/div[2]/div[2]/div/div[2]/form/div/div/a[1]/span"
    page.first(:xpath, path).click
    when "br48"
      path = "/html/body/div[2]/div/div[2]/div/div[2]/div[2]/div/div[2]/form/div/div/a[2]/span"
      page.find(:xpath, path).click
    when "br52"
      path = "/html/body/div[2]/div/div[2]/div/div[2]/div[2]/div/div[2]/form/div/div/a[3]/span"
      page.find(:xpath, path).click
    else
      puts "Invalid world..."
      exit(0)
    end

  #page.find(:xpath, "/html/body/div[2]/div/div[2]/div/div[2]/div[2]/form/div/div/div/a/span[2]").click
  #page.find(:xpath, path).click
  #puts "Loging status => #{page.status_code}."
  #page.save_screenshot('screenshot1.png')
  analisaBot
end

def refreshTroops

  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Atualizando", :starting_at => 0, :total => @player.villages.size, :format => '%a %B %p%% %t')
  @player.villages.each  {|key, value|

    page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+value.id.to_s+'&screen=place')
    #puts "Atualizando tropas #{page.status_code}"
    analisaBot

    path_spear    = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td/table/tbody/tr/td/a[2]"
    path_sword    = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td/table/tbody/tr[2]/td/a[2]"
    path_axe      = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td/table/tbody/tr[3]/td/a[2]"
    path_spy      = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[2]/table/tbody/tr/td/a[2]"     
    path_light    = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td/a[2]"
    path_ram      = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[3]/table/tbody/tr/td/a[2]"
    path_catapult = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[3]/table/tbody/tr[2]/td/a[2]"
    path_knight   = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[4]/table/tbody/tr/td/a[2]"
    path_snob     = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[4]/table/tbody/tr[2]/td/a[2]"

    value.spear   = page.first(:xpath, path_spear   ).text.sub('(','').sub(')','')
    value.sword   = page.first(:xpath, path_sword   ).text.sub('(','').sub(')','')
    value.axe     = page.first(:xpath, path_axe     ).text.sub('(','').sub(')','')
    value.spy     = page.first(:xpath, path_spy     ).text.sub('(','').sub(')','')
    value.light   = page.first(:xpath, path_light   ).text.sub('(','').sub(')','')
    value.ram     = page.first(:xpath, path_ram     ).text.sub('(','').sub(')','')
    value.catapult= page.first(:xpath, path_catapult).text.sub('(','').sub(')','')
    value.knight  = page.first(:xpath, path_knight  ).text.sub('(','').sub(')','')
    value.snob    = page.first(:xpath, path_snob    ).text.sub('(','').sub(')','')

    if @world.archers
      path_archer   = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td/table/tbody/tr[4]/td/a[2]"
      path_marcher  = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[2]/table/tbody/tr[3]/td/a[2]"
      path_heavy    = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[2]/table/tbody/tr[4]/td/a[2]"
      value.archer  = page.first(:xpath, path_archer  ).text.sub('(','').sub(')','')
      value.heavy   = page.first(:xpath, path_heavy   ).text.sub('(','').sub(')','')
      value.marcher = page.first(:xpath, path_marcher ).text.sub('(','').sub(')','')
    else
      path_heavy    = "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/form/table/tbody/tr[3]/td[2]/table/tbody/tr[3]/td/a[2]"
      value.heavy   = page.first(:xpath, path_heavy   ).text.sub('(','').sub(')','')
      value.archer  = 0
      value.marcher = 0
    end 
    progressbar.increment
  }
end

def getVillage(villageName)
  @player.villages.each  {|key, value|
    if value.name.eql? villageName
      return value
    end
  }
  return @player.villages[@player.villages.keys[rand(@player.villages.size)]]
end

def getVillageCoord(targetx, targety)
  @world.get_villages.each {|key, value|
    if (value[:xcoord].eql? targetx) && (value[:ycoord].eql? targety)
      return Village.new(
        :name    => value[:name],
        :id      => value[:id],
        :xcoord  => value[:xcoord],
        :ycoord  => value[:ycoord],
        :user_id => value[:user_id])
    end 
  }
end

def nearTo(xi, yi)
  menor = 100
  key   = ""
  @player.villages.each  {|rkey, rvalue|
    xf = rvalue.xcoord.to_i
    yf = rvalue.ycoord.to_i
    dist = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
    if dist <= menor and dist > 0 then
      menor = Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2)
      key   = rkey
    end
  }
  #puts "escolhemos a menor distancia = #{menor} #{key}"
  return @player.villages[key]
end

def vectorNearTo (xi,yi)
  @player.villages.each  {|rkey, rvalue|
    xf = rvalue.xcoord.to_i
    yf = rvalue.ycoord.to_i
    rvalue.setVar("distance",Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2))
  }
end

def getOrdenedVectorNearTo (target)
  vector = Hash.new
  vectorNearTo(target.xcoord,target.ycoord).each.sort_by { |key,value|
    vector[value.name] = value.distance.to_i
  }
  return vector.sort_by {|name,dist| dist}
end

#Massive snob creater
def screate(nothing)
  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Criando Nobres", :starting_at => 0, :total => @player.villages.size, :format => '%a %B %p%% %t')    
  @player.villages.sort.each  {|key, ville|
    page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+ville.id.to_s+'&screen=snob')
  #puts "Atualizando academia #{page.status_code}"
  analisaBot
  page.click_link('Formar unidade') if page.has_link?('Formar unidade')
  progressbar.increment
  }
end

#Massive snob killer
def skill(nothing)  
  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Matando Nobres", :starting_at => 0, :total => @player.villages.size, :format => '%a %B %p%% %t')    
  @player.villages.each  {|key, ville|
    if ville.snob.to_i > 0
      target = nearTo(ville.xcoord, ville.ycoord)
  #puts "Enviando #{ville.snob} nobres from #{ville.name} to death => #{target.name}"
  vetAttack = Hash.new
  vetAttack = vetAttack.merge(setTroops "snob=#{ville.snob}")
  attackTroops(ville,target,vetAttack,"attack")
  end
  progressbar.increment
}
end

def janelaSpy(fromcoords, tolerance)
  x   = fromcoords[0].to_i
  y   = fromcoords[1].to_i
  vetRet = Hash.new
  cont = 0
  @world.get_villages.each {|key, value|
    if value[:user_id].eql?  "0" 
      _x = value[:xcoord].to_i
      _y = value[:ycoord].to_i
      if  _x.between?(  x - tolerance , x + tolerance ) && 
        _y.between?(  y - tolerance , y + tolerance )
        dist    = Math.sqrt((x - _x) ** 2 + (y - _y) ** 2).to_i
        vetRet["#{_x} #{_y}"] = dist
      end
    end 
  }
  return vetRet
end

def attackTroops(fromVillage, toVillage, vTropas, attackType)

  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+fromVillage.id.to_s+'&screen=place')
  #puts "Atacanto tropas #{page.status_code}"
  analisaBot
  #page.save_screenshot('ataqueTropas.png')

  fill_in('x'       , :with => toVillage.xcoord)
  fill_in('y'       , :with => toVillage.ycoord)

  fill_in('spy'     , :with => vTropas["spy"])
  fill_in('spear'   , :with => vTropas["spear"])
  fill_in('sword'   , :with => vTropas["sword"])
  fill_in('axe'     , :with => vTropas["axe"])
  fill_in('light'   , :with => vTropas["light"])
  fill_in('heavy'   , :with => vTropas["heavy"])
  fill_in('ram'     , :with => vTropas["ram"])
  fill_in('catapult', :with => vTropas["catapult"])
  fill_in('knight'  , :with => vTropas["knight"])
  fill_in('snob'    , :with => vTropas["snob"])

  if @world.archers
    fill_in('archer'  , :with => vTropas["archer"])
    fill_in('marcher' , :with => vTropas["marcher"])
  end

  page.click_button('Ataque')
  #page.save_screenshot('ataqueTropas_Ataque.png')
  analisaBot


  begin
    page.click_button('OK')
  #page.save_screenshot('ataqueTropas_OK.png')
  analisaBot
  rescue
    puts "Alvo não tratado #{toVillage.xcoord}/#{toVillage.ycoord}"
  #page.save_screenshot("#{toVillage.xcoord}_#{toVillage.ycoord}.png")
  end

  return true

end

def setTroops inVector
  outVector = Hash.new 
  inVector.split(' ').each {|vector|
    vector.split('=')[0]
    outVector[vector.split('=')[0].to_s] = vector.split('=')[1].to_i
  }
  return outVector
end

def spys(fromcoords)
  cont = 0
  @temp_vector = janelaSpy(fromcoords,6).sort_by {|_key, value| value}
  cont = 0
  @temp_vector.each {|key,value|
    xcoord = key.split(" ")[0].to_i
    ycoord = key.split(" ")[1].to_i
    vetAttack = Hash.new
    vetAttack = vetAttack.merge(setTroops 'spy=2')
    target = Village.new(
      :name    => '',
      :id      => '',
      :xcoord  => xcoord,
      :ycoord  => ycoord,
      :user_id => '')
    ville = nearTo(xcoord,ycoord)
    attackTroops(ville,target,vetAttack,'attack')
    cont += 1
    puts "#{cont} #{@temp_vector.size} #{value} #{xcoord} #{ycoord} <= #{ville.name}"
  }
end

def firstId
  return @player.villages[@player.villages.keys[0]].getVar("id")
end

def distbetween(xi,yi,xf,yf)
  return Math.sqrt((xi - xf) ** 2 + (yi - yf) ** 2).to_i
end

def readreports(page,fromcoords)

  xi      = fromcoords[0].to_i
  yi      = fromcoords[1].to_i
  reports = Hash.new

  def getall(xi, yi) 
    reports = Hash.new
    page.all('a').each {|a|
      if a.text.include?('xykoBR') && page.has_link?(a.text)
        aux = a.text.scan(/\([[:digit:]]{3}\|[[:digit:]]{3}\)/)
        coords = aux[aux.size-1]
        xf = coords.gsub(/[()]/,'').split('|')[0].to_i
        yf = coords.gsub(/[()]/,'').split('|')[1].to_i
        reports['http://'+@world.name+'.tribalwars.com.br'+a[:href].to_s] = distbetween(xi, yi, xf, yf)
      end
    }
    return reports
  end

  reports = reports.merge(getall(xi, yi))
  [2,3,4].each {|index|
    if !page.all('a', :text => "[#{index}]").empty?()
      click_link("[#{index}]")
      reports = reports.merge(getall(xi, yi)) 
    end
  }

  return reports.sort_by {|name,dist| dist}
end

def cleanothers(fromcoords)
  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=defense&screen=report')
  page.click_button('Apagar') if check('Selecionar todos').present?
  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=support&screen=report')
  page.click_button('Apagar') if check('Selecionar todos').present?
  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=trade&screen=report')
  page.click_button('Apagar') if check('Selecionar todos').present?
  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=other&screen=report')
  page.click_button('Apagar') if check('Selecionar todos').present?
end

def clean(fromcoords)

  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=attack&screen=report')
  analisaBot
  reports = readreports(page,fromcoords)
  puts "Report.size = #{reports.size}"
  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Analisando relatorios", :starting_at => 0, :total => reports.size, :format => '%a %B %p%% %t')    
  reports.each {|report,dist|
    page.visit(report)  
    analisaBot

    begin
      page.find_by_id('attack_spy')
    rescue Capybara::ElementNotFound
      page.all('a').select {|elt| elt.text == "Apagar" }.first.click
    end

    wood  = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
    stone = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
    iron  = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
    @capacity = wood + stone + iron
    page.all('a').select {|elt| elt.text == "Apagar" }.first.click if @capacity < 500


    # if page.find_by_id('attack_spy unidade')
    #   wood = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
    #   stone = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
    #   iron = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
    #   @capacity = wood + stone + iron
    #   page.all('a').select {|elt| elt.text == "Apagar" }.first.click if @capacity < 500
    # else
    #   page.all('a').select {|elt| elt.text == "Apagar" }.first.click if @capacity < 500
    # end

    progressbar.increment
  }
end

def emptyville(ville)
  @world.vet_attack_types.each{|troop|
    ville.setVar(troop,0) if [true,false].sample
  }
end

def farmanalize(arguments)
  ville   = arguments[:ville]
  coords  = arguments[:coords]
  #case test
  #emptyville(ville)
  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=attack&screen=report')
  analisaBot
  reports = readreports(page,coords)
  reports.each {|report,dist|
    page.visit(report)
    analisaBot
    wood = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
    stone = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
    iron = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
    capacity = wood + stone + iron
    coords = page.first(:xpath,'/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td[2]/table/tbody/tr/td/table[2]/tbody/tr[3]/td/table[2]/tbody/tr[2]/td[2]/span/a').text.gsub(/[a-zA-Z:çá()éí.]/,'').strip.split
    xcoord = coords[0].split('|')[0]
    ycoord = coords[0].split('|')[1]
    farmprepare(ville,capacity)
}
end

def newfarmall(coords) 
  @player.reports = readreports(page,coords)
  while @player.updatecapacity > 300
    puts @player.updatecapacity
    @player.villages.each  {|key, ville|
      farmanalize({:ville => ville, :coords => coords}) if ville.farmed_cap > 0
    }
  end
end


def farmall(fromcoords)

  page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+firstId.to_s+'&mode=attack&screen=report')
  #page.save_screenshot('report1.png')
  analisaBot
  reports = readreports(page,fromcoords)

  @minimalFarmLimit = 300

  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Analisando relatorios", :starting_at => 0, :total => reports.size, :format => '%a %B %p%% %t')    
  reports.each {|report,dist|

    index = 1

    page.visit(report)  
  #page.save_screenshot('report2.png')
  analisaBot

  wood = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[0].to_i
  stone = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[1].to_i
  iron = page.find_by_id('attack_spy').text.gsub(/[a-zA-Z:çá()éí.]/,'').split[2].to_i
  @capacity = wood + stone + iron

  coords = page.first(:xpath,'/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td[2]/table/tbody/tr/td/table[2]/tbody/tr[3]/td/table[2]/tbody/tr[2]/td[2]/span/a').text.gsub(/[a-zA-Z:çá()éí.]/,'').strip.split
  xcoord = coords[0].split('|')[0]
  ycoord = coords[0].split('|')[1]

  #if wood > 100 || stone > 100 || iron > 100 && wood + stone + iron > 300
  if @capacity >= @minimalFarmLimit
    target = Village.new(
      :xcoord   => xcoord,
      :ycoord   => ycoord,
      :wood     => wood.to_i,
      :stone     => stone.to_i,
      :iron     => iron.to_i,
      :delete   => "")

    candidates = getOrdenedVectorNearTo(target)

    candidates.each {|ville_name,v|
      ville = getVillage(ville_name)

      if ville.farmed_cap > 1000

        def internalAttack (ville,target,msg,report)
          if @vetAttack.size > 0
            puts "internalAttack #{ville.farmed_cap} #{ville.farmed_cap} #{@capacity} #{@vetAttack}"
            @vetAttack = @vetAttack.merge(setTroops "spy=1")
            puts "#{msg} com #{@vetAttack}. Restam: #{ville.light} #{ville.heavy} #{ville.spear} #{ville.sword} #{ville.axe}"
            attackTroops(ville,target,@vetAttack,"attack")
            if @capacity < @minimalFarmLimit 
              page.visit(report) 
              page.all('a').select {|elt| elt.text == "Apagar" }.first.click
              puts "internalAttack Apagando....."
              analisaBot
            end 
          end
        end

        index += 1
        msg = "#{index}/#{reports.size} #{ville.name} atacando #{xcoord}/#{ycoord}" 

        @vetAttack = Hash.new
        attackWithWalkers(ville)  if @capacity > @minimalFarmLimit 
        internalAttack(ville,target,msg,report) 

        @vetAttack = Hash.new
        attackWithArchers(ville)   if @capacity > @minimalFarmLimit
        internalAttack(ville,target,msg,report) 

        @vetAttack = Hash.new
        attackWithHorses(ville)   if @capacity > @minimalFarmLimit            
        internalAttack(ville,target,msg,report) 

      end

    }
    index += 1
  else 
    page.all('a').select {|elt| elt.text == "Apagar" }.first.click
    puts "internalAttack out of Apagando....."
    analisaBot 
  end

  progressbar.increment
  }
end

def normalizeTroops(type)

  puts " #{@capacity} #{@_spear} #{@_sword} #{@_axe}"

  def byZero(itsZero)
    return "1" if itsZero > 0
    return "0"
  end

  def byTwenty(itsZero)
    return "1" if itsZero > 20
    return "0"
  end

  def _spear
    @capacity  -= @_spear_cap
    @_spear    -= 1
  end

  def _sword
    @capacity  -=  @_sword_cap 
    @_sword    -= 1
  end

  def _axe
    @capacity  -= @_axe_cap
    @_axe      -= 1
  end

  def _light
    @capacity  -=  @_light_cap 
    @_light    -= 1
  end

  def _heavy
    @capacity  -= @_heavy_cap
    @_heavy    -= 1
  end

  def _archer
    @capacity  -=  @_archer_cap 
    @_archer    -= 1
  end

  def _marcher
    @capacity  -= @_marcher_cap
    @_marcher    -= 1
  end

  if type == :walkers
    vetVarWalkers = byZero(@_spear) + byZero(@_sword) + byZero(@_axe)
    case vetVarWalkers
    when "111"
      _spear
      _sword
      _axe
    when "110"
      _spear
      _sword
    when "101"
      _spear
      _axe
    when "011"
      _sword
      _axe
    when "010" 
      _sword
    when "001"
      _axe
    when "100"
      _spear
    when "010"
      puts "normalizeTroops -> vetVar vetor apenas com sword... retornando"
      return  
    when "000"
      puts "normalizeTroops -> vetVar vetor walkwrs vazio... retornando"
      return
    else
      puts "normalizeTroops -> vetVar não definido #{vetVar}"
      exit(0)
    end
  end

  if type == :horses
    vetVarHorses  = byZero(@_light) + byZero(@_heavy) 
    case vetVarHorses
    when "11"
      _light
      _heavy
    when "10"
      _light
    when "01"
      _heavy
    when "00"
      puts "normalizeTroops -> vetVar vetor horses vazio... retornando"
      return
    else
      puts "normalizeTroops -> vetVar não definido #{vetVar}"
      exit(0)
    end
  end

  if type == :archers
    vetVarArchors  = byZero(@_archer) + byZero(@_marcher) 
    case vetVarArchors
    when "11"
      _archer
      _marcher
    when "10"
      _archer
    when "01"
      _marcher
    when "00"
      puts "normalizeTroops -> vetVar vetor horses vazio... retornando"
      return
    else
      puts "normalizeTroops -> vetVar não definido #{vetVar}"
      exit(0)
    end
  end

  normalizeTroops(type) if @capacity > @minimalFarmLimit 

  return

  puts "#{@capacity} #{@_spear} #{@_sword} #{@_axe}" 
end

def attackWithWalkers(ville) 

  @_spear       = ville.getVar("spear").to_i
  @_sword       = ville.getVar("sword").to_i
  @_axe         = ville.getVar("axe").to_i
  @_spear_cap   = ville.getVar("spear_cap").to_i
  @_sword_cap   = ville.getVar("sword_cap").to_i
  @_axe_cap     = ville.getVar("axe_cap").to_i

  capAux = @capacity

  normalizeTroops(:walkers)

  if @_spear.to_i + @_sword.to_i + @_axe.to_i > 30

    spear = ville.getVar("spear").to_i - @_spear.to_i 
    sword = ville.getVar("sword").to_i - @_sword.to_i 
    axe   = ville.getVar("axe").to_i   - @_axe.to_i    

    ville.setVar("spear" ,@_spear)
    ville.setVar("sword" ,@_sword)
    ville.setVar("axe"   ,@_axe)

    @vetAttack = @vetAttack.merge(setTroops "spear=#{spear.to_i}")
    @vetAttack = @vetAttack.merge(setTroops "sword=#{sword.to_i}")
    @vetAttack = @vetAttack.merge(setTroops "axe=#{axe.to_i}")

  else

    @capacity - capAux

  end
end

def attackWithHorses(ville) 

  @_light     = ville.getVar("light").to_i
  @_heavy     = ville.getVar("heavy").to_i
  @_light_cap   = ville.getVar("light_cap").to_i
  @_heavy_cap   = ville.getVar("heavy_cap").to_i

  normalizeTroops(:horses)

  light = ville.getVar("light").to_i - @_light.to_i 
  heavy = ville.getVar("heavy").to_i - @_heavy.to_i 

  if light + heavy > 3

    ville.setVar("light" ,@_light)
    ville.setVar("heavy" ,@_heavy)

    @vetAttack = @vetAttack.merge(setTroops "light=#{light.to_i}")
    @vetAttack = @vetAttack.merge(setTroops "heavy=#{heavy.to_i}")

  end
end

def attackWithArchers(ville) 

  @_archer    = ville.getVar("archer").to_i
  @_marcher     = ville.getVar("marcher").to_i
  @_archer_cap   = ville.getVar("archer_cap").to_i
  @_marcher_cap   = ville.getVar("marcher_cap").to_i

  normalizeTroops(:archers)

  archer = ville.getVar("archer").to_i - @_archer.to_i 
  marcher = ville.getVar("marcher").to_i - @_marcher.to_i 

  if archer + marcher > 3

    ville.setVar("archer" ,@_archer)
    ville.setVar("marcher" ,@_marcher)

    @vetAttack = @vetAttack.merge(setTroops "archer=#{archer.to_i}")
    @vetAttack = @vetAttack.merge(setTroops "marcher=#{marcher.to_i}")

  end
end

def rename(msg)
  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Renomeando", :starting_at => 0, :total => @player.villages.size, :format => '%a %B %p%% %t')    
  @player.villages.each  {|key, ville|
    page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+ville.id.to_s+'&screen=main')
    analisaBot
    name = ""
    (1..20).each{
      name += ["0","1"].sample 
    }
    fill_in('name',  :with => name)
    page.click_button('Alterar')
    progressbar.increment
  }
end

def shop(msg)

  @limit = msg[2].to_i

  def analyze(ville,delivery,type)

    captype   = delivery.getVar(type)
    capacity  = delivery.capacity
    necessary = @limit - ville.getVar(type) 


    if necessary > 0
      if capacity > 0
        if captype > 0
          puts "[#{ville.name} <= #{delivery.name}] Is necessary #{necessary} of #{type} and can delivery #{capacity} and I have #{captype}"
          page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+delivery.id.to_s+'&screen=market')
          fill_in('x'       , :with => ville.xcoord)
          fill_in('y'       , :with => ville.ycoord)
          if captype - necessary > 0
            if  capacity > necessary
              delivery.setVar(type,captype-necessary)
              ville.setVar(type,@limit)
              fill_in(type      , :with => necessary)
            else
              delivery.setVar(type,capacity)
              ville.setVar(type,necessary - capacity)
              fill_in(type      , :with => capacity)
            end
          else
            delivery.setVar(type,0)
            ville.setVar(type,necessary - captype)
            fill_in(type, :with => captype)
          end
          page.click_button('OK')
          page.click_button('OK')
        else
          puts "#{type} is necessary and I have capacity but I dont have #{type}"
        end
      else
        puts "#{type} is necessary but I dont have capacity"          
      end
    else
      puts "#{type} is not necessary"
    end

    return true

  end

  def shopresource(type,ville)
    vet = getOrdenedVectorNearTo(ville)
    vet.each{|target|
      if target[0].start_with?("MC") && ville.getVar(type) < @limit
        delivery = getVillage(target[0])  
        case type
        when "wood"
          analyze(ville,delivery,type)
        when "stone"
          analyze(ville,delivery,type)
        when "iron"
          analyze(ville,delivery,type)
        end
      end
    }

  end

  progressbar = ProgressBar.create(:progress_mark => '-' ,:title => "Shopping", :starting_at => 0, :total => @player.villages.size, :format => '%a %B %p%% %t')    
  @player.villages.each  {|key, ville|
    page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+ville.id.to_s+'&screen=overview')
    wood  = page.find(:xpath, "//*[@id=\"wood\"]").text.to_i
    stone = page.find(:xpath, "//*[@id=\"stone\"]").text.to_i
    iron  = page.find(:xpath, "//*[@id=\"iron\"]").text.to_i
    page.visit('http://'+@world.name+'.tribalwars.com.br/game.php?village='+ville.id.to_s+'&screen=market')
    capacity = page.first(:xpath, "/html/body/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table[2]/tbody/tr/td[2]/table/tbody/tr/th[2]").text.split(" ")[4].to_i
    ville.setresources(wood,stone,iron,capacity)
    progressbar.increment
  }
  (msg[0]..msg[1]).each{|name|
    ville = getVillage(name)    
    puts "#{ville.name} #{ville.wood} #{ville.stone} #{ville.iron}"  
    shopresource("wood",ville)  if ville.wood  < @limit
    shopresource("stone",ville) if ville.stone < @limit
    shopresource("iron",ville)  if ville.iron  < @limit
    puts "#{ville.name} #{ville.wood} #{ville.stone} #{ville.iron}" 
  }

end


def screen(page,name)
  page.save_screenshot(name+".png")
end

def test(msg)
  puts "testing.....=> #{msg.inspect}"
end


def polar(x,y)
  theta = Math.atan2(y,x)   # Compute the angle
  r = Math.hypot(x,y)       # Compute the distance
  [ r, theta]                # The last expression is the return value
end

def planAttack(target)

  xf    = target[0].to_i
  yf    = target[1].to_i
  dia   = target[2].to_i
  mes   = target[3].to_i
  hora  = target[4].to_i
  minuto= target[5].to_i

  vector = Hash.new
  @player.villages.each {|keyv, ville|
    xi = ville.xcoord.to_i
    yi = ville.ycoord.to_i
    r, theta = polar(xf - xi, yf - yi)
    vector[ville.name] = r
  }

  t = Time.new(2013, mes, dia, hora, minuto, 0)

  (vector.sort_by {|name,dist| dist}).each {|k,v|
    cv = t - 11 * v * 60
    w  = t - 22 * v * 60
    s  = t - 35 * v * 60
    d  = format("%.1f", v)
    ville = getVillage(k)
    puts format("%20s %8s %8s %8s %5s %5s %5s %5s\n", 
      k,
      "#{cv.hour}:#{cv.min}:#{cv.sec}",
      "#{ w.hour}:#{ w.min}:#{ w.sec}",
      "#{ s.hour}:#{ s.min}:#{ s.sec}", 
      ville.axe.to_s,
      ville.heavy.to_s,
      ville.snob.to_s,               
      d)    
  }

end 



end

############ End Octopus

#begin
opts = Slop.parse(:help => true, :strict => true) do
  on '-v', 'Print the version' do
    puts "Version 1.0"
  end
  on :w, :world=,   'Your world',  :required => true
  on :l, :login=,   'Your login',  :required => true
  on :p, :passwd=,  'Your passwd',  :required => true
  on :c, :command=, 'Your command'
  on :a, :archers,  'Archers boolean'
  on :n, :nologin,  'Login boolean'
  on :t, :time,     'Time do target'
  on :v, :ville,    'Ville to target'
  on :m, :message=, 'Option message to send', as: Array,  delimiter: ':'
end

# validCommands = ['test','spys', 'screate', 'skill', 'farmall', 'clean', 'newfarmall', 'rename', 'shop', 'planattack', 'cleanothers']
# raise "Invalid Command! Valid are: #{validCommands.inspect}\nTry -h or --help for help." unless validCommands.include?(opts[:command])

case opts[:command]
when "spys", "farmall", "clean", "newfarmall"
  raise "Command #{opts[:command]} required -m." if opts[:message].nil?
else
  puts "Parser completed."  
end


#begin
octopus = Octupus.new(opts.to_hash)
octopus.send(opts.to_hash[:command],opts.to_hash[:message])
# rescue Exception => e
#   puts e.message.light_red
#   puts e.backtrace
#   exit(0)
# end

#  rescue Exception => e
#    puts e.message.red
#    #puts e.backtrace
# end



# ataques sai 11:55
# trem sai as 10:48



