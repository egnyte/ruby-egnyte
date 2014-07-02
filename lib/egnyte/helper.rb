module Egnyte
  class Helper

    # removes leading and trailing '/'
    # from folder and file names.
    def self.normalize_path(path)
      path.gsub(/(^\/)|(\/$)/, '')
    end

    def self.params_to_s(params)
      str = ''
      if params
        str = "?"
        params.each_with_index do |(k,v),i|
          v.split('|') if v.instance_of? Array
          str += URI.escape("#{k}=#{v}")
          str += "&" unless i == params.size - 1
        end
      end
      return str
    end

    def self.params_to_filter_string(params)
      str = ''
      if params
        str = "?"
        params.each_with_index do |(k,v),i|
          str += "filter="
          str += URI.escape("#{k} eq \"#{v}\"")
          str += "&" unless i == params.size - 1
        end
      end
      return str
    end

  end
end
