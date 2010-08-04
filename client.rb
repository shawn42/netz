require 'thread'
require 'socket'
require 'command'
require 'broadcaster'
require 'catcher'
require 'lobby'

class Client
  def host_lobby
    lobby = Lobby.new
    lobby.open_doors
    puts "Waiting for clients... enter when ready"
    gets

    puts "Starting the game."
    clients = lobby.close_doors

    @channel = Queue.new
    broadcaster = Broadcaster.new
    broadcaster.command_channel = @channel
    broadcaster.remote_clients = clients

    catcher = Catcher.new
    catcher.command_channel = @channel
    catcher.remote_clients = clients

    catcher.run
    broadcaster.run
  end

  def join(ip)
    host = TCPSocket.new ip, 7373
    port = host.recvfrom(2)[0].unpack("S")[0]
    host.close
    host = TCPSocket.new ip, port
    puts host.gets
  end
end