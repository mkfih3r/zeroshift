package cmd

import "embed"

//go:embed rules/*.yaml
var DefaultRulesFS embed.FS