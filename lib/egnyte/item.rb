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

    def move_or_copy(destination_path, action)
      item_path = "#{fs_path}#{URI.escape(Egnyte::Helper.normalize_path(path))}"
      @session.post(item_path, { action: action, destination: destination_path }.to_json, return_parsed_response=true)
    end

    def move(destination_path)
      move_or_copy(destination_path, 'move')
    end

    def copy(destination_path)
      move_or_copy(destination_path, 'copy')
    end

  end
end
