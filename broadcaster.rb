require 'command_serializer'
class Broadcaster
  attr_accessor :remote_clients, :command_channel

  def initialize
    @remote_clients = []
  end

  def run
    Thread.new do
      loop do
        command = @command_channel.pop
        push_to_peers command if command.local?
      end
    end
  end

  def push_to_peers(command)
    # TODO add command buffering?
    command.extend(CommandSerializer)

    # write to clients
    msg = command.serialize
    puts msg
    @remote_clients.each do |rc|
      rc.write [msg.length].pack("S")
      rc.write msg
    end
  end
end
