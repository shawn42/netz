require 'client'

client = Client.new
client.join ARGV.pop

puts "client is waiting..."
gets
