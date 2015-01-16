module Egnyte

  class Client

    def links
      Link::all(@session)
    end

    def links_where(params)
      Link::where(@session, params)
    end

    def link(id)
      Link::find(@session, id)
    end

    def create_link(params)
      Link::create(@session, params)
    end

    def delete_link(id)
      Link::delete(@session, id)
    end

  end

  class Link

    @@required_attributes = ['path', 'type', 'accessibility']
    attr_accessor :path, :type, :accessibility, :send_email, :recipients, :messages, :copy_me, :notify, :link_to_current, :expiry_date, :expiry_clicks, :add_filename, :creation_date
    attr_reader :id

    def initialize(session, params)
      @session = session
      params.each do |k,v|
        instance_variable_set("@#{k}", v)
      end
    end

    def self.all(session)
      self.where(session)
    end

    def self.create(session, params)
      link = self.new(session, params)
      link.save
    end

    def self.find(session, id)
      response = session.get("#{self.link_path(session)}/#{id}", return_parsed_response=true)
      self.new(session, response)
    end

    def self.where(session, params=nil)
      url = self.link_path(session)
      url += Egnyte::Helper.params_to_s(params) if params
      parsed_body = session.get(url)
      parsed_body["ids"].nil? ? [] : parsed_body["ids"]
    end

    def save
      raise Egnyte::MissingAttribute.new(missing_attributes) unless valid?
      response = @session.post(link_path, to_json, return_parsed_response=true)
      link = Egnyte::Link.find(@session, response['links'].first['id'])
      link.instance_variables.each do |ivar|
        instance_variable_set(ivar, link.instance_variable_get(ivar))
      end
      self
    end

    def delete
      Egnyte::Link.delete(@session, @id)
    end

    def self.delete(session, id)
      session.delete("#{self.link_path(session)}/#{id}", return_parsed_response=false)
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
      hash = {}
      instance_variables.each do |iv|
        next if [:@session, :@client].include? iv
        next if instance_variable_get(iv) == nil
        hash[iv.to_s[1..-1]] = instance_variable_get(iv)
      end
      hash.to_json
    end

    def link_path
      Egnyte::Link.link_path(@session)
    end

    def self.link_path(session)
      "https://#{session.domain}.#{EGNYTE_DOMAIN}/#{session.api}/v1/links"
    end

  end
end
