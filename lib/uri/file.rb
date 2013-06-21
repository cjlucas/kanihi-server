require 'uri'

module URI
  class File
    include URI
    attr_reader :path

    def initialize(scheme,
                   userinfo, host, port, registry,
                   path, opaque,
                   query,
                   fragment,
                   parser = DEFAULT_PARSER,
                   arg_check = false)
      @scheme = nil
      @user = nil
      @password = nil
      @host = nil
      @port = nil
      @path = nil
      @query = nil
      @opaque = nil
      @registry = nil
      @fragment = nil
      @parser = parser == DEFAULT_PARSER ? nil : parser

      
      self.scheme = scheme || 'file'
      self.host = host || 'localhost'
      self.path = path
    end

    def self.new_with_path(path)
      self.new('file', nil, nil, nil, nil, path, nil, nil, nil)
    end

    def ==(other)
      if other.is_a?(self.class)
        path_norm.eql?(other.path_norm)
      else
        false
      end
    end

    def path_norm
      path = @path.squeeze(::File::SEPARATOR)
      path[-1].eql?(::File::SEPARATOR) ? path[0..-2] : path
    end
 
    def scheme=(scheme)
      @scheme = scheme ? scheme.downcase : scheme
    end
    protected :scheme=
    
    def path=(path)
      @path = self.class.escape_path(URI.unescape(path))
    end
    protected :path=

    # filesystem path
    def fpath
      URI.unescape(@path)
    end

    def host=(host)
      @host = host
    end
    protected :host=

    def exists?
      path = URI.unescape(@path)
      ::File.exists?(path) || ::Dir.exists?(path)
    end

    def self.escape_path(path)
      path = URI.escape(path)
      URI.escape(path, '^[]\,\'\"')
    end

    def to_s
      s = ''
      s << @scheme
      s << ':'
      s << '//'
      s << @host
      s << @path
    end

  end
  @@schemes['FILE'] = File
end

