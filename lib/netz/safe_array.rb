require 'thread'
module Netz
  # a thread safe array class
  class SafeArray
    def initialize(items=[])
      @items = items
      @mutex = Mutex.new
    end

    def push(item)
      @mutex.synchronize {
        @items.push item
      }
      self
    end
    alias :<< :push

    def delete(item)
      @mutex.synchronize {
        @items.delete item
      }
    end

    def each(&block)
      @mutex.synchronize {
        @items.each(&block)
      }
      self
    end

    def empty?
      @mutex.synchronize {
        @items.empty?
      }
    end

    def size
      @mutex.synchronize {
        @items.size
      }
    end
  end
end