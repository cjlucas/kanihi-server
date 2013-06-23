class SourcesController < ApplicationController
  respond_to :json
  
  def index
    @sources = Source.all
    respond_with @sources
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
