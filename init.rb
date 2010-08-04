require 'thread'
require 'command'
require 'socket'

require 'broadcaster'
require 'catcher'
require 'lobby'

lobby = Lobby.new
lobby.open_doors

puts "Waiting for clients... enter when ready"
gets

puts "Starting the game."
clients = lobby.close_doors

clients.each do |client|
  client.puts "HERE!!"
end

puts "DONE.. please continue"
gets

channel = Queue.new
broadcaster = Broadcaster.new
broadcaster.command_channel = channel
broadcaster.remote_clients = clients

catcher = Catcher.new
catcher.command_channel = channel
catcher.remote_clients = clients

catcher.run
broadcaster.run

loop do
  cmd = gets
  c = Command.new
  c.local = true if cmd.strip == "l"
  channel.push c
end
