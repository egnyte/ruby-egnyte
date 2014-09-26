module Egnyte

  class Permission

    attr_accessor :data
    ### Representative Structure of @data
    # {
    #   'users': {
    #     'jsmith': 'Full',
    #     'jdoe': 'Editor'
    #   },
    #   'groups': {
    #     'employees': 'Full',
    #     'partners': 'Viewer'
    #   }
    # }

    def initialize(permissions_hash={})
      raise Egnyte::InvalidParameters unless (permissions_hash.empty? or permissions_hash['users'] or permissions_hash['groups'])
      @data = empty_permissions_hash
      merge!(permissions_hash)
    end

    def merge(new_perm_set)
      old_perm_set = @data.dup
      new_perm_set = new_perm_set.data if new_perm_set.class == Egnyte::Permission
      raise Egnyte::InvalidParameters unless new_perm_set.class == Hash
      new_perm_set.each do |type, perms_hash|
        perms_hash.each do |username, permission|
          old_perm_set[type][username] = permission
        end
      end
      old_perm_set
    end

    def merge!(new_perm_set)
      @data = merge(new_perm_set)
    end

    def empty_permissions_hash
      Egnyte::Permission.empty_permissions_hash
    end

    def self.empty_permissions_hash
      { 'users' => {}, 'groups' => {} }
    end

    def self.build_from_api_listing(json_listing)
      perm = empty_permissions_hash
      json_listing.each do |type, data|
        data.each do |item|
          perm[type][item["subject"]] = item["permission"]
        end
      end
      Egnyte::Permission.new(perm)
    end

    def self.folder_permissions(session, path, params=nil)
      path = Egnyte::Helper.normalize_path(path)
      path += Egnyte::Helper.params_to_filter_string(params) if params
      response = session.get("#{self.permission_path(session)}/#{URI.escape(path)}")
      self.build_from_api_listing(response)
    end

    def self.inherited_permissions(session, path, params=nil)
      path = Egnyte::Helper.normalize_path(path)
      path = path.split('/')[0..-2].join('/')
      self.folder_permissions(session, path, params)
    end

    def self.original_permissions(session, path, params=nil)
      inherited = self.inherited_permissions(session, path, params).data
      permissions = self.folder_permissions(session, path, params).data
      original = self.empty_permissions_hash

      #filter out permissions that exist in the parent folder's permissions
      permissions.each do |type, perm|
        perm.each do |k,v|
          original[type][k] = v unless inherited[type][k] == v
        end
      end
      self.new(original)
    end

    def self.permission_path(session)
      "https://#{session.domain}.egnyte.com/#{session.api}/v1/perms/folder"
    end

    def valid?
      return @data['users'].class == Hash && @data['groups'].class == Hash
    end

    def has_data?
      return @data['users'].size > 0 || @data['groups'].size > 0
    end

    def empty?
      return !has_data?
    end

    def to_hash
      @data
    end

    def to_json
      to_hash.to_json
    end

    def self.transfrom_by_perm_level(permission_object)
      perm_type_hash = {
        'users' => { "Viewer" => [], "Editor" => [], "Full"   => [], "Owner"  => [] },
        'groups' => { "Viewer" => [], "Editor" => [], "Full"   => [], "Owner"  => [] }
      }
      permission_object.data.each do |type, perm|
        perm.each do |k,v|
          perm_type_hash[type][v] << k
        end
      end
      perm_type_hash
    end

    def self.apply(session, permission_object, target_path)
      if permission_object.valid? and permission_object.has_data?
        permissions_set = transfrom_by_perm_level(permission_object)
        ["Viewer", "Editor", "Full", "Owner"].each do |level|
          tmp_hash = {}
          tmp_hash['users']  = permissions_set['users'][level] unless permissions_set['users'][level].empty?
          tmp_hash['groups'] = permissions_set['groups'][level] unless permissions_set['groups'][level].empty?
          tmp_hash['permission'] = level
          session.post("#{self.permission_path(session)}/#{URI.escape(target_path)}", tmp_hash.to_json, false)
        end
        "Permissions set on #{target_path}: #{permission_object.to_hash}"
      end
    end

  end

end
