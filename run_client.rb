require 'client'

client = Client.new(7379)
client.join "localhost"
