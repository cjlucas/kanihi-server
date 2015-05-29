package datastore

import (
	"database/sql/driver"
	"errors"

	"code.google.com/p/go-uuid/uuid"
)

type UUID struct {
	uuid.UUID
}

func NewRandomUUID() UUID {
	u := UUID{}
	u.UUID = uuid.NewRandom()
	return u
}

func NewSHA1(b []byte) UUID {
	u := UUID{}
	u.UUID = uuid.NewSHA1(uuid.NIL, b)
	return u
}

func ParseUUID(s string) (UUID, error) {
	u := UUID{}
	u.UUID = uuid.Parse(s)
	if u.UUID == nil {
		return u, errors.New("invalid UUID")
	}

	return u, nil
}

func (u UUID) Equal(o UUID) bool {
	return uuid.Equal(u.UUID, o.UUID)
}

func (u UUID) Value() (driver.Value, error) {
	return []byte(u.UUID), nil
}

func (u *UUID) Scan(src interface{}) error {
	if v, ok := src.([]byte); ok {
		u.UUID = uuid.UUID(v)
	}

	return nil
}
