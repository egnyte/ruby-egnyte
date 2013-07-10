module Egnyte
  class Client
    def initialize(session)
      @session = session
    end

    def folder(path='/')
      data = @session.access_token.get("#{fs_path}#{path}")
    end

    private

    def fs_path
      "https://#{@session.domain}.egnyte.com/#{@session.api}/v1/fs/"
    end
  end
end
