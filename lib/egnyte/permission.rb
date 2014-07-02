module Egnyte

  class Permission

    attr_accessor :users, :groups, :permission_level

    def initialize(permissions_hash)
      @users = permissions_hash[:users].class == Array ? permissions_hash[:users] : []
      @groups = permissions_hash[:groups].class == Array ? permissions_hash[:groups] : []
      @permission_level = permissions_hash[:permission] unless permissions_hash[:permission].nil?
    end

    def valid?
      return (@users && @groups) && (@users.class == Array && @groups.class == Array) && (@users.size > 0 || @groups.size > 0)
    end

    def to_hash
      hash = {}
      hash[:users] = @users unless @users == []
      hash[:groups] = @groups unless @groups == []
      hash[:permission] = @permission_level if @permission_level
      hash
    end

    def to_json
      to_hash.to_json
    end

  end

end
