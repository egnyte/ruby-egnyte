require 'json'

module Egnyte
  class Folder < Item
    def create(path)
      new_folder_path = [self.path.split('/'), path.split('/')].flatten.join('/')
      @session.post("#{fs_path}#{new_folder_path}", JSON.dump({
        action: 'add_folder'
      }))
    end

    def self.find(session, path)
      folder = Folder.new({
        'path' => path
      }, session)
      
      parsed_body = session.get("#{folder.fs_path}#{path}")

      folder.update_data(parsed_body)
    end
  end
end
