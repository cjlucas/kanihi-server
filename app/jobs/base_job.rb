class BaseJob
  # enqueue gives a Job object without an id, which is useless to us
  # so the logic for this is handled in JobRecordsController.enqueue
  def enqueue(job)
  end

  def before(job)
    puts 'before'
    JobRecordsController.new.update_record(job)
  end

  def after(job)
    puts 'after'
    puts JobRecordsController.new.attributes_for_delayed_job(job).to_s
    JobRecordsController.new.update_record(job)
  end

  def success(job)
    puts 'success'
    JobRecordsController.new.close_record(job)
  end

  def error(job, exception)
    puts 'error'
    puts job.send(:last_error)
    JobRecordsController.new.update_record(job)
  end

  #def failure
    #puts 'failure'
  #end
  
  def perform
    puts 'performing'
    raise 'omg fail'
  end

  def max_attempts
    1
  end
end
