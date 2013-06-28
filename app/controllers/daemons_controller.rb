require 'cjutils/process'

class DaemonsController < ActionController::Base
  PID_DIR = File.join(Rails.root, 'tmp/pids')

  def start
   @name ||= params[:name]
   system "#{script_path} restart"

   head :no_content
  end

  def restart
    @name ||= params[:name]
    fork do
      stop
      sleep(5)
      start
    end

    head :no_content
  end

  def stop
    @name ||= params[:name]
    system "#{script_path} stop"
    
    head :no_content
  end

  def script_path
    raise ArgumentError, '@name not set' if @name.nil?
    File.join(Rails.root, 'script', @name.chomp('_monitor'))
  end

  def self.signal_for_name(name)
    case name.downcase
    when 'server' then 'INT'
    else 'TERM'
    end
  end
end
