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

    @tracks = Track.includes(:genre, :track_artist, :images, disc: [album: :album_artist])
      .order('updated_at ASC')
      .limit(@limit)
      .offset(@offset)
      .where('updated_at >= ?', @last_updated)

    respond_to do |format|
      format.html # index.html.erb
      format.json # index.json.rabl
    end
  end

  # GET /tracks/count
  def count
    last_updated_s = request.headers['Last-Updated-At']
    @last_updated = Time.at(0) if last_updated_s.nil?
    @last_updated = DateTime.parse(last_updated_s) unless last_updated_s.nil?
    @last_updated = @last_updated.utc

    count = Track.count(:conditions => ['updated_at >= ?', @last_updated])

    respond_to do |format|
      format.json { render json: { 'track_count' => count } }
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
    @track = case
             when !params[:id].nil?
               Track.find(params[:id])
             when !params[:uuid].nil?
               Track.where(:uuid => params[:uuid]).limit(1).first
             end

    @pos = params[:pos].to_i - 1
    
    et = EasyTag::File.new(@track.location) rescue nil
    raise if et.nil?
    
    et_img = et.album_art[@pos]
    raise if et_img.nil?

    send_data et_img.data, :type => et_img.mime_type, :disposition => :inline
  end

  # POST /tracks/deleted.json
  # Params (JSON)
  #   - a hash with one key, 'current_tracks', value is an array of uuids
  # Response
  #   - a hash with one key, 'deleted_tracks, value is an array of uuids
  def deleted # Think of a better name
    json_body = ActiveSupport::JSON.decode(request.body)

    deleted_tracks = json_body['current_tracks']
    # remove uuid from deleted_tracks array if still exists in db
    Track.select(:uuid).each { |t| deleted_tracks.delete(t.uuid) }

    respond_to do |format|
      format.json { render json: {'deleted_tracks' => deleted_tracks} }
    end
  end

  def stream
    @track = track_with_params(params)
    raise if @track.nil?

    filename = @track.uuid << File.extname(@track.location).downcase
    send_file @track.location, :type => 'audio/mpeg', :disposition => :inline, :filename => filename
  end

  def track_with_params(params)
    case
    when !params[:id].nil?
      Track.find(params[:id])
    when !params[:uuid].nil?
      Track.where(:uuid => params[:uuid]).limit(1).first
    end
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
