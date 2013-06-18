class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :json

  def index
    @sources = Source.all
  end

  class ServerInfo < Struct.new(:jobs,
                                :track_count,
                                :image_count,
                                :server_time)
  end
  def info
    @info = ServerInfo.new
    @info.track_count = Track.count
    @info.image_count = Image.count
    @info.server_time = Time.now
    @info.jobs = process_jobs(Delayed::Job.all)
    #@info.jobs = []
  end

  class Job < Struct.new(:id,
                         :name,
                         :args,
                         :priority,
                         :run_at);
  end

  def process_jobs(jobs)
    new_jobs = []
    jobs.each do |job|
      new_job = Job.new
      new_job.id = job.id
      new_job.priority = case
                         when job.priority < 0 then 'low'
                         when job.priority == 0 then 'normal'
                         else 'high'
                         end
      new_job.run_at = job.run_at
      
      handler = YAML.load(job.handler)
      new_job.name = handler.class.to_s
      
      new_jobs << new_job
    end

    new_jobs
  end
end
