module Egnyte 
  class EgnyteError < StandardError
    def initialize(error_json)
      @error_json = error_json
    end

    def [](key)
      @error_json[key]
    end
  end

  class FileOrFolderNotFound < StandardError; end
  class UnsupportedAuthStrategy < StandardError; end
  class RequestError < EgnyteError; end
end
