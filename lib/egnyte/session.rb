require 'uri'
require 'oauth2'
require 'net/https'

module Egnyte
  class Session

    attr_accessor :domain, :api

    def initialize(opts, strategy=:implicit)

      @strategy = strategy # the authentication strategy to use.
      raise Egnyte::UnsupportedAuthStrategy unless @strategy == :implicit
      
      @api = 'pubapi' # currently we only support the public API.

      # the domain of the egnyte account to interact with.
      raise Egnyte::DomainRequired unless @domain = opts[:domain]

      @client = OAuth2::Client.new(opts[:key], nil, {
        :site => "https://#{@domain}.egnyte.com",
        :authorize_url => "/puboauth/token"
      })

      @access_token = OAuth2::AccessToken.new(@client, opts[:access_token]) if opts[:access_token]
    end

    def authorize_url(redirect_uri)
      @client.implicit.authorize_url(:redirect_uri => redirect_uri)
    end

    def create_access_token(token)
      @access_token = OAuth2::AccessToken.new(@client, token) if @strategy == :implicit
    end

    def get(url)
      uri = URI.parse(url)
      request = Net::HTTP::Get.new( uri.request_uri )
      resp = request( uri, request )
    end

    def post(url, body)
      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body
      request.content_type = "application/json"
      resp = request(uri, request)
    end

    private

    def request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.ssl_version = :SSLv3
      #http.set_debug_output($stdout)
      
      request.add_field('Authorization', "Bearer #{@access_token.token}")

      response = http.request(request)

      parse_response( response.code.to_i, response.body )
    end

    def parse_response( status, body )

      begin
        parsed_body = JSON.parse(body)
      rescue
        parsed_body = {}
      end

      case status / 100
      when 4
        #raise(RubyBox::ItemNameInUse.new(parsed_body), parsed_body["message"]) if parsed_body["code"] == "item_name_in_use"
        #raise(RubyBox::AuthError.new(parsed_body), parsed_body["message"]) if parsed_body["code"] == "unauthorized" || status == 401
        #raise(RubyBox::RequestError.new(parsed_body), parsed_body["message"])
      when 5
        #raise RubyBox::ServerError, parsed_body["message"]
      end
      
      parsed_body
    end

  end
end
