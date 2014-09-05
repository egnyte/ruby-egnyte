module Egnyte
  class Client
    def initialize(session)
      @session = session
    end

    def file(path)
      File::find(@session, path)
    end
  end
end
