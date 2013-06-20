class EasyTag::File
  def self.new_with_uri(uri)
    self.new(URI.unescape(uri.path))
  end
end

class ImagesController < ApplicationController
  def show
    @image = Image.find(params[:id])
    et_img = find_easytag_image
    raise ActionController::RoutingError.new('Image not found') if et_img.nil?
    send_data et_img.data, type: et_img.mime_type, disposition: :inline
  end

  # searches through tracks belonging to @image for a match
  # returns: EasyTag::Image or nil
  def find_easytag_image
    @image.tracks.each do |track|
      uri = URI(track.uri)
      next unless uri.exists?

      et = EasyTag::File.new_with_uri(uri)
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
