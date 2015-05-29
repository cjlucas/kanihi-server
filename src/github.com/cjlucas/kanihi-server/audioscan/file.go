package audioscan

import (
	"os"

	"github.com/cjlucas/audiotag/audiotag"
)

type File struct {
	Getter   audiotag.Getter
	FilePath string
	FileInfo os.FileInfo
}
