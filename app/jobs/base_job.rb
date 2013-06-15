class BaseJob
  def enqueue(job)
  end

  def before(job)
  end

  def after(job)
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
end
