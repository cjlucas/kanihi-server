fields = []
DATA.read.each_line do |l|
    l = l.split
    next if l.size < 2
    field = l[0].downcase
    ftype = l[1].downcase
    fields.push([field, ftype])
end

field_names = fields.collect{ |f| f[0] }
puts %Q{INSERT INTO TRACKS (#{field_names.join(",\n")}) VALUES (#{field_names.collect{|f| '?'}.join(",")});}
puts %Q{SELECT #{fields.collect{ |f| f[0] }.join(",\n")} from tracks;}

fields.each do |f|
    puts "#{f[0]} #{f[1]}"
end

__END__
	Id                   uuid.UUID `json:"id"`
	Title                string
	TrackArtist          string
	TrackArtistSortOrder string
	TrackNumber          int
	TotalTracks          int
	AlbumTitle           string
	AlbumArtist          string
	AlbumArtistSortOrder string
	DiscSubtitle         string
	DiscNumber           int
	TotalDiscs           int
	Duration             int
	Genre                string
	Date                 time.Time
	ModTime              time.Time `json:"-"`
	FilePath             string    `json:"-"`
