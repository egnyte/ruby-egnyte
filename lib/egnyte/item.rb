module Egnyte
  class Item
    def initialize(data, session)
      @data = data
      @session = session
    end

    def method_missing(method, *args, &block)
      @data[method.to_s]
    end

    def update_data(data)
      @data = @data.update(data)
      self
    end

    # mode can be either fs, or fs-content.
    def fs_path(mode='fs')
      "https://#{@session.domain}.egnyte.com/#{@session.api}/v1/#{mode}/"
    end
  end
end
