module Egnyte
  class Helper
    # removes leading and trailing '/'
    # from folder and file names.
    def self.normalize_path(path)
      path.gsub(/(^\/)|(\/$)/, '')
    end
  end
end
