class JobScheduler
  SLEEP_TIME = 1

  def check_sources
    Source.find_each do |source|
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

  def run_maintenance_jobs
    if Time.now - @maintenance_last_run > 1.day
      PurgeOrphanedTracksJob.new.add
      PurgeOrphanedImagesJob.new.add
      @maintenance_last_run = Time.now
    end
  end

  def run
    halt = false
    Signal.trap('TERM') { halt = true }

    @maintenance_last_run = Time.new(1960)
    loop do
      check_sources
      run_maintenance_jobs
      halt ? exit : sleep(SLEEP_TIME)
    end
  end
end
