module Egnyte
  class EgnyteError < StandardError
    def initialize(data)
      super(data.to_s)
      @data = data
    end

    def [](key)
      @data[key]
    end
  end

  class UnsupportedAuthStrategy < StandardError; end
  class InvalidParameters < StandardError; end
  class FileExpected < StandardError; end
  class FolderExpected < StandardError; end
  class RecordNotFound < EgnyteError; end
  class RequestError < EgnyteError; end
  class BadRequest < EgnyteError; end
  class NotAuthorized < EgnyteError; end
  class InsufficientPermissions < EgnyteError; end
  class DuplicateRecordExists < EgnyteError; end
  class FileSizeExceedsLimit < EgnyteError; end
  class ClientIdRequired < EgnyteError; end
  class DomainRequired < EgnyteError; end
  class OAuthUsernameRequired < StandardError; end
  class OAuthPasswordRequired < StandardError; end
  class MissingAttribute < EgnyteError; end
end
