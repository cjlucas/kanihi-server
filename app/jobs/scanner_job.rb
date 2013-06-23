class ScannerJob
  def ScannerJob.job_for_source(source)
    case source.source_type
    when Source::Type::ITUNES_LIBRARY_XML_FILE
      ITunesLibraryScannerJob.new(source)
    end
  end
end
