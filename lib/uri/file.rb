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

      if arg_check
        self.scheme = scheme
        #self.userinfo = userinfo
        #self.host = host
        #self.port = port
        self.path = path
        #self.query = query
        #self.opaque = opaque
        #self.registry = registry
        #self.fragment = fragment
      else
        self.set_scheme(scheme)
        #self.set_userinfo(userinfo)
        #self.set_host(host)
        #self.set_port(port)
        self.set_path(path)
        #self.set_query(query)
        #self.set_opaque(opaque)
        #self.set_registry(registry)
        #self.set_fragment(fragment)
      end
    end

    def self.new_with_path(path)
      self.new('file', nil, nil, nil, nil, escape_path(path), nil, nil, nil)
    end

    # ensure we get a new uri suitible for comparison
    def self.new_with_uri_string(uri_s)
      uri = URI(uri_s)
      path = URI.unescape(uri.path)
      self.new_with_path(path)
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
 
    def set_scheme(v)
      @scheme = v ? v.downcase : v
    end
    protected :set_scheme
    
    def set_path(v)
      @path = v
    end
    protected :set_path

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
      s << @path
    end

  end
  @@schemes['FILE'] = File
end

