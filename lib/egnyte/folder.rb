module Egnyte
  class Folder < Item
    def create(path)
      path = Egnyte::Helper.normalize_path(path)

      new_folder_path = [self.path.split('/'), path.split('/')].flatten.join('/')
      
      @session.post("#{fs_path}#{new_folder_path}", JSON.dump({
        action: 'add_folder'
      }))

      Folder::find(@session, new_folder_path)
    end

    def files
      create_objects(File, 'files')
    end

    def folders
      create_objects(Folder, 'folders')
    end

    def self.find(session, path)
      path = Egnyte::Helper.normalize_path(path)

      folder = Folder.new({
        'path' => path
      }, session)
      
      parsed_body = session.get("#{folder.fs_path}#{path}")

      raise FolderExpected unless parsed_body['is_folder']

      folder.update_data(parsed_body)
    end

    private

    def create_objects(klass, key)
      @data[key].map do |data|
        data = data.merge({
          'path' => "#{path}/#{data['name']}"
        })
        klass.new(data, @session)
      end
    end
  end
end
