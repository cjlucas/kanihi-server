require 'awesome_print'

class TracksController < ApplicationController
  # GET /tracks
  # GET /tracks.json
  def index
    @limit = request.headers['SQL-Limit']
    @offset = request.headers['SQL-Offset']
    last_updated_s = request.headers['Last-Updated-At']
    @last_updated = Time.at(0) if last_updated_s.nil?
    @last_updated = DateTime.parse(last_updated_s) unless last_updated_s.nil?
    @last_updated = @last_updated.utc

    @tracks = Track.order('updated_at ASC')
      .limit(@limit)
      .offset(@offset)
      .where('updated_at >= ?', @last_updated)

    respond_to do |format|
      format.html # index.html.erb
      format.json # index.json.rabl
    end
  end

  # GET /tracks/1
  # GET /tracks/1.json
  def show
    @track = Track.find(params[:id]) unless params[:id].nil?
    @track = Track.where(:uuid => params[:uuid]) unless params[:uuid].nil?

    #respond_to do |format|
      #format.html # show.html.erb
      #format.json # show.json.rabl
    #end
  end

  def artwork
    @track = Track.find(params[:id])
    @pos = (params[:pos] || 1).to_i

    et = EasyTag::File.new(@track.location) rescue nil
    raise if et.nil?
    
    et_img = et.album_art[@pos]
    raise if et_img.nil?

    send_data et_img.data, :type => et_img.mime_type, :disposition => :inline
  end

  ## GET /tracks/new
  ## GET /tracks/new.json
  #def new
    #@track = Track.new

    #respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @track }
    #end
  #end

  ## GET /tracks/1/edit
  #def edit
    #@track = Track.find(params[:id])
  #end

  ## POST /tracks
  ## POST /tracks.json
  #def create
    #@track = Track.new(params[:track])

    #respond_to do |format|
      #if @track.save
        #format.html { redirect_to @track, notice: 'Track was successfully created.' }
        #format.json { render json: @track, status: :created, location: @track }
      #else
        #format.html { render action: "new" }
        #format.json { render json: @track.errors, status: :unprocessable_entity }
      #end
    #end
  #end

  ## PUT /tracks/1
  ## PUT /tracks/1.json
  #def update
    #@track = Track.find(params[:id])

    #respond_to do |format|
      #if @track.update_attributes(params[:track])
        #format.html { redirect_to @track, notice: 'Track was successfully updated.' }
        #format.json { head :no_content }
      #else
        #format.html { render action: "edit" }
        #format.json { render json: @track.errors, status: :unprocessable_entity }
      #end
    #end
  #end

  ## DELETE /tracks/1
  ## DELETE /tracks/1.json
  #def destroy
    #@track = Track.find(params[:id])
    #@track.destroy

    #respond_to do |format|
      #format.html { redirect_to tracks_url }
      #format.json { head :no_content }
    #end
  #end
end
