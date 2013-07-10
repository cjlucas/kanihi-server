class ResizeImage
  def initialize(app)
    @app = app
  end
  

  def supported_content_type?
    return false if @headers.nil? || @headers['Content-Type'].nil?

    SUPPORTED_CONTENT_TYPES.each do |type|
      return true if @headers['Content-Type'].downcase.include?(type.downcase)
    end 

    false
  end

  # checks for required image headers
  def has_headers?
    ['HTTP_IMAGE_RESIZE_WIDTH', 'HTTP_IMAGE_RESIZE_HEIGHT'].each do |key|
      return true if @env.keys.include?(key)
    end

    return false
  end

  def is_image?
    return false unless @headers.has_key?('Content-Type')

    !(@headers['Content-Type'].match(/^image\//i)).nil?
  end

  def read_response
    io = StringIO.new
    @response.each do |resp|
      io.write(resp)
    end

    io
  end

  def resize_image
    src_io = read_response and src_io.rewind
    req_w = @env['HTTP_IMAGE_RESIZE_WIDTH']
    req_h = @env['HTTP_IMAGE_RESIZE_HEIGHT']
    src_w, src_h = ImageSpec.new(src_io).dimensions
    ar = src_w.to_f / src_h

    # because we're maintaing AR, we're only choosing one resize constraint
    if !req_w.nil?
      req_w = req_w.to_i
      # don't resize if requested size is > than actual size
      return if req_w >= src_w
      new_w = req_w
      new_h = (new_w / ar).round
    elsif !req_h.nil?
      req_h = req_h.to_i
      return if req_h >= src_h
      new_h = req_h
      new_w = (new_h * ar).round
    else
      return
    end

    puts "Src IO Size", src_io.size
    
    src_io.rewind
    img = MiniMagick::Image.read(src_io) and src_io.close
    img.resize "#{new_w}x#{new_h}"
    img.quality "92"
    img.format "JPEG"
    puts img.path 
    dest_io = img.write(StringIO.new) and dest_io.rewind

    #ap ImageSpec.new(dest_io) and dest_io.rewind

    @headers['Content-Type'] = 'image/jpeg'
    @response = dest_io.read and dest_io.close
  end

  def call(env)
    @env = env
    @status, @headers, @response = @app.call(@env)

    if @env['REQUEST_METHOD'] =~ /GET/
      resize_image if is_image? && has_headers?
      
      Rack::Response.new(@response, @status, @headers).finish
    else
      [@status, @headers, @response]
    end
  end
end
