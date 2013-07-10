module Egnyte 
  class EgnyteError < StandardError
    def initialize(error_json)
      @error_json = error_json
    end

    def [](key)
      @error_json[key]
    end
  end

  class UnsupportedAuthStrategy  < StandardError; end
end
