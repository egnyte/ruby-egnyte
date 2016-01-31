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

    def download_version(entry_id)
      stream(:entry_id => entry_id).read
    end

    # use opts to provide lambdas
    # to track the streaming download:
    #
    # :content_length_proc
    # :progress_proc
    def stream( opts={} )
      file_content_path = "#{fs_path('fs-content')}#{Egnyte::Helper.normalize_path(path)}"
      file_content_path += "?entry_id=#{opts[:entry_id]}" if opts[:entry_id]
      puts file_content_path
      @session.streaming_download(file_content_path, opts )
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
