require 'net/http'

module MusicServer
  module Command
    module Common

      def user_confirmation
        input = nil
        until input =~ /^(ye?s?|no?)$/i
          print 'Are you sure? [y/n]: '
          input = gets.strip
          #puts "you entered \"#{input}\""
        end

        input.match(/^no?$/i).nil?
      end

      def base_uri
        URI("http://localhost:#{AppConfig[:port]}")
      end

      def server_connection
        uri = base_uri
        Net::HTTP.new(uri.host, uri.port)
      end

      def server_connectable?
        http = server_connection
        http.head('/').is_a?(Net::HTTPSuccess)
      end

      def assert_server_connectable
        unless server_connectable?
          puts "ERROR: Cannot connect to #{base_uri}. Exiting."
          exit!
        end
      end

      def clone_and_empty_argv
        cloned = ARGV.dup
        ARGV.clear
        cloned
      end
    end
  end
end

