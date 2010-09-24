# when client X connects, give him a list of ports to listen on
# tell all clients not me or X to connect to X on next available port
# don't close "handshake" sockets until lobby closes its doors
class Lobby
  attr_accessor :clients

  # allow clients to connect and register themselves to setup the p2p
  def open_doors
    @next_client_port = 7374

    # only the accept thread is allowed to access @lobby_clients 
    # (or after accept thread is dead)
    @lobby_clients = []


    # TODO pull this into something that calls yield
    @clients = Queue.new
    server = TCPServer.open 7373
    @accept_thread = Thread.new do
      begin
        while true
          client = server.accept
          puts "YAY! #{client} connected!"
          port_message = [@next_client_port].pack("S") 
          STDERR.puts port_message.inspect
          STDERR.flush

          client_server = TCPServer.open @next_client_port
          client << port_message
          @next_client_port += 1
 
          client_socket = client_server.accept
          puts "#{client} completed join"
          @clients << client_socket
          @lobby_clients << client
        end
      ensure
        server.close
      end

    end
  end

  def close_doors
    @accept_thread.kill
    @lobby_clients.each do |lobby_client|
      lobby_client.pop.close
    end

    remote_clients = []
    while @clients.length > 0
      remote_clients << @clients.pop
    end

    addresses = remote_clients.map{|rc|
      "#{rc.addr[3]}:#{rc.addr[1]}"
    }.join(",")

    remote_clients.each do |client|
      rc.write [addresses.length].pack("S")
      rc.write addresses
    end

    remote_clients
  end
end
