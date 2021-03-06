class ImagesController < ApplicationController
  def show
    if !params[:id].nil?
      @image = Image.find(params[:id])
    elsif !params[:checksum].nil?
      @image = Image.where(:checksum => params[:checksum]).limit(1).first
    end

    raise if @image.nil?

    et_img = find_easytag_image
    raise ActionController::RoutingError.new('Image not found') if et_img.nil?
    send_data et_img.data, type: et_img.mime_type, disposition: :inline
  end

  # searches through tracks belonging to @image for a match
  # returns: EasyTag::Image or nil
  def find_easytag_image
    @image.tracks.each do |track|
      next unless File.exists?(track.location)

      et = EasyTag.open(track.location)
      et.album_art.each do |album_art|
        temp_img = Image.image_for_data(album_art.data)
        if temp_img.checksum == @image.checksum \
          && temp_img.size == @image.size
          return album_art
        end
      end
    end

    nil
  end
end
