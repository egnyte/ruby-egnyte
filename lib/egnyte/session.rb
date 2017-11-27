require 'os'

module Egnyte
  class Session

    attr_accessor :domain, :api, :username
    attr_reader :access_token

    def initialize(opts, strategy=:implicit, backoff=0.5)

      @strategy = strategy # the authentication strategy to use.
      raise Egnyte::UnsupportedAuthStrategy unless [:implicit, :password].include? @strategy

      @backoff = backoff # only two requests are allowed a second by Egnyte.
      @api = 'pubapi' # currently we only support the public API.

      @username = opts[:username]

      # the domain of the egnyte account to interact with.
      raise Egnyte::DomainRequired unless @domain = opts[:domain]

      @client = OAuth2::Client.new(opts[:key], nil, {
        :site => "https://#{@domain}.#{EGNYTE_DOMAIN}",
        :authorize_url => "/puboauth/token",
        :token_url => "/puboauth/token"
      })

      if @strategy == :implicit
        @access_token = OAuth2::AccessToken.new(@client, opts[:access_token]) if opts[:access_token]
      elsif @strategy == :password
        if opts[:access_token]
          @access_token = OAuth2::AccessToken.new(@client, opts[:access_token])
        else
          raise Egnyte::OAuthUsernameRequired unless @username
          raise Egnyte::OAuthPasswordRequired unless opts[:password]
          if true #OS.windows?
            body = {
              :client_id => opts[:key],
              :username => @username,
              :password => opts[:password],
              :grant_type => 'password'
            }.map {|k,v| "#{k}=#{v}"}.join("&")
            url = "https://#{@domain}.#{EGNYTE_DOMAIN}/puboauth/token"
            response = login_post(url, body, return_parsed_response=true)
            @access_token = OAuth2::AccessToken.new(@client, response["access_token"])
          else
            @access_token = @client.password.get_token(@username, opts[:password])
          end
        end
        @username = info["username"] unless @username
      end

    end

    def info
      information
    end

    def information
      get("https://#{@domain}.#{EGNYTE_DOMAIN}/#{@api}/v1/userinfo", return_parsed_response=true)
    end

    def authorize_url(redirect_uri)
      @client.implicit.authorize_url(:redirect_uri => redirect_uri)
    end

    def create_access_token(token)
      @access_token = OAuth2::AccessToken.new(@client, token) if @strategy == :implicit
    end

    def get(url, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Get.new( uri.request_uri )
      resp = request( uri, request, return_parsed_response )
    end

    def delete(url, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Delete.new( uri.request_uri )
      resp = request( uri, request, return_parsed_response )
    end

    def post(url, body, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body
      request.content_type = "application/json"
      resp = request(uri, request, return_parsed_response)
    end

    def login_post(url, body, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body
      request.content_type = "application/x-www-form-urlencoded"
      resp = request(uri, request, return_parsed_response)
    end

    def patch(url, body, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Patch.new(uri.request_uri)
      request.body = body
      request.content_type = "application/json"
      resp = request(uri, request, return_parsed_response)
    end

    def put(url, body, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = body
      request.content_type = "application/json"
      resp = request(uri, request, return_parsed_response)
    end

    def multipart_post(url, filename, data, return_parsed_response=true)
      uri = URI.parse(Egnyte::Helper.encode_url(url))

      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = data.read
      request.content_type = 'application/binary'

      resp = request(uri, request, return_parsed_response)
    end

    # perform a streaming download of a file
    # rather than in-memory.
    def streaming_download(url, opts)
      uri = URI.parse(Egnyte::Helper.encode_url(url))

      params = {
        :content_length_proc => opts[:content_length_proc],
        :progress_proc => opts[:progress_proc],
        'Authorization' => "Bearer #{@access_token.token}"
      }

      open(uri, params)
    end

    private

    def request(uri, request, return_parsed_response=true)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      if OS.windows? # Use provided certificate on Windows where gem doesn't have access to a cert store.
        http.cert_store = OpenSSL::X509::Store.new
        http.cert_store.set_default_paths
        http.cert_store.add_file("#{::File.dirname(__FILE__)}/../../includes/cacert.pem")
      end
      #http.set_debug_output($stdout)

      unless request.content_type == "application/x-www-form-urlencoded"
        request.add_field('Authorization', "Bearer #{@access_token.token}")
      end

      response = http.request(request)

      # Egnyte throttles requests to
      # two requests per second by default.
      sleep(@backoff)

      # puts "#{response.code.to_i} ||||| #{response.body}"


      return_value = return_parsed_response ? parse_response_body(response.body) : response
      parse_response_code(response.code.to_i, return_value, response)

      return_value
    end

    def parse_response_code(status, response_body, response)
      case status
      when 400
        raise BadRequest.new(response_body)
      when 401
        raise NotAuthorized.new(response_body)
      when 403
        case response.header['X-Mashery-Error-Code']
        when "ERR_403_DEVELOPER_OVER_QPS"
          raise RateLimitExceededQPS.new(response_body, response.header['Retry-After']&.to_i)
        else
          raise InsufficientPermissions.new(response_body)
        end
      when 404
        raise RecordNotFound.new(response_body)
      when 405
        raise DuplicateRecordExists.new(response_body)
      when 413
        raise FileSizeExceedsLimit.new(response_body)
      end

      # Handle all other request errors.
      raise RequestError.new(response_body) if status >= 400
    end

    def parse_response_body(body)
      JSON.parse(body)
    rescue
      {original_body: body} # return original_body as a json hash if unparseable
    end

  end
end
