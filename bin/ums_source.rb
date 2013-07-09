module MusicServer
  module Command
    module Source
      include Common
      include ActionView::Helpers::DateHelper

      UNSAFE = URI::REGEXP::PATTERN::RESERVED + ' '

      #
      # helpers
      #
      
      def source_type_for_path(path)
        case
        when File.directory?(path)
          0 # DIRECTORY
        when File.file?(path) && File.extname(path).downcase.eql?('.xml')
          1 # ITUNES_LIBRARY_XML_FILE
        else
          -1
        end
      end

      def source_uri
        base_uri.dup.tap { |uri| uri.path = '/sources' } 
      end

      def source_uri_with_path(path)
        source_uri.tap { |uri| uri.path << path }
      end


      #
      # actions
      #
      
      def get_sources
        uri = URI("#{source_uri}.json")
        data = Net::HTTP.get(uri)
        puts "ERROR: couldn't load sources from #{uri}" if data.nil?
        data.nil? ? [] : JSON.load(data)
      end

      def add_source(path)
        uri = source_uri_with_path('/new')
        path = File.expand_path(path)
        src_type = source_type_for_path(path)

        uri.query = "location=#{URI.escape(path, UNSAFE)}&type=#{src_type}"
        resp = Net::HTTP.get_response(uri)

        srcid = nil

        if resp.is_a?(Net::HTTPSuccess)
          srcid =  JSON.load(resp.body)['id']
          puts "Successfully added \"#{path}\""
        elsif resp.code.to_i == 500 # internal server error
          error = resp.body.match(/\<\/H1\>([^\<]*)\<HR\>/i)[1].strip rescue nil
          puts "ERROR: \"#{path}\" could not be added (#{error})"
        else
          puts "ERROR: \"#{path}\" could not be added (unknown error)"
        end

        srcid
      end

      def scan_source(id)
        uri = URI("#{source_uri}/#{id}/scan")
        resp = Net::HTTP.get_response(uri)
        if resp.is_a?(Net::HTTPError)
          puts "Scanning for source (##{id}) could not be started"
        end
      end

      def delete_source(id)
        http = server_connection
        resp = http.send_request('DELETE', "/#{source_uri.path}/#{id}")
        if resp.is_a?(Net::HTTPSuccess)
          puts "Successfully deleted source ##{id}"
        else
          puts "ERROR: Couldn't delete source ##{id}"
        end
      end

      def source_cmd(action, items)
        case action.downcase
        when 'add'
          src_ids = []
          ARGV.each { |path| src_ids << add_source(path) }
          
          puts 'Sending source scan requests to server...'
          src_ids.compact.each { |id| scan_source(id) }

        when 'del'
          # have to empty out ARGV before user confirmation
          srcids = clone_and_empty_argv

          return unless user_confirmation

          srcids.each do |srcid|
            if srcid.downcase == 'all'
              get_sources.each { |s| delete_source(s['id']) }
              break
            else
              delete_source(srcid)
            end
          end

        when 'list'
          sources = get_sources

          # make pretty table
          longest = sources.collect { |s| s['location'].length }.max
          header = sprintf("%-5s %-#{longest+2}s %s",
                           'ID', 'Location', 'Last Updated')
          lines = []
          sources.each do |s|
            lines << sprintf("%-5s %-#{longest+2}s %s ago\n",
                             s['id'],
                               s['location'], 
                               time_ago_in_words(s['last_scanned_at']))
          end
          
          # puts pretty table
          puts header
          puts '-' * lines.collect { |l| l.length }.max
          puts lines

        when 'scan'
          ARGV.each do |srcid|
            if srcid.downcase == 'all'
              get_sources.each { |s| scan_source(s['id']) }
              break
            else
              scan_source(srcid)
            end
          end

        when 'help' then puts_command_help('source')
        end
      end
    end
  end
end
