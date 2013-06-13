require 'nokogiri'

TYPE_BEGIN_ELEMENT  = Nokogiri::XML::Reader::TYPE_ELEMENT
TYPE_END_ELEMENT    = Nokogiri::XML::Reader::TYPE_END_ELEMENT

class ITunesLibrary
  attr_reader :count, :tracks

  TRACK_KEYMAP = {
    :total_time => :duration,
    :location   => :uri,
  }

  def initialize(f)
    @f = File.open(f)
    @r = Nokogiri::XML::Reader(@f)
  end

  # if no block given, returns an array of track_infos
  def self.parse(xml_file, &block)
    it = self.new(xml_file)
    it.read(block)
  end
  
  def read(block)
    track_infos = []
    until @r.read.nil?
      if @r.name.eql?('dict') && @r.depth == 3 # new track
        track_info = get_track_info
        unless block.nil?
          block.call(track_info)
        else
          track_infos << track_info
        end
      end
    end

    track_infos if block.nil?
  end

  private

  def get_track_info
    track_info = {}
    until @r.read.name.eql?('dict') && @r.node_type == TYPE_END_ELEMENT
      if @r.name.eql?('key') && @r.node_type == TYPE_BEGIN_ELEMENT
        key, value = read_key_value_pair
        track_info[key] = value
      end
    end
    track_info
  end

  ###
  # @r position must be on opening key
  def read_key_value_pair
    key = self.class.track_key(@r.read.value)
    value_type = @r.read.read.name.downcase

    value = true if value_type.eql? 'true'
    value = false if value_type.eql? 'false'
    value = self.class.cast(@r.read.value, value_type) if value.nil?

    @r.read # close value tag
    [key, value]
  end

  def self.cast(value, type)
    case type.downcase
    when 'integer'
      value.to_i
    else
      value
    end
  end

  def self.normalize(str)
    str.downcase!
    str.gsub!(' ', '_')
    str.to_sym
  end

  def self.track_key(key)
    key = normalize(key)
    TRACK_KEYMAP[key] || key
  end
end
