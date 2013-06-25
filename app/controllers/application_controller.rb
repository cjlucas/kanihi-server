require 'cjutils/process'

class ApplicationController < ActionController::Base
  protect_from_forgery
  respond_to :json

  def index
    @sources = Source.all
  end

  def shutdown
    pid_dir = File.expand_path('tmp/pids', Rails.root)
    @shutdown_pid = fork do
      Dir[File.join(pid_dir, '*.pid')].each do |pid_file|
        signal = case File.basename(pid_file).downcase
                 when 'server.pid' then 'INT'
                 else 'TERM'
                 end
        pid = File.read(pid_file).to_i
        CJUtils::Process.kill(pid, signal, 30) if pid > 0
      end

    end

    render text: "MusicServer is shutting down (#{@shutdown_pid})"
  end

  class ServerInfo < Struct.new(:jobs,
                                :sources,
                                :track_count,
                                :image_count,
                                :server_time,
                                :server_version)
  end
  def info
    @info = ServerInfo.new
    @info.server_version = MusicServer::Application::VERSION
    @info.track_count = Track.count
    @info.image_count = Image.count
    @info.server_time = Time.now
    jobs_query = ['SELECT * from delayed_jobs',
                  'ORDER BY locked_at DESC, priority ASC'].join(' ')
    @info.jobs = process_jobs(Delayed::Job.find_by_sql(jobs_query))
    @info.sources = Source.all
    #@info.jobs = []
  end

  class Job < Struct.new(:id,
                         :name,
                         :args,
                         :priority,
                         :running,
                         :run_at);
  end

  def process_jobs(jobs)
    new_jobs = []
    jobs.each do |job|
      new_job = Job.new
      new_job.id = job.id
      new_job.priority = case
                         when job.priority >= BaseJob::Priority::LOW
                           'low'
                         when job.priority <= BaseJob::Priority::HIGH
                           'high'
                         else
                           'normal'
                         end
      new_job.run_at = job.run_at
      new_job.running = !job.locked_at.nil?
      
      handler = YAML.load(job.handler)
      new_job.name = handler.class.to_s
      
      new_jobs << new_job
    end

    new_jobs
  end
end
