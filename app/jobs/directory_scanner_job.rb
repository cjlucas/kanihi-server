require 'scanner_job'

class DirectoryScannerJob < ScannerJob
  SUPPORTED_FILE_TYPES = ['mp3', 'm4a']

  def supported_audio_file?(file)
    ext = File.extname(file).downcase.sub('.','')
    SUPPORTED_FILE_TYPES.include?(ext)
  end

  def handle_file(filename)
    return unless File.readable?(filename) && supported_audio_file?(filename)
    fpath = File.expand_path(filename)
    
    t = Track.track_for_file_path(fpath)

    unless t.sources.include?(source)
      t.sources << source
      t.save
    end
  end

  def perform
    halt = false
    Signal.trap(:TERM) { halt = true }
    
    raise JobError, 'Source is no longer in database' if source.nil?

    source_glob = File.join(source.location, '**/*')
    Dir.glob(source_glob) do |filename|
      handle_file(filename) if File.file?(filename)
      exit if halt
    end
  end

end
