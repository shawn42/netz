require 'thread'
require 'socket'
require 'command'
require 'broadcaster'
require 'catcher'
require 'lobby'
require 'safe_array'

module ManagementCommands
  PEER_CONNECT = 1
  START = 2
end

class Client
  include ManagementCommands
  MANAGEMENT_PORT = 7370
  INITIAL_PEER_PORT = 7374
  def initialize(management_port = MANAGEMENT_PORT)
    @management_port = management_port 
    @port = INITIAL_PEER_PORT
    @peers = SafeArray.new
    Thread.new do
      setup_management_port
    end
  end
  
  def start_all
    setup_with_siblings

    @peers.each do |peer_socket|
      to_send_address = peer_socket.peeraddr[3].split(":").last
      puts "STARTING... #{to_send_address}"
      peer_mng_socket = TCPSocket.new to_send_address, MANAGEMENT_PORT

      peer_mng_socket << [START].pack("C") 
      peer_mng_socket.close
    end
  end

  def add_peer(peer_socket)
    Thread.new do
      peer_server = TCPServer.open @port 
      peer = peer_server.accept
      @peers.push(peer)
    end
    #push port, then ip strings
    peer_socket << [@port].pack("I") 
    peer_socket << [@peers.size].pack("I") 
    @peers.each do |peer_socket|
      # TODO will this always be peeraddr? or sometime addr depending on Server vs Socket?
      to_send_address = peer_socket.peeraddr[3].split(":").last
      peer_socket << [to_send_address.length].pack("I") 
      peer_socket << to_send_address
    end
  end
  
  def setup_with_siblings
    puts "setting up siblings"
    @channel = Queue.new
    broadcaster = Broadcaster.new
    broadcaster.command_channel = @channel
    broadcaster.remote_clients = @peers

    catcher = Catcher.new
    catcher.command_channel = @channel
    catcher.remote_clients = @peers

    catcher.run
    broadcaster.run
    
    @channel.push Command.new
  end

  def setup_management_port
    puts "creating management port on #{@management_port}"
    begin
      server = TCPServer.open @management_port
      @management_accept_thread = Thread.new do
        begin
          loop do
            puts "trying to accept..."
            peer = server.accept
            puts "YAY! peer connected!"

            cmd = peer.recvfrom(1)[0].unpack("C")[0].to_i
            case cmd
            when PEER_CONNECT
              puts "connection from peer #{peer.inspect}"
              add_peer peer
            when START
              puts "got start"
              setup_with_siblings
            else
              puts "unknown cmd"
              p cmd
            end
            
          end
        end
      end
    rescue Exception => ex
      puts "client failed to open management port: #{ex}"
    end
    
  end
  
  def connect_to_peer(ip, port)
    puts "connecting to peer #{ip}:#{port}"
    @peers << TCPSocket.new(ip, port)
  end

  def join(ip)
    puts "trying to join #{ip}"
    @joined_peer_ips ||= []
    @joined_peer_ips << ip
    peer_accept = TCPSocket.new ip, MANAGEMENT_PORT
    peer_accept << [PEER_CONNECT].pack("C") 

    peer_ips = []
    join_port = peer_accept.recvfrom(4)[0].unpack("I")[0]
    puts "got join_port #{join_port}"
    num_additional_peers = peer_accept.recvfrom(4)[0].unpack("I")[0]
    puts "got num_additional_peers #{num_additional_peers}"
    num_additional_peers.times do
      puts "getting peer ip from stream"
      ip_length = peer_accept.recvfrom(4)[0].unpack("I")
      ip = peer_accept.recvfrom(ip_length)[0].unpack("a")
      peer_ips << ip unless @joined_peer_ips.include? ip
    end

    connect_to_peer ip, join_port
    
    peer_accept.close

    peer_ips.each do |pip|
      join pip
    end

  end
end
