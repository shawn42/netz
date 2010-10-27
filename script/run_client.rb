require 'netz'

client = Netz::Client.new
client.join ARGV.pop

puts "client is waiting..."
gets
