package audioscan

type Scanner interface {
	Scan(in string) (<-chan File, error)
}
