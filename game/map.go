package game

import (
	"encoding/json"
	"io"
	"log"

	"gonum.org/v1/gonum/graph"
)

// https://pkg.go.dev/gonum.org/v1/gonum/graph

type RouteJSON struct {
	Endpoints []string
	Color     string
	Length    int
	Tunnel    bool
	Ferries   int
}

type City struct {
	Name string
	id   int64
}

type Map struct {
	Graph  graph.UndirectWeighted
	Cities []City
}

func ImportJSONMap(r io.Reader) {
	d := make([]RouteJSON, 0, 0)
	err := json.NewDecoder(r).Decode(&d)
	if err != nil {
		log.Fatal(err)
	}

	var cities []string

	for _, route := range d {
		if 
	}
}
