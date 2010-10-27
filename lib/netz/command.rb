module Netz
  class Command
    attr_writer :local
    def local?
      @local
    end
  end
end