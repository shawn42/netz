require 'client'

c = Client.new

loop do
  cmd = gets
  c = Command.new
  c.local = true if cmd.strip == "l"
  channel.push c
end
