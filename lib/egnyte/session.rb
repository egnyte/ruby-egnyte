require 'oauth2'

module Egnyte
  class Session

    attr_accessor :access_token, :domain, :api

    def initialize(opts, strategy=:implicit)
      raise Egnyte::UnsupportedAuthStrategy unless strategy == :implicit
      
      @api = 'pubapi' # currently we only support the public API.

      raise Egnyte::DomainRequired unless @domain = opts[:domain]

      @client = OAuth2::Client.new(opts[:key], nil, {
        :site => "https://#{@domain}.egnyte.com",
        :authorize_url => "/puboauth/token"
      })

      @access_token = OAuth2::AccessToken.new(@client, opts[:access_token]) if opts[:access_token]
    end
  end
end
