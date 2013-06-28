class JobScheduler
  SLEEP_TIME = 1

  def check_sources
    Source.all.each do |source|
      next if source.scan_interval == 0 || source.last_scanned_at.nil?

      if Time.now - source.last_scanned_at > source.scan_interval
        Delayed::Job.enqueue(ScannerJob.job_for_source(source))
      end  
    end
  end

  def run
    loop do
      puts 'start loop'
      check_sources

      sleep(SLEEP_TIME)
    end
  end
end
