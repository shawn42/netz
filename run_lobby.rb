require 'netz'

c = Netz::Client.new
puts "waiting..."
gets
c.start_all

puts "DONE.. please continue"
gets