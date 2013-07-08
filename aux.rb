
19:49

N-253-10.4 614|321  24.0  2013-07-08 15:24:46 -0300  1372  2013-07-08 12:36:37 -0300  2494 
N-253-10.4 => s.send("08/07/2013 19:49:00,614|321,615|345, heavy=1372  axe=2494 ,0")











resque-scheduler


require 'date'
require 'rufus/scheduler'
scheduler = Rufus::Scheduler.start_new

scheduler.in "100s" do
	puts "teste"
end
scheduler.in "200s" do
	puts "teste"
end
scheduler.in "300s" do
	puts "teste"
end
scheduler.in "400s" do
	puts "teste"
end

scheduler.pending_job_count


#scheduler.instance_variable_get("@jobs").instance_variable_get("@jobs")[0].instance_variable_get("@at")


scheduler.instance_variable_get("@jobs").instance_variable_get("@jobs").each { |x|
	puts Time.at(x.instance_variable_get("@at").to_i).to_datetime 
}
