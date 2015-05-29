package main

import (
	"encoding/json"
	"io"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
)

type JSONHandler struct {
	Payload interface{}
}

func (h JSONHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	jw := json.NewEncoder(w)
	jw.Encode(h.Payload)
}

type ServeFileHandler struct {
	FilePath string
}

func writeFile(r io.Reader, w io.Writer) error {
	var buf [4096]byte

	for {
		bytesRead, err := r.Read(buf[:])
		if err == io.EOF {
			return nil
		} else if err != nil {
			return err
		}

		bytesWritten := 0
		for bytesWritten < bytesRead {
			if n, err := w.Write(buf[bytesWritten:bytesRead]); err != nil {
				return err
			} else {
				bytesWritten += n
			}
		}
	}

	return nil
}

func (h ServeFileHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	stat, err := os.Stat(h.FilePath)
	if err != nil {
		// TODO: return 404
		panic(err)
	}

	w.Header().Set("Content-Length", strconv.Itoa(int(stat.Size())))
	if mtype := mime.TypeByExtension(filepath.Ext(h.FilePath)); mtype != "" {
		w.Header().Set("Content-Type", mtype)
	}

	if fp, err := os.Open(h.FilePath); err != nil {
		// TODO: return 500
		panic(err)
	} else {
		defer fp.Close()
		if err := writeFile(fp, w); err != nil {
			panic(err)
		}
	}
}
