package main

import (
	"fmt"
	"mime"
	"net/http"

	"github.com/cjlucas/kanihi-server/datastore"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/jinzhu/gorm"
)

type ApiServer struct {
	db *gorm.DB
}

func NewApiServer(store *gorm.DB) *ApiServer {
	s := &ApiServer{store}
	return s
}
func (s *ApiServer) StreamHandler(w http.ResponseWriter, req *http.Request) {
	vars := mux.Vars(req)
	fmt.Println(vars)

	id, _ := datastore.ParseUUID(vars["id"])

	t := datastore.Track{}
	if s.db.Preload("Images").Where("uuid = ?", id).Find(&t).RecordNotFound() {
		fmt.Println("RECORD NOT FOUND")
		return
	}

	ServeFileHandler{t.FilePath}.ServeHTTP(w, req)
}

func (s *ApiServer) TracksHandler(w http.ResponseWriter, req *http.Request) {
	var tracks []datastore.Track
	s.db.Preload("Images").Find(&tracks)

	tracksJson := make(map[string][]datastore.Track)
	tracksJson["tracks"] = tracks
	handlers.CompressHandler(JSONHandler{tracksJson}).ServeHTTP(w, req)
	//JSONHandler{tracksJson}.ServeHTTP(w, req)
}

func (s *ApiServer) Serve(port int) error {
	mime.AddExtensionType(".mp3", "audio/mpeg")

	router := mux.NewRouter()
	router.HandleFunc("/tracks", s.TracksHandler)
	router.HandleFunc("/tracks/{id}/stream", s.StreamHandler)

	http.Handle("/", router)

	server := &http.Server{
		Addr: fmt.Sprintf(":%d", port),
	}

	return server.ListenAndServe()
}
