package audioscan

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/cjlucas/audiotag/id3"
)

type FileScanner struct {
	c chan File
}

func (s *FileScanner) handleFile(fpath string, fi os.FileInfo, err error) error {
	if fi.IsDir() || filepath.Ext(fpath) != ".mp3" || err != nil {
		return nil
	}

	if tag, err := id3.Read(fpath); err != nil {
		fmt.Println("Could not open id3:", fpath)
	} else {
		s.c <- File{
			Getter:   tag,
			FilePath: fpath,
			FileInfo: fi,
		}
	}

	return nil
}

func (s *FileScanner) Scan(path string) (<-chan File, error) {
	s.c = make(chan File)
	go func() {
		filepath.Walk(path, s.handleFile)
		close(s.c)
	}()
	return s.c, nil
}
