class AlbumArtsController < ApplicationController
  # GET /album_arts
  # GET /album_arts.json
  def index
    @album_arts = AlbumArt.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @album_arts }
    end
  end

  # GET /album_arts/1
  # GET /album_arts/1.json
  def show
    @album_art = AlbumArt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album_art }
    end
  end

  # GET /album_arts/new
  # GET /album_arts/new.json
  def new
    @album_art = AlbumArt.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album_art }
    end
  end

  # GET /album_arts/1/edit
  def edit
    @album_art = AlbumArt.find(params[:id])
  end

  # POST /album_arts
  # POST /album_arts.json
  def create
    @album_art = AlbumArt.new(params[:album_art])

    respond_to do |format|
      if @album_art.save
        format.html { redirect_to @album_art, notice: 'Album art was successfully created.' }
        format.json { render json: @album_art, status: :created, location: @album_art }
      else
        format.html { render action: "new" }
        format.json { render json: @album_art.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /album_arts/1
  # PUT /album_arts/1.json
  def update
    @album_art = AlbumArt.find(params[:id])

    respond_to do |format|
      if @album_art.update_attributes(params[:album_art])
        format.html { redirect_to @album_art, notice: 'Album art was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @album_art.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /album_arts/1
  # DELETE /album_arts/1.json
  def destroy
    @album_art = AlbumArt.find(params[:id])
    @album_art.destroy

    respond_to do |format|
      format.html { redirect_to album_arts_url }
      format.json { head :no_content }
    end
  end
end
