require 'thread'
require 'broadcaster'
require 'command'

channel = Queue.new

broadcaster = Broadcaster.new
broadcaster.command_channel = channel

broadcaster.run

loop do
  cmd = gets
  c = Command.new
  c.local = true if cmd.strip == "l"
  channel.push c
end

