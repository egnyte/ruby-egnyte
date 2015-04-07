module Egnyte

  class Client

    def file(path)
      File::find(@session, path)
    end

  end

  class File < Item

    def download
      stream.read
    end

    # use opts to provide lambdas
    # to track the streaming download:
    #
    # :content_length_proc
    # :progress_proc
    def stream( opts={} )
      @session.streaming_download( "#{fs_path('fs-content')}#{path}", opts )
    end

    def delete
      @session.delete("#{fs_path}#{path}")
    end

    def self.find(session, path)
      path = Egnyte::Helper.normalize_path(path)

      file = File.new({
        'path' => path
      }, session)

      parsed_body = session.get("#{file.fs_path}#{path}")

      raise FileExpected if parsed_body['is_folder']

      file.update_data(parsed_body)
    end

  end
end
