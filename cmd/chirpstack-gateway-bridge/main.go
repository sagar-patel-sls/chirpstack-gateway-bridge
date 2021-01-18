package main

import "github.com/brocaar/chirpstack-gateway-bridge/cmd/chirpstack-gateway-bridge/cmd"

var version string // set by the compiler
var buildVersion string
var buildDate string

func main() {
	cmd.Execute(version, buildVersion, buildDate)
}
