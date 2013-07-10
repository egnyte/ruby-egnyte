module Egnyte 
  class EgnyteError < StandardError
    def initialize(data)
      @data = data
    end

    def [](key)
      @data[key]
    end
  end

  class UnsupportedAuthStrategy < StandardError; end
  class FileFolderNotFound < EgnyteError; end
  class RequestError < EgnyteError; end
  class BadRequest < EgnyteError; end
  class NotAuthorized < EgnyteError; end
  class InsufficientPermissions < EgnyteError; end
  class FileFolderDuplicateExists < EgnyteError; end
  class FileSizeExceedsLimit < EgnyteError; end
end
