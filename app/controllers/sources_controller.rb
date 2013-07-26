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
    
    # calling destroy caused rails to hang, so we'll
    # handle deleting the relationships ourselves
    @source.delete

    sql = "DELETE from sources_tracks WHERE source_id = #{@source.id}"
    ActiveRecord::Base.connection.execute(sql)

    PurgeOrphanedTracksJob.new.add
    
    head :no_content
  end

  def scan
    @source = Source.find(params[:id])
    
    ScannerJob.job_for_source(@source).add
    head :no_content
  end
end
