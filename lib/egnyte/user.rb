module Egnyte

  # How to convert a user to SSO?

  class Client

    def users
      User::all(@session)
    end

    def users_where(params)
      User::where(@session, params)
    end

    def user(id)
      User::find(@session, id)
    end

    def user_by_email(email)
      User::find_by_email(@session, email)
    end

    def create_user(params)
      User::create(@session, params)
    end

    def delete_user(id)
      User::delete(@session, id)
    end

  end

  class User

    @@required_attributes = ['userName', 'email', 'familyName', 'givenName', 'authType', 'userType']
    attr_accessor :userName, :email, :formatted, :familyName, :givenName, :authType, :userType, :active, :sendInvite, :externalId, :idpUserId, :userPrincipalName
    attr_reader :id

    def initialize(session, params)
      @session = session
      params.each do |k,v|
        if k.to_s == "name" # dig into nested name if passed in Egnyte format
          params[k].each do |name_k,v|
            instance_variable_set("@#{name_k}", v)
          end
        else
          instance_variable_set("@#{k}", v)
        end
      end
    end

    def self.all(session)
      self.where(session)
    end

    def self.create(session, params)
      user = self.new(session, params)
      user.save
    end

    def self.find(session, id)
      response = session.get("#{self.user_path(session)}/#{id}", return_parsed_response=true)
      self.new(session, response)
    end

    def self.find_by_email(session, email)
      self.where(session, {"email" => email}).first
    end

    def self.where(session, params=nil)
      startIndex = 1
      user_count = nil
      itemsPerPage = 100
      user_list = []
      base_url = self.user_path(session)
      base_url += Egnyte::Helper.params_to_filter_string(params) if params
      while startIndex == 1 || user_count > startIndex
        url = base_url
        url += params.nil? ? '?' : '&'
        url += "startIndex=#{startIndex}&count=#{itemsPerPage}"
        parsed_body = session.get(url)
        parsed_body["resources"].each do |user_hash|
          user_list << self.new(session, user_hash)
        end
        user_count = parsed_body["totalResults"]
        startIndex += itemsPerPage
      end
      user_list
    end

    def save
      raise Egnyte::MissingAttribute.new(missing_attributes) unless valid?
      response = ''
      if @id.nil? or @id.to_s.empty?
        response = @session.post(user_path, to_json, return_parsed_response=true)
        @id = response['id']
      else
        response = @session.patch("#{user_path}/#{@id}", to_json_for_update, return_parsed_response=true)
      end
      user = Egnyte::User.new(@session, response)
    end

    def delete
      self.delete(@session, @id)
    end

    def self.delete(session, id)
      session.delete("#{self.user_path(session)}/#{id}", return_parsed_response=true)
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

    def to_json
      hash = {name:{}}
      instance_variables.each do |iv|
        next if iv == :@session
        next if instance_variable_get(iv) == nil
        if [:@formatted, :@givenName, :@familyName].include? iv
          hash[:name][iv.to_s[1..-1]] = instance_variable_get(iv)
        else
          hash[iv.to_s[1..-1]] = instance_variable_get(iv)
        end
      end
      hash.to_json
    end

    def to_json_for_update
      hash = {}
      instance_variables.each do |iv|
        # next if [:@session, :@id, :@userName, :@sendInvite, :@userPrincipalName, :@emailChangePending, :@locked, :@externalId].include? iv
        next if instance_variable_get(iv) == nil || instance_variable_get(iv) == ''
        if [:@email, :@formatted, :@givenName, :@familyName, :@active, :@authType, :@userType, :@idpUserId, :@userPrincipalName].include? iv
          next if [:@formatted, :@givenName, :@familyName].include? iv  # temporary fix since API does not properly respond for these fields.
          hash[iv.to_s[1..-1]] = instance_variable_get(iv)
        end
      end
      hash.to_json
    end

    def user_path
      "https://#{@session.domain}.egnyte.com/#{@session.api}/v2/users"
    end

    def self.user_path(session)
      "https://#{session.domain}.egnyte.com/#{session.api}/v2/users"
    end

  end
end
