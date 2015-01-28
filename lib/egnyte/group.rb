module Egnyte

  class Client

    def groups
      Group::all(@session)
    end

    def groups_where(params)
      Group::where(@session, params)
    end

    def search_groups(search_string)
      Group::search(@session, search_string)
    end

    def group(id)
      Group::find(@session, id)
    end

    def group_by_name(name)
      Group::where(@session, {:displayName => name}).first
    end

    def create_group(params)
      Group::create(@session, params)
    end

    def delete_group(id)
      Group::delete(@session, id)
    end

  end

  class Group

    @@required_attributes = ['displayName']
    attr_accessor :displayName, :members
    attr_reader :id

    def initialize(session, params)
      @session = session
      if params.is_a? String
        @displayName = params
      elsif params.is_a? Hash
        params.each do |k,v|
          if k == "name"
            @displayName = v
          else
            instance_variable_set("@#{k}", v)
          end
        end
      end
      @members = [] if @members.nil?
    end

    def self.all(session)
      self.where(session)
    end

    def self.create(session, params)
      group = self.new(session, params)
      group.save
    end

    def name
      @displayName
    end

    def name=(name)
      @displayName = name
    end

    def self.find(session, id)
      response = session.get("#{self.group_path(session)}/#{id}", return_parsed_response=true)
      self.new(session, response)
    end

    def self.find_by_name(session, displayName)
      self.where(session, {:displayName => displayName}).first
    end

    def self.where(session, params=nil)
      startIndex = 1
      group_count = nil
      itemsPerPage = 100
      group_list = []
      base_url = self.group_path(session)
      base_url += Egnyte::Helper.params_to_filter_string(params) if params
      while startIndex == 1 || group_count > startIndex
        url = base_url
        url += params.nil? ? '?' : '&'
        url += "startIndex=#{startIndex}&count=#{itemsPerPage}"
        parsed_body = session.get(url)
        parsed_body["resources"].each do |group_hash|
          group_list << self.new(session, group_hash)
        end
        group_count = parsed_body["totalResults"]
        startIndex += itemsPerPage
      end
      group_list
    end

    def self.search(session, search_string)
      group_list = self.all(session)
      result_list = []
      group_list.each do |user|
        catch(:found) do 
          user.instance_variables.each do |ivar|
            value = user.instance_variable_get(ivar).to_s
            if value.match(search_string)
              result_list << user
              throw :found
            end
          end
        end
      end
      result_list
    end

    def save
      raise Egnyte::MissingAttribute.new(missing_attributes) unless valid?
      response = ''
      if @id.nil? or @id.to_s.empty?
        response = @session.post(group_path, to_json_for_api_call)
        @id = response['id']
      else
        response = @session.put("#{group_path}/#{@id}", to_json_for_api_call)
      end
      Egnyte::Group.new(@session, response)
    end

    def delete
      Egnyte::Group.delete(@session, @id)
    end

    def self.delete(session, id)
      session.delete("#{self.group_path(session)}/#{id}", return_parsed_response=true)
    end

    def valid?
      return missing_attributes.size < 1
    end

    def missing_attributes
      missing = @@required_attributes.collect do |param|
        param unless instance_variable_get("@#{param}")
      end
      missing.compact
    end

    def to_hash
      hash = to_hash_for_api_call
      hash[:id] = @id
      hash
    end

    def to_json
      to_hash.to_json
    end

    def to_hash_for_api_call
      hash = {}
      hash[:displayName] = @displayName
      hash[:members] = []
      @members.each do |group_member|
        hash[:members] << {"value" => group_member}
      end
      hash
    end

    def to_json_for_api_call
      to_hash_for_api_call.to_json
    end

    def group_path
      Egnyte::Group.group_path(@session)
    end

    def self.group_path(session)
      "https://#{session.domain}.#{EGNYTE_DOMAIN}/#{session.api}/v2/groups"
    end

  end
end
