require 'base_job'

class ScannerJob < BaseJob
  def self.job_for_source(source)
    case source.source_type
    when Source::Type::DIRECTORY
      DirectoryScannerJob.new(source)
    when Source::Type::ITUNES_LIBRARY_XML_FILE
      ITunesLibraryScannerJob.new(source)
    end
  end
  
  def initialize(source)
    @source_id = source.id
  end

  def priority
    Priority::HIGH
  end

  def source
    @source ||= Source.where(id: @source_id).first
  end

  def success(job)
    source.last_scanned_at = Time.now
  end

  def after(job)
    source.scanning = false
    source.save
  end
end
