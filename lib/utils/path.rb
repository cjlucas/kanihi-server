module MusicServer
  module Utils
    module Path
      def uri_to_path(uri)
        sanitize_path(URI.unescape(uri.path))
      end

      def sanitize_path(path)
        path = path.squeeze(::File::SEPARATOR)
        path[-1].eql?(::File::SEPARATOR) ? path[0..-2] : path
      end
    end
  end
end
