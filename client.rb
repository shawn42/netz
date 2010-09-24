require 'thread'
require 'socket'
require 'command'
require 'broadcaster'
require 'catcher'
require 'lobby'

class Client
  MANAGEMENT_PORT = 7370
  INITIAL_PEER_PORT = 7374
  def initialize
    @port = INITIAL_PEER_PORT
    # TODO: THREADING THIS ...
    # setup_management_port
  end
  
  def host_lobby
    lobby = Lobby.new
    lobby.open_doors
    puts "Waiting for clients... enter when ready"
    gets

    puts "Starting the game."
    clients = lobby.close_doors
    setup_with_siblings clients
  end

  def setup_with_siblings(clients)
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

  def setup_management_port
    server = TCPServer.open MANAGEMENT_PORT
    @management_accept_thread = Thread.new do
      begin
        loop do
          peer = server.accept
          puts "YAY! peer connected!"

          ports = [@port]

          peer_server = TCPServer.open @port 
          peer << [@port].pack("S") 

          @peers << peer_server.accept
        end
      end
    end
    
  end

  def join(ip)
    lobby_accept = TCPSocket.new ip, 7373
    puts "joining"
    # connect to lobby client
    port = lobby_accept.recvfrom(2)[0].unpack("S")[0]
    p port
    lobby_accept.close
    puts "joined"
    host = TCPSocket.new ip, port

    # allow other clients to connect to you
    while true
      port = host.recvfrom(2)[0].unpack("S")[0]

      Thread.new do
        host = TCPSocket.new ip, port
        puts host.gets
      end
    end

    #host.close
  end
end
