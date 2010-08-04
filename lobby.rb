# when client X connects, give him a list of ports to listen on
# tell all clients not me or X to connect to X on next available port
# don't close "handshake" sockets until lobby closes its doors
class Lobby
  attr_accessor :clients

  # allow clients to connect and register themselves to setup the p2p
  def open_doors
    @port = 7373
    @clients = Queue.new
    server = TCPServer.open 7373
    @accept_thread = Thread.new do
      begin
        while true
          client = server.accept
          puts "YAY! #{client} connected!"
          @port += 1
          client << [@port].pack("S") 
          client_server = TCPServer.open @port 
          client_socket = client_server.accept
          @clients << client_socket
          client.close
        end
      ensure
        server.close
      end

    end
  end

  def close_doors
    @accept_thread.kill
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
