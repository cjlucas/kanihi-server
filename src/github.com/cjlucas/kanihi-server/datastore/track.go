package datastore

import "time"

type Image struct {
	ID      int64 `gorm:"primary_key" json:"-"`
	UUID    UUID  `gorm:"primary_key" sql:"type:blob(16)" json:"id"`
	TrackID int64 `gorm:"primary_key" sql:"index" json:"-"`
}

type ImageSet []Image

func (s *ImageSet) Add(image Image) {
	for _, img := range *s {
		if img.UUID.Equal(image.UUID) {
			return
		}
	}

	*s = append(*s, image)
}

type Track struct {
	ID                   int64     `gorm:"primary_key"json:"-"`
	UUID                 UUID      `sql:"type:blob(16)"json:"id"`
	Title                string    `json:"title"`
	TrackArtist          string    `json:"track_artist"`
	TrackArtistSortOrder string    `json:"track_artist_sort_order"`
	TrackNumber          int       `json:"track_number"`
	TotalTracks          int       `json:"total_tracks"`
	AlbumTitle           string    `json:"album_title"`
	AlbumArtist          string    `json:"album_artist"`
	AlbumArtistSortOrder string    `json:"album_artist_sort_order"`
	DiscSubtitle         string    `json:"disc_subtitle"`
	DiscNumber           int       `json:"disc_number"`
	TotalDiscs           int       `json:"total_discs"`
	Duration             int       `json:"duration"`
	Genre                string    `json:"genre"`
	Date                 time.Time `json:"date"`
	ModTime              time.Time `json:"-"`
	DevID                int32     `sql:"index" json:"-"`
	Inode                uint64    `sql:"index" json:"-"`
	FilePath             string    `json:"-"`
	Images               ImageSet  `json:"images"`
}
