module Egnyte
  class File < Item
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
