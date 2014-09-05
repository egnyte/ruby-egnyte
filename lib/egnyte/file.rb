module Egnyte
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
      @session.streaming_download( "#{fs_path('fs-content')}/#{URI.escape(path)}", opts )
    end

    def delete
      @session.delete("#{fs_path}/#{URI.escape(path)}")
    end

    def self.find(session, path)
      path = Egnyte::Helper.normalize_path(path)

      file = File.new({
        'path' => path
      }, session)
      
      parsed_body = session.get("#{file.fs_path}#{URI.escape(path)}")

      raise FileExpected if parsed_body['is_folder']

      file.update_data(parsed_body)
    end

  end
end
