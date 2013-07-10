module Egnyte
  class Item

    def initialize(data, client)
      @data = data
      @client = @client
    end

    def method_missing(method, *args, &block)
      key = method.to_s
      @data[key]
    end
  end
end