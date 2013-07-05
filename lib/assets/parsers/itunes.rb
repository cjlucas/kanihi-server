require 'rexml/document'
require 'rexml/streamlistener'

class TrackListener
  include REXML::StreamListener

  attr_accessor :tracks

  def initialize(&block)
    @in_tag = nil
    @current_track = {}
    @current_key = nil
    @depth = 1
    @block = block
    @tracks = []
  end

  def tag_start(name, attributes)
    name.downcase!
    
    #ap "start: #{name}" 
    # new track
    if name.eql?('dict') && @depth == 4
      @current_track = {}
    end

    if name.eql?('key') && @depth == 5
      @in_tag = name
    end

    @depth += 1
  end

  def tag_end(name)
    name.downcase!
    @depth -= 1

    # end of track
    if @depth == 4 && name.eql?('dict')
      if @block.nil?
        @tracks << @current_track
      else
        @block.call(@current_track)
      end
    end

    @in_tag = nil
  end

  def text(text)
    if @in_tag.eql?('key')
      @current_key = text
    elsif !@current_key.nil?
      @current_track[@current_key] = text
      @current_key = nil
    end
  end
end

class ITunesLibrary
  def initialize(xml)
    @fp = File.open(xml)
  end

  def parse(&block)
    listener = TrackListener.new(&block)
    stream_parser = REXML::Parsers::StreamParser.new(@fp, listener)
    stream_parser.parse
    @fp.close
  end

  def self.parse(xml, &block)
    it = new(xml)
    it.parse(&block) 
  end
end
