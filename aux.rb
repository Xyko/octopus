

# require 'date'
# require 'rufus/scheduler'
# scheduler = Rufus::Scheduler.start_new

# scheduler.in "24000s" do
# 	puts "teste"
# end

# scheduler.pending_job_count


# #scheduler.instance_variable_get("@jobs").instance_variable_get("@jobs")[0].instance_variable_get("@at")


# scheduler.instance_variable_get("@jobs").instance_variable_get("@jobs").each { |x|
# 	puts Time.at(x.instance_variable_get("@at").to_i).to_datetime 
# }


      players = File.open(File.expand_path(File.dirname(__FILE__) ).to_s + '/playerbr52.txt')
      players.each do |line|
        
       puts line.to_s

      end