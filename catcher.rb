module Netz
  class Catcher
    attr_accessor :remote_clients, :command_channel

    def initialize()
      @remote_clients = []
    end

    def run
      #thread per client?
      @remote_clients.each do |rc|
        Thread.new do
          loop do
            read_command(rc)
          end
        end
      end
    end

    def read_command(remote_client)
      length = remote_client.recvfrom(2)[0].unpack("S")[0]
      cmd = CommandSerializer.deserialize(remote_client.recvfrom(length))
      @command_channel << cmd 
    end
  end
end