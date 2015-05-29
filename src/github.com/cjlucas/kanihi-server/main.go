package main

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"syscall"

	"github.com/cjlucas/audiotag/audiotag"
	"github.com/cjlucas/kanihi-server/audioscan"
	"github.com/cjlucas/kanihi-server/datastore"
	"github.com/jinzhu/gorm"
	_ "github.com/mattn/go-sqlite3"
)

const DB_PATH = "/Users/chris/kanihi.db"
const MUSIC_PATH = "/Volumes/DATA1/music"

var store *gorm.DB

func splitPair(s string) (int, int) {
	split := bytes.Split([]byte(s), []byte{'/'})
	var num, total int
	if len(split) == 2 {
		num, _ = strconv.Atoi(string(split[0]))
		total, _ = strconv.Atoi(string(split[1]))
	}

	return num, total
}

func trackForGetter(i audiotag.Getter, t *datastore.Track) {
	trackNum, totalTracks := splitPair(i.TrackPosition())
	discNum, totalDiscs := splitPair(i.DiscPosition())

	t.Title = i.TrackTitle()
	t.TrackArtist = i.TrackArtist()
	t.TrackArtistSortOrder = i.TrackArtistSortOrder()
	t.TrackNumber = trackNum
	t.TotalTracks = totalTracks
	t.AlbumTitle = i.AlbumTitle()
	t.AlbumArtist = i.AlbumArtist()
	t.AlbumArtistSortOrder = i.AlbumArtistSortOrder()
	t.DiscSubtitle = i.DiscSubtitle()
	t.DiscNumber = discNum
	t.TotalDiscs = totalDiscs
	t.Genre = i.Genre()
	t.Date = i.OriginalReleaseDate()

	for _, img := range i.Images() {
		t.Images.Add(datastore.Image{UUID: datastore.NewSHA1(img.Data())})
	}
}

func scanPath(db *gorm.DB) {
	sc := audioscan.FileScanner{}
	files, err := sc.Scan(MUSIC_PATH)
	if err != nil {
		panic(err)
	}

	fmt.Println(files)
	for f := range files {
		var stat syscall.Stat_t
		syscall.Stat(f.FilePath, &stat)

		// use t initially as the query in Find()
		t := datastore.Track{DevID: stat.Dev, Inode: stat.Ino}
		if db.Find(&t, t).RecordNotFound() {
			t.UUID = datastore.NewRandomUUID()
		} else {
			if t.ModTime == f.FileInfo.ModTime().UTC() {
				fmt.Println("file hasnt changed. skipping")
				continue
			}
		}

		t.FilePath = f.FilePath
		t.ModTime = f.FileInfo.ModTime().UTC()
		trackForGetter(f.Getter, &t)
		db.Save(&t)
	}
}

func main() {
	os.Remove(DB_PATH)

	db, err := gorm.Open("sqlite3", DB_PATH)

	if err != nil {
		panic(err)
	}

	db.LogMode(true)

	store = &db

	db.DB().Exec("PRAGMA journal_mode=WAL;")

	db.CreateTable(&datastore.Track{})
	db.CreateTable(&datastore.Image{})

	db.AutoMigrate(&datastore.Track{}, &datastore.Image{})

	go scanPath(&db)

	NewApiServer(&db).Serve(9999)
}
