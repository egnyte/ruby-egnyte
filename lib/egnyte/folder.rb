module Egnyte

  class Client
    def folder(path='Shared')
      Folder::find(@session, path)
    end
  end

  class Folder < Item
    def create(path)
      path = Egnyte::Helper.normalize_path(path)

      new_folder_path = "#{self.path}/#{path}"

      @session.post("#{fs_path}#{URI.escape(new_folder_path)}", JSON.dump({
        action: 'add_folder'
      }))

      Folder.new({
        'path' => new_folder_path,
        'folders' => [],
        'is_folder' => true,
        'name' => new_folder_path.split('/').pop
      }, @session)
    end

    def delete
      @session.delete("#{fs_path}/#{URI.escape(path)}")
    end

    def upload(filename, content)
      resp = @session.multipart_post("#{fs_path('fs-content')}#{URI.escape(path)}/#{URI.escape(filename)}", filename, content, false)

      content.rewind # to calculate size, rewind content stream.

      File.new({
        'is_folder' => false,
        'entry_id' => resp['ETag'],
        'checksum' => resp['X-Sha512-Checksum'],
        'last_modified' => resp['Last-Modified'],
        'name' => filename,
        'size' => content.size
      }, @session)
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
      
      parsed_body = session.get("#{folder.fs_path}#{URI.escape(path)}")

      raise FolderExpected unless parsed_body['is_folder']

      folder.update_data(parsed_body)
    end

    def permissions(params=nil)
      path = Egnyte::Helper.normalize_path(@data['path'])
      path += Egnyte::Helper.params_to_filter_string(params) if params
      @session.get("#{permission_path}/#{URI.escape(path)}")
    end

    def set_permission(permission_object)
      @session.post("#{permission_path}/#{URI.escape(path)}", permission_object.to_json, false)
    end

    private

    def create_objects(klass, key)
      return [] unless @data[key]
      @data[key].map do |data|
        data = data.merge({
          'path' => "#{path}/#{data['name']}"
        })
        klass.new(data, @session)
      end
    end

    def permission_path
      "https://#{@session.domain}.egnyte.com/#{@session.api}/v1/perms/folder"
    end

  end
end
