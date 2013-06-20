class BaseJob
  # start delayed_job hooks
  
  def enqueue(job)
  end

  def before(job)
    @logger = get_logger(job.id)
    log_header(job)
  end

  def after(job)
    logger.close
  end

  def success(job)
  end

  def error(job, exception)
  end

  def failure
  end
  
  def perform
  end

  def max_attempts
    1
  end

  # end delayed_job hooks
 
  def log_header(job)
    logger.info('starting job:')
    logger.info(job.handler)
  end

  def logger
    @logger
  end

  def get_logger(job_id)
    logger = Logger.new(log_path(job_id))
    logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} - #{msg}\n" 
    end

    logger
  end

  def log_path(job_id)
    log_dir = Rails.root.join('log')
    Dir.mkdir(log_dir) unless Dir.exists?(log_dir)

    log_dir.join("job-#{job_id}.log")
  end

  def update_source
    @src.last_scanned_at = Time.now
    @src.save
  end
end
