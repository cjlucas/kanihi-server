class JobScheduler
  SLEEP_TIME = 1

  def check_sources
    Source.all.each do |source|
      next if source.scan_interval == 0 \
        || source.last_scanned_at.nil? \
        || source.scanning == true

      if Time.now - source.last_scanned_at > source.scan_interval
        Delayed::Job.enqueue(ScannerJob.job_for_source(source))
        source.scanning = true
        source.save
      end  
    end
  end

  def run
    halt = false
    Signal.trap('TERM') { halt = true }
    loop do
      check_sources
      halt ? exit : sleep(SLEEP_TIME)
    end
  end
end
