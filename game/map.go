package game

// https://pkg.go.dev/gonum.org/v1/gonum/graph

type RouteJSON struct {
	Endpoints []string
	Color     string
	Length    int
	Tunnel    bool
	Ferries   int
}
