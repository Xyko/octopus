# -*- encoding : utf-8 -*-
require 'rubygems'


class World
  
  attr_accessor :name
  
  def get_knowledge_base
      
  
      players = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + '/player'+@name+'.txt')
      players.each do |line|
        
        player    =  line.to_s

        id        =  player.split(",")[0]
        name      =  get_tranlated_name(player.split(",")[1].to_s)
        ally_id   =  player.split(",")[2]
        villages  =  player.split(",")[3]
        points    =  player.split(",")[4]
        rank      =  player.split(",")[5]

        @vet_players[:name => name] = {
          
          :id        =>  id,
          :ally_id   =>  ally_id,
          :villages  =>  villages,
          :points    =>  points,
          :rank      =>  rank
          
        }

      end
      
      villages = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + '/village'+@name+'.txt')
      villages.each do |line|
        
        villa   =  line.to_s
        
        id      =  villa.split(",")[0]
        name    =  get_tranlated_name(villa.split(",")[1].to_s)
        xcoord  =  villa.split(",")[2]
        ycoord  =  villa.split(",")[3]
        user_id =  villa.split(",")[4]

        puts villa

        @vet_villages[:id => id] = {
          
          :id        =>  id,
          :name      =>  name,
          :xcoord    =>  xcoord,
          :ycoord    =>  ycoord,
          :user_id   =>  user_id,
          :continent =>  ycoord.to_s[0]+xcoord.to_s[0],
          
        }


      end
      
      allys = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + '/ally'+@name+'.txt')
      allys.each do |line|

        ally  =  line.to_s

        id          =  ally.split(",")[0]
        name        =  get_tranlated_name(ally.split(",")[1].to_s)
        tag         =  get_tranlated_name(ally.split(",")[2].to_s)
        members     =  ally.split(",")[3]
        villages    =  ally.split(",")[4]
        points      =  ally.split(",")[5]
        all_points  =  ally.split(",")[6]
        rank        =  ally.split(",")[7]

        @vet_allys[:tag => tag] = {
          
          :id          =>  id,
          :name        =>  name,
          :members     =>  members,
          :villages    =>  villages,
          :points      =>  points,
          :all_points  =>  all_points,
          :rank        =>  rank

         }
         
      end
      
  end
  
  def get_players
     return @vet_players
  end
  
  def get_villages
     return @vet_villages
  end
  
  def get_allys
     return @vet_allys
  end
  
  
  def getVillageByCoords(xcoord,ycoord)
    @vet_villages.select{|k,v| v[:xcoord].to_i == xcoord && v[:ycoord].to_i == ycoord}.each{|k,v|
      return v[:name]
    }
  end

  
  def initialize(options = {})

    @vet_players    = Hash.new
    @vet_villages   = Hash.new
    @vet_allys      = Hash.new

  end

  def get_info

    puts @vet_villages.size
    puts @vet_players.size
    puts @vet_allys.size

  end

  def get_converted_name(name)
      return name.gsub(/[ ]/,'+').gsub(/[=]/,'%3D').gsub(/[á]/,'%C3%A1')
  end

  def get_tranlated_name(name)

      return  name.gsub(/%3D/,'=').gsub(/%C3%A1/,'á').gsub(/%C3%A9/,'é').gsub(/%2A/,'*').gsub(/%3F/,'?').gsub(/%2B/,'+').gsub(/%7C/,'|')
 
  end
  
end

# w = World.new
# w.name = "br48"
# w.get_knowledge_base
# w.getVillageByCoords(462,528)

