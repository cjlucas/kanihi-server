class SourcesController < ApplicationController
  
  def index
    @sources = Source.all
    respond_with @sources
  end

  def new
    begin
      @source = Source.new_with_source_type(params[:location], params[:type])
    rescue Source::SourceNotFoundError
      raise "Source doesn't exist"
    end

    raise 'Source already added' unless @source.save

    respond_with @source
  end

  def show
    @source = Source.find(params[:id])
    respond_with @source
  end

  def destroy
    @source = Source.find(params[:id])
    # when a source is destroyed, the relationship entries are deleted too
    @source.destroy

    Delayed::Job.enqueue(PurgeOrphanedTracksJob.new)
    head :no_content
  end

  def scan
    @source = Source.find(params[:id])
    
    ScannerJob.job_for_source(@source).add
    head :no_content
  end
end
