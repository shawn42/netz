module CommandSerializer
  def serialize
    self.to_s
  end

  def self.deserialize(cmd)
    cmd = Command.new
    #cmd.stuff = blah
    cmd
  end
end
